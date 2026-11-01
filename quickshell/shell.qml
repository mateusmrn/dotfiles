import QtQuick
import QtQuick.Layouts
import Quickshell

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
                anchors.fill: parent
                radius: 15
                color: "#e011293c"
                border.width: 1
                border.color: "#295ec1eb"

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
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
