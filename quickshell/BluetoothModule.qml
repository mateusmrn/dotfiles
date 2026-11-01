import QtQuick
import Quickshell.Bluetooth

Rectangle {
    id: root

    property bool active: false
    signal clicked()

    implicitWidth: icon.implicitWidth + 18
    implicitHeight: icon.implicitHeight + 10
    radius: 9
    color: (hoverHandler.hovered || root.active) ? "#16324a" : "transparent"

    Image {
        id: icon
        anchors.centerIn: parent
        width: 14
        height: 14
        sourceSize: Qt.size(14, 14)
        source: "icons/bluetooth.svg"
        opacity: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? 1.0 : 0.45
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
