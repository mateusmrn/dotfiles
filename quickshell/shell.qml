import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

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

                function sortedWorkspaces() {
                    const list = Hyprland.workspaces.values.slice();
                    list.sort((a, b) => a.id - b.id);
                    return list;
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
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
        }
    }
}
