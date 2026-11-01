import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            property var modelData
            property bool volumePopupOpen: false

            screen: modelData
            color: "transparent"

            anchors.top: true
            anchors.left: true
            anchors.right: true

            implicitHeight: 46
            margins.top: 14
            margins.left: 14
            margins.right: 14

            Rectangle {
                id: bar
                anchors.fill: parent
                radius: 15
                color: "#e011293c"
                border.width: 1
                border.color: "#295ec1eb"

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                PwObjectTracker {
                    objects: [Pipewire.defaultAudioSink]
                }

                function sortedWorkspaces() {
                    const list = Hyprland.workspaces.values.slice();
                    list.sort((a, b) => a.id - b.id);
                    return list;
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Repeater {
                        model: bar.sortedWorkspaces()

                        Rectangle {
                            required property var modelData

                            width: 22
                            height: 22
                            radius: 7
                            color: modelData.active ? "#19b6ee" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.id
                                font.pixelSize: 12
                                font.family: "Anthropic Mono Web"
                                color: modelData.active ? "#06202c" : "#6f93a8"
                            }

                            TapHandler {
                                onTapped: modelData.activate()
                            }
                        }
                    }
                }

                Rectangle {
                    id: volumeModule
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    implicitWidth: volumeRow.implicitWidth + 18
                    implicitHeight: volumeRow.implicitHeight + 10
                    radius: 9
                    color: (volumeHover.hovered || panel.volumePopupOpen) ? "#16324a" : "transparent"

                    Row {
                        id: volumeRow
                        anchors.centerIn: parent
                        spacing: 6

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            sourceSize: Qt.size(14, 14)

                            property var sink: Pipewire.defaultAudioSink

                            source: {
                                if (!sink || !sink.ready || !sink.audio || sink.audio.muted)
                                    return "icons/volume-x.svg";
                                const v = sink.audio.volume;
                                if (v < 0.01) return "icons/volume.svg";
                                if (v < 0.5) return "icons/volume-1.svg";
                                return "icons/volume-2.svg";
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: "Anthropic Mono Web"
                            font.pixelSize: 12
                            color: "#eaf4fa"

                            property var sink: Pipewire.defaultAudioSink

                            text: {
                                if (!sink || !sink.ready || !sink.audio) return "--";
                                if (sink.audio.muted) return "muted";
                                return Math.round(sink.audio.volume * 100) + "%";
                            }
                        }
                    }

                    HoverHandler {
                        id: volumeHover
                    }

                    TapHandler {
                        onTapped: panel.volumePopupOpen = !panel.volumePopupOpen
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        color: "#eaf4fa"
                        font.family: "Anthropic Mono Web"
                        font.pixelSize: 15
                        text: Qt.formatDateTime(clock.date, "hh:mm")
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        color: "#6f93a8"
                        font.family: "Anthropic Mono Web"
                        font.pixelSize: 12
                        text: Qt.formatDateTime(clock.date, "ddd, MMM d")
                    }
                }
            }

            PopupWindow {
                id: volumePopup
                visible: panel.volumePopupOpen
                property bool outputListOpen: false
                onVisibleChanged: if (!visible) outputListOpen = false

                color: "transparent"
                implicitWidth: 236
                implicitHeight: volumeColumn.implicitHeight + 24

                PwObjectTracker {
                    objects: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
                }

                anchor {
                    window: panel
                    item: volumeModule
                    rect {
                        x: volumeModule.width - volumePopup.implicitWidth + 10
                        y: volumeModule.height + 15
                        w: 1
                        h: 1
                    }
                    edges: Edges.Top | Edges.Left
                    gravity: Edges.Bottom | Edges.Right
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 15
                    color: "#e011293c"
                    border.width: 1
                    border.color: "#295ec1eb"

                    ColumnLayout {
                        id: volumeColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Image {
                                Layout.alignment: Qt.AlignVCenter
                                width: 16
                                height: 16
                                sourceSize: Qt.size(16, 16)

                                property var sink: Pipewire.defaultAudioSink

                                source: {
                                    if (!sink || !sink.ready || !sink.audio || sink.audio.muted)
                                        return "icons/volume-x.svg";
                                    const v = sink.audio.volume;
                                    if (v < 0.01) return "icons/volume.svg";
                                    if (v < 0.5) return "icons/volume-1.svg";
                                    return "icons/volume-2.svg";
                                }

                                TapHandler {
                                    onTapped: {
                                        const sink = Pipewire.defaultAudioSink;
                                        if (sink && sink.ready && sink.audio)
                                            sink.audio.muted = !sink.audio.muted;
                                    }
                                }
                            }

                            Rectangle {
                                id: volTrack
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                implicitHeight: 6
                                radius: 3
                                color: "#16324a"

                                property var sink: Pipewire.defaultAudioSink
                                property real level: (sink && sink.ready && sink.audio && !sink.audio.muted) ? sink.audio.volume : 0

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    radius: parent.radius
                                    width: parent.width * Math.min(1, volTrack.level)
                                    color: "#19b6ee"
                                }

                                Rectangle {
                                    width: 13
                                    height: 13
                                    radius: 7
                                    color: "#eaf4fa"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: parent.width * Math.min(1, volTrack.level) - width / 2
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    preventStealing: true

                                    function applyAt(mx) {
                                        const ratio = Math.min(1, Math.max(0, mx / volTrack.width));
                                        const sink = Pipewire.defaultAudioSink;
                                        if (!sink || !sink.ready || !sink.audio) return;
                                        sink.audio.volume = ratio;
                                        if (ratio > 0) sink.audio.muted = false;
                                    }

                                    onPressed: (mouse) => applyAt(mouse.x)
                                    onPositionChanged: (mouse) => { if (pressed) applyAt(mouse.x); }
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                font.family: "Anthropic Mono Web"
                                font.pixelSize: 12
                                color: "#6f93a8"

                                property var sink: Pipewire.defaultAudioSink

                                text: {
                                    if (!sink || !sink.ready || !sink.audio) return "--";
                                    if (sink.audio.muted) return "muted";
                                    return Math.round(sink.audio.volume * 100) + "%";
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 1
                            color: "#295ec1eb"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: outputRow.implicitHeight + 10
                            radius: 8
                            color: outputHover.hovered ? "#16324a" : "transparent"

                            RowLayout {
                                id: outputRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                spacing: 8

                                Image {
                                    Layout.alignment: Qt.AlignVCenter
                                    width: 15
                                    height: 15
                                    sourceSize: Qt.size(15, 15)
                                    source: "icons/headphones.svg"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    font.family: "Anthropic Mono Web"
                                    font.pixelSize: 12
                                    color: "#eaf4fa"
                                    elide: Text.ElideRight

                                    property var sink: Pipewire.defaultAudioSink
                                    text: (sink && sink.ready) ? (sink.description || sink.nickname || sink.name) : "--"
                                }

                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    font.pixelSize: 11
                                    color: "#6f93a8"
                                    text: volumePopup.outputListOpen ? "▲" : "▼"
                                }
                            }

                            HoverHandler {
                                id: outputHover
                            }

                            TapHandler {
                                onTapped: volumePopup.outputListOpen = !volumePopup.outputListOpen
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: volumePopup.outputListOpen
                            spacing: 2

                            Repeater {
                                model: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)

                                Rectangle {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    implicitHeight: outputLabel.implicitHeight + 10
                                    radius: 7
                                    color: itemHover.hovered ? "#16324a" : "transparent"

                                    Text {
                                        id: outputLabel
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        font.family: "Anthropic Mono Web"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        color: (Pipewire.defaultAudioSink === modelData) ? "#19b6ee" : "#eaf4fa"
                                        text: modelData.description || modelData.nickname || modelData.name
                                    }

                                    HoverHandler {
                                        id: itemHover
                                    }

                                    TapHandler {
                                        onTapped: {
                                            Pipewire.preferredDefaultAudioSink = modelData;
                                            volumePopup.outputListOpen = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            PanelWindow {
                screen: panel.screen
                visible: panel.volumePopupOpen
                color: "transparent"
                exclusiveZone: 0
                WlrLayershell.namespace: "quickshell-scrim"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                MouseArea {
                    anchors.fill: parent
                    onPressed: panel.volumePopupOpen = false
                }
            }
        }
    }
}
