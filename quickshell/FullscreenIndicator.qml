import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 5

    readonly property var toplevel: Hyprland.activeToplevel
    readonly property var waylandState: toplevel ? toplevel.wayland : null
    readonly property bool maximized: waylandState ? waylandState.maximized : false
    readonly property bool fullscreen: waylandState ? waylandState.fullscreen : false

    visible: maximized || fullscreen

    Rectangle {
        width: 8
        height: 8
        radius: 4
        anchors.verticalCenter: parent.verticalCenter
        color: "#19b6ee"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Anthropic Mono Web"
        font.pixelSize: 11
        color: "#19b6ee"
        text: root.fullscreen ? "FULL" : "MAX"
    }
}
