import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            property var modelData
            property bool volumePopupOpen: false

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

                Workspaces {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                }

                VolumeModule {
                    id: volumeModule
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    active: panel.volumePopupOpen
                    onClicked: panel.volumePopupOpen = !panel.volumePopupOpen
                }

                KeyboardLayoutModule {
                    anchors.right: volumeModule.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                ClockWidget {
                    anchors.centerIn: parent
                }
            }

            VolumePopup {
                id: volumePopup
                visible: panel.volumePopupOpen
                panelWindow: panel
                anchorItem: volumeModule
            }

            Scrim {
                screen: panel.screen
                active: panel.volumePopupOpen
                onDismissed: panel.volumePopupOpen = false
            }
        }
    }
}
