import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    property var dockApps: [
        { key: "1", class: "Alacritty", icon: "icons/terminal.svg" },
        { key: "2", class: "firefox",   icon: "icons/globe.svg" },
        { key: "3", class: "Code",      icon: "icons/file-code.svg" },
        { key: "4", class: "Spotify",   icon: "icons/spotify.svg" }
    ]

    function isRunning(className) {
        return Hyprland.toplevels.values.some(t => t.lastIpcObject && t.lastIpcObject.class === className);
    }

    property bool shown: false

    visible: false
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell-dock"

    anchors.bottom: true
    margins.bottom: 14

    implicitWidth: row.implicitWidth + 20
    implicitHeight: row.implicitHeight + 16

    onShownChanged: {
        if (shown) {
            root.visible = true;
            transitionAnim.stop();
            content.opacity = 0;
            slideTransform.y = 16;
            showAnim.start();
        } else {
            showAnim.stop();
            transitionAnim.start();
        }
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: content; property: "opacity"; to: 1; duration: 160; easing.type: Easing.OutQuad }
        NumberAnimation { target: slideTransform; property: "y"; to: 0; duration: 160; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: transitionAnim
        ParallelAnimation {
            NumberAnimation { target: content; property: "opacity"; to: 0; duration: 140; easing.type: Easing.InQuad }
            NumberAnimation { target: slideTransform; property: "y"; to: 16; duration: 140; easing.type: Easing.InQuad }
        }
        ScriptAction { script: root.visible = false }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "submap")
                root.shown = (event.data === "dock");
        }
    }

    Rectangle {
        id: content
        anchors.fill: parent
        radius: 16
        color: "#e011293c"
        border.width: 1
        border.color: "#295ec1eb"
        transform: Translate { id: slideTransform }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: root.dockApps

                Rectangle {
                    required property var modelData

                    width: 46
                    height: 46
                    radius: 12
                    color: "#16324a"

                    Image {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        sourceSize: Qt.size(22, 22)
                        source: modelData.icon
                    }

                    Rectangle {
                        width: 15
                        height: 15
                        radius: 8
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -5
                        anchors.rightMargin: -5
                        color: "#11293c"
                        border.width: 1
                        border.color: "#295ec1eb"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.key
                            font.family: "Anthropic Mono Web"
                            font.pixelSize: 9
                            color: "#6f93a8"
                        }
                    }

                    Rectangle {
                        visible: root.isRunning(modelData.class)
                        width: 4
                        height: 4
                        radius: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -7
                        color: "#19b6ee"
                    }
                }
            }
        }
    }
}
