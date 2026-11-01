import QtQuick

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
        width: 16
        height: 16
        sourceSize: Qt.size(16, 16)
        source: "icons/system-usage.svg"
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
