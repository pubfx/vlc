/*****************************************************************************
 * Copyright (C) 2026 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
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
import QtQuick

import VLC.Widgets as Widgets
import VLC.Style
import VLC.Player
import VLC.Util

// Redesign: base of the subtitle / audio buttons. Opens the quick track panel
// (TracksQuickMenu) on a given tab, right-aligned above the button.
Widgets.IconToolButton {
    id: root

    // tab of TracksQuickMenu to show first (0 subtitles, 1 audio, 2 video)
    property int initialTab: 0

    readonly property var _parentItem: {
        if ((typeof rootPlayer !== 'undefined') && (rootPlayer !== null))
            return rootPlayer
        else
            return g_mainDisplay
    }

    signal requestLockUnlockAutoHide(bool lock)
    signal menuOpened(var menu)

    enabled: menuLoader.status === Loader.Ready

    checked: menuLoader.item ? menuLoader.item.visible : false

    // pressing the button while the panel is open closes the panel (press
    // outside the popup); don't reopen it on the click that follows
    property double _lastCloseTime: 0

    onClicked: {
        const menu = menuLoader.item
        if (menu.visible) {
            menu.close()
            return
        }
        if (Date.now() - root._lastCloseTime < 300)
            return
        menu.currentTab = root.initialTab

        // computed on open, the button moves when the control bar is laid out:
        // keep the panel inside the player, right edge aligned with the button
        const buttonRight = root.mapToItem(menu.parent, root.width, 0).x
        menu.x = Math.max(VLCStyle.margin_xsmall,
                          Math.min(buttonRight - menu.width,
                                   menu.parent.width - menu.width - VLCStyle.margin_xsmall))
        menu.open()
    }

    Loader {
        id: menuLoader

        sourceComponent: TracksQuickMenu {
            id: menu

            parent: root._parentItem

            // x is set when opening
            y: (parent.positionSliderY - height - VLCStyle.margin_xsmall)
            z: 1

            focus: true

            colorContext.palette: root.colorContext.palette

            onOpened: {
                root.requestLockUnlockAutoHide(true)
                root.menuOpened(menu)
            }

            onClosed: {
                root._lastCloseTime = Date.now()
                root.requestLockUnlockAutoHide(false)
                root.forceActiveFocus()
                root.menuOpened(null)
            }
        }
    }

    function forceUnlock() {
        // also called while the control bar is torn down, after menuLoader is gone
        if (menuLoader && menuLoader.item)
            menuLoader.item.close()
    }
}
