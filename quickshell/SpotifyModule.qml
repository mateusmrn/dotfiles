import QtQuick

Rectangle {
    id: root

    property bool active: false
    property bool running: false
    signal clicked()

    visible: running
    implicitWidth: visible ? icon.implicitWidth + 18 : 0
    implicitHeight: 24
    radius: 9
    color: (hoverHandler.hovered || root.active) ? "#16324a" : "transparent"

    Image {
        id: icon
        anchors.centerIn: parent
        width: 14
        height: 14
        sourceSize: Qt.size(14, 14)
        source: "icons/spotify.svg"
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
