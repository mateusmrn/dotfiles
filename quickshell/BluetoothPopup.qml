import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

PopupWindow {
    id: root

    property var panelWindow
    property var anchorItem

    color: "transparent"
    implicitWidth: 236
    implicitHeight: column.implicitHeight + 24

    anchor {
        window: panelWindow
        item: anchorItem
        rect {
            x: anchorItem ? anchorItem.width - root.implicitWidth + 10 : 0
            y: anchorItem ? anchorItem.height + 15 : 0
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
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    font.family: "Anthropic Mono Web"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#eaf4fa"
                    text: "Bluetooth"
                }

                Rectangle {
                    id: toggle
                    width: 34
                    height: 20
                    radius: 999
                    color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled)
                        ? "#5919b6ee"
                        : "#16324a"

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        y: 2
                        x: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? 16 : 2
                        color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? "#19b6ee" : "#6f93a8"

                        Behavior on x {
                            NumberAnimation { duration: 120 }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#295ec1eb"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                opacity: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? 1.0 : 0.4
                enabled: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled)

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }

                Text {
                    Layout.fillWidth: true
                    visible: pairedRepeater.count === 0
                    font.family: "Anthropic Mono Web"
                    font.pixelSize: 12
                    color: "#6f93a8"
                    text: "No paired devices"
                }

                Repeater {
                    id: pairedRepeater
                    model: Bluetooth.defaultAdapter
                        ? [...Bluetooth.defaultAdapter.devices.values].filter(d => d.paired)
                        : []

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: label.implicitHeight + 10
                        radius: 7
                        color: itemHover.hovered ? "#16324a" : "transparent"

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                id: label
                                Layout.fillWidth: true
                                font.family: "Anthropic Mono Web"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                color: modelData.connected ? "#19b6ee" : "#eaf4fa"
                                text: modelData.name || modelData.deviceName
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                visible: modelData.connected
                                font.pixelSize: 15
                                color: "#19b6ee"
                                text: "✓"
                            }
                        }

                        HoverHandler {
                            id: itemHover
                        }

                        TapHandler {
                            onTapped: modelData.connected ? modelData.disconnect() : modelData.connect()
                        }
                    }
                }
            }
        }
    }
}
