import QtQuick

Rectangle {
    id: root

    property bool active: false
    property string connectionType: "none"
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
        source: {
            if (root.connectionType === "wifi") return "icons/wifi.svg";
            if (root.connectionType === "ethernet") return "icons/ethernet-port.svg";
            return "icons/wifi-off.svg";
        }
        opacity: root.connectionType === "none" ? 0.45 : 1.0
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
