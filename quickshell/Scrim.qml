import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool active: false
    signal dismissed()

    visible: active
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
        onPressed: root.dismissed()
    }
}
