/*****************************************************************************
 * Copyright (C) 2025 the VideoLAN team
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#include "ui_notifier.hpp"

#include "maininterface/mainctx.hpp"

#include <vlc_actions.h>
#include <vlc_configuration.h>

#include <QPointer>

/* Redesign: on-screen messages show the shortcut that was pressed (SPEC §2).
 * Called on whichever thread pressed the key; builds "Play/Pause · Space" and
 * hands it to the UI thread. Actions not caused by one of their own key
 * bindings (menus, remotes...) and mouse wheel actions are not shown. */
static int ShortcutActionCallback( vlc_object_t *libvlc, const char *,
                                   vlc_value_t, vlc_value_t newval, void *data )
{
    const vlc_action_id_t action = static_cast<vlc_action_id_t>( newval.i_int );
    const uint_fast32_t keycode = var_GetInteger( libvlc, "key-pressed" );
    const uint_fast32_t baseKey = keycode & ~KEY_MODIFIER;
    if( keycode == KEY_UNSET
        || ( baseKey >= KEY_MOUSEWHEELUP && baseKey <= KEY_MOUSEWHEELRIGHT ) )
        return VLC_SUCCESS;

    /* key names are bare ("play-pause"); the option and the id lookup use "key-play-pause" */
    const char *name = nullptr;
    QByteArray option;
    for( const char *const *names = vlc_actions_get_key_names( libvlc ); *names; ++names )
    {
        option = QByteArray( "key-" ) + *names;
        if( vlc_actions_get_id( option.constData() ) == action )
        {
            name = *names;
            break;
        }
    }
    if( !name )
        return VLC_SUCCESS;

    /* only when the pressed key is one of this action's bindings */
    uint_fast32_t *keycodes = nullptr;
    const size_t count = vlc_actions_get_keycodes( libvlc, name, false, &keycodes );
    bool matches = false;
    for( size_t i = 0; i < count; ++i )
        matches = matches || ( keycodes[i] == keycode );
    free( keycodes );
    if( !matches )
        return VLC_SUCCESS;

    const module_config_t *config = config_FindConfig( option.constData() );
    const QString label = ( config && config->psz_text ) ? qfu( vlc_gettext( config->psz_text ) )
                                                         : QString::fromUtf8( name );
    char *psz_key = vlc_keycode2str( keycode, true );
    QString key = psz_key ? QString::fromUtf8( psz_key ) : QString();
    free( psz_key );
    /* "Shift+r" -> "Shift+R", as in the menus */
    QStringList parts = key.split( '+' );
    for( QString &part : parts )
        if( part.size() == 1 )
            part = part.toUpper();
    key = parts.join( '+' );

    QPointer<UINotifier> notifier = static_cast<UINotifier *>( data );
    QMetaObject::invokeMethod( notifier, [notifier, label, key]() {
        if( notifier )
            emit notifier->showNotification( UINotifier::Shortcut,
                                             key.isEmpty() ? label : label + QStringLiteral( " · " ) + key );
    }, Qt::QueuedConnection );
    return VLC_SUCCESS;
}

UINotifier::UINotifier(MainCtx *ctx, QObject *parent)
    : QObject {parent}
    , m_ctx {ctx}
{
    setupNotifications();

    // Redesign: watch hotkey actions to show their shortcut
    if (m_ctx && m_ctx->getIntf())
    {
        m_libvlc = VLC_OBJECT(vlc_object_instance(m_ctx->getIntf()));
        var_AddCallback(m_libvlc, "key-action", ShortcutActionCallback, this);
    }
}

UINotifier::~UINotifier()
{
    if (m_libvlc)
        var_DelCallback(m_libvlc, "key-action", ShortcutActionCallback, this);
}

void UINotifier::setupNotifications()
{
    connect(m_ctx, &MainCtx::intfScaleFactorChanged, this, [this]()
    {
        const QString scale = QString::number(m_ctx->getIntfScaleFactor() * 100);
        emit showNotification(Scale
                              , qtr("Scale: %1%").arg(scale));
    });

    connect(m_ctx, &MainCtx::mainInterfaceModesChanged, this, [this]()
    {
        if (m_ctx->isMinimalView())
            emit showNotification(MinimalView
                                  , qtr("Minimal View"));
    });

    // Redesign: tell how to get the hidden player bars back
    connect(m_ctx, &MainCtx::playerUiHiddenChanged, this, [this]()
    {
        if (m_ctx->playerUiHidden())
            emit showNotification(HideUI
                                  , qtr("Interface hidden. Press Ctrl+\\ to show it"));
    });
}
