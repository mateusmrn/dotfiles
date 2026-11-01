import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string iconSource: ""
    property var currentNode: null
    property string currentLabel: "--"
    property var devices: []
    property bool listOpen: false

    signal deviceSelected(var node)

    spacing: 2

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: headerRow.implicitHeight + 10
        radius: 8
        color: headerHover.hovered ? "#16324a" : "transparent"

        RowLayout {
            id: headerRow
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
                source: root.iconSource
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.family: "Anthropic Mono Web"
                font.pixelSize: 12
                color: "#eaf4fa"
                elide: Text.ElideRight
                text: root.currentLabel
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 11
                color: "#6f93a8"
                text: root.listOpen ? "▲" : "▼"
            }
        }

        HoverHandler {
            id: headerHover
        }

        TapHandler {
            onTapped: root.listOpen = !root.listOpen
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.listOpen
        spacing: 2

        Repeater {
            model: root.devices

            Rectangle {
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: itemLabel.implicitHeight + 10
                radius: 7
                color: itemHover.hovered ? "#16324a" : "transparent"

                Text {
                    id: itemLabel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    font.family: "Anthropic Mono Web"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    color: (root.currentNode === modelData) ? "#19b6ee" : "#eaf4fa"
                    text: modelData.description || modelData.nickname || modelData.name
                }

                HoverHandler {
                    id: itemHover
                }

                TapHandler {
                    onTapped: {
                        root.deviceSelected(modelData);
                        root.listOpen = false;
                    }
                }
            }
        }
    }
}
