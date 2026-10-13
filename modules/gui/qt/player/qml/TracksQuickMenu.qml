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
import QtQuick.Templates as T
import QtQuick.Layouts

import VLC.Style
import VLC.Player
import VLC.Widgets as Widgets
import VLC.Util
import VLC.Dialogs

// Redesign: compact track panel opened by the subtitle and audio buttons
// (SPEC §2, Figma "subtitle one" / "subtitle multiple"). One tab per track
// type, so video tracks don't need their own button; the audio tab also lists
// the audio output devices (headphones / speakers).
T.Popup {
    id: root

    readonly property int tabSubtitles: 0
    readonly property int tabAudio: 1
    readonly property int tabVideo: 2

    property int currentTab: tabSubtitles

    readonly property var _tracksModel: (currentTab === tabSubtitles) ? Player.subtitleTracks
                                      : (currentTab === tabAudio) ? Player.audioTracks
                                      : Player.videoTracks

    // bumped whenever a track row changes its checked state, so the "Off" row
    // re-evaluates whether any track is selected
    property int _selectionRevision: 0

    width: VLCStyle.trackPanel_width
    height: Math.min(implicitHeight, VLCStyle.trackPanel_maxHeight)

    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    padding: VLCStyle.margin_xsmall

    // take keyboard focus so Escape closes the panel
    onOpened: flickable.forceActiveFocus()

    readonly property ColorContext colorContext: ColorContext {
        id: popupTheme
        colorSet: ColorContext.Window
    }

    background: Rectangle {
        color: popupTheme.bg.primary
        radius: VLCStyle.trackPanel_radius
        border.color: popupTheme.border
        border.width: VLCStyle.dp(1, VLCStyle.scale)
    }

    contentItem: Flickable {
        id: flickable

        // popup content is not parented to the popup item, so the rows can't
        // inherit popupTheme; give them a context of their own
        readonly property ColorContext colorContext: ColorContext {
            colorSet: ColorContext.View
            palette: popupTheme.palette
        }

        implicitHeight: content.implicitHeight
        contentHeight: content.implicitHeight

        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: content

            width: flickable.width

            spacing: VLCStyle.margin_xxxsmall

            Row {
                bottomPadding: VLCStyle.margin_xxsmall

                spacing: VLCStyle.margin_xxsmall

                Repeater {
                    model: [qsTr("Subtitles"), qsTr("Audio"), qsTr("Video")]

                    delegate: TabChip {
                        required property string modelData
                        required property int index

                        text: modelData
                        selected: (index === root.currentTab)

                        onClicked: root.currentTab = index
                    }
                }
            }

            TrackRow {
                width: content.width

                visible: (root.currentTab === root.tabSubtitles)

                text: qsTr("Off")
                iconText: VLCIcons.clear

                checked: {
                    void root._selectionRevision
                    return !trackRepeater.anyChecked()
                }

                onClicked: trackRepeater.uncheckAll()
            }

            Repeater {
                id: trackRepeater

                model: root._tracksModel

                function anyChecked() {
                    for (let i = 0; i < count; ++i) {
                        const item = itemAt(i)
                        if (item && item.checked)
                            return true
                    }
                    return false
                }

                function uncheckAll() {
                    for (let i = 0; i < count; ++i) {
                        const item = itemAt(i)
                        if (item && item.checked)
                            item.setTrackChecked(false)
                    }
                }

                delegate: TrackRow {
                    width: content.width

                    text: model.display
                    iconText: (root.currentTab === root.tabSubtitles) ? VLCIcons.ic_fluent_document_copy_24_regular
                            : (root.currentTab === root.tabAudio) ? VLCIcons.volume_high
                            : VLCIcons.topbar_video

                    checked: model.checked

                    onCheckedChanged: root._selectionRevision++

                    function setTrackChecked(value) {
                        model.checked = value
                    }

                    // a click only ever selects, so a stray click can't mute
                    // the audio or hide the video; "Off" turns subtitles off
                    onClicked: setTrackChecked(true)
                }
            }

            TrackRow {
                width: content.width

                visible: (root.currentTab !== root.tabAudio)

                text: (root.currentTab === root.tabSubtitles) ? qsTr("Add subtitle file...")
                                                              : qsTr("Add video file...")
                iconText: VLCIcons.add
                showCheck: false

                onClicked: {
                    root.close()
                    if (root.currentTab === root.tabSubtitles)
                        DialogsProvider.loadSubtitlesFile()
                    else
                        DialogsProvider.loadVideoFile()
                }
            }

            Widgets.CaptionLabel {
                // no heading when the audio output exposes no devices
                visible: (root.currentTab === root.tabAudio) && (deviceRepeater.count > 0)

                topPadding: VLCStyle.margin_xsmall
                leftPadding: VLCStyle.margin_xsmall
                bottomPadding: VLCStyle.margin_xxxsmall

                text: qsTr("Output device")
            }

            Repeater {
                id: deviceRepeater

                model: (root.currentTab === root.tabAudio) ? Player.audioDevices : null

                delegate: TrackRow {
                    width: content.width

                    text: model.display
                    iconText: VLCIcons.renderer
                    checked: model.checked

                    onClicked: model.checked = true
                }
            }
        }
    }

    // Figma "subtitle one": 36 px row, icon + name, orange check when selected;
    // the selected / hovered row sits on a darker background
    component TrackRow: T.ItemDelegate {
        id: row

        property string iconText: ""
        property bool showCheck: true

        implicitHeight: VLCStyle.trackPanel_rowHeight

        leftPadding: VLCStyle.margin_xsmall
        rightPadding: VLCStyle.margin_small

        focusPolicy: Qt.StrongFocus

        readonly property ColorContext colorContext: ColorContext {
            id: rowTheme
            colorSet: ColorContext.View
        }

        background: Rectangle {
            radius: VLCStyle.trackPanel_radius
            color: Qt.rgba(0, 0, 0, row.hovered || row.visualFocus ? 0.45
                                   : row.checked ? 0.6 : 0)
        }

        contentItem: RowLayout {
            spacing: VLCStyle.margin_small

            Widgets.IconLabel {
                Layout.preferredWidth: VLCStyle.icon_normal

                text: row.iconText
                color: rowTheme.fg.secondary
                font.pixelSize: VLCStyle.icon_small * 1.5
            }

            Widgets.ListLabel {
                Layout.fillWidth: true

                // Figma: regular weight, the check mark shows the selection
                font.weight: Font.Normal

                text: row.text
                color: (row.hovered || row.visualFocus) ? rowTheme.fg.primary : rowTheme.fg.secondary
                elide: Text.ElideRight
            }

            Widgets.IconLabel {
                visible: row.showCheck && row.checked

                text: VLCIcons.check
                color: rowTheme.accent
                font.pixelSize: VLCStyle.icon_small * 1.5
            }
        }
    }

    component TabChip: T.Button {
        id: chip

        property bool selected: false

        // templates have no implicit size of their own
        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                implicitContentWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                 implicitContentHeight + topPadding + bottomPadding)

        padding: VLCStyle.margin_xsmall
        bottomPadding: VLCStyle.margin_xsmall + underline.height

        focusPolicy: Qt.StrongFocus

        readonly property ColorContext colorContext: ColorContext {
            id: chipTheme
            colorSet: ColorContext.View
        }

        contentItem: Widgets.ListLabel {
            text: chip.text
            color: (chip.selected || chip.hovered || chip.visualFocus) ? chipTheme.fg.primary
                                                                      : chipTheme.fg.secondary
            font.weight: chip.selected ? Font.DemiBold : Font.Normal
        }

        background: Item {
            Rectangle {
                id: underline

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                height: VLCStyle.margin_xxxsmall
                radius: height / 2

                visible: chip.selected
                color: chipTheme.accent
            }
        }
    }
}
