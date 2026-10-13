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

#ifndef UI_NOTIFIER_HPP
#define UI_NOTIFIER_HPP

#include <QObject>

class MainCtx;

class UINotifier : public QObject
{
    Q_OBJECT
public:
    UINotifier(MainCtx *ctx, QObject *parent = nullptr);
    ~UINotifier() override;

    enum ID
    {
        Scale,
        MinimalView,
        HideUI, // Redesign
        Shortcut // Redesign: action and the key that triggered it
    };

    Q_ENUM(ID)

signals:
    void showNotification(ID id, const QString &text);

private:
    void setupNotifications();

    MainCtx *m_ctx;
    // Redesign: libvlc instance watched for hotkey actions
    struct vlc_object_t *m_libvlc = nullptr;
};

#endif // UI_NOTIFIER_HPP
