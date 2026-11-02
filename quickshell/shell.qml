import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            property var modelData
            property bool volumePopupOpen: false
            property bool bluetoothPopupOpen: false
            property bool systemUsagePopupOpen: false
            property bool networkPopupOpen: false
            property bool spotifyPopupOpen: false

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
                    id: keyboardModule
                    anchors.right: volumeModule.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                BluetoothModule {
                    id: bluetoothModule
                    anchors.right: keyboardModule.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    active: panel.bluetoothPopupOpen
                    onClicked: panel.bluetoothPopupOpen = !panel.bluetoothPopupOpen
                }

                SystemUsageModule {
                    id: systemUsageModule
                    anchors.right: bluetoothModule.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    active: panel.systemUsagePopupOpen
                    onClicked: panel.systemUsagePopupOpen = !panel.systemUsagePopupOpen
                }

                NetworkModule {
                    id: networkModule
                    anchors.right: systemUsageModule.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    active: panel.networkPopupOpen
                    connectionType: networkPopup.connectionType
                    onClicked: panel.networkPopupOpen = !panel.networkPopupOpen
                }

                SpotifyModule {
                    id: spotifyModule
                    anchors.right: networkModule.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    active: panel.spotifyPopupOpen
                    running: spotifyPopup.running
                    onClicked: panel.spotifyPopupOpen = !panel.spotifyPopupOpen
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

            BluetoothPopup {
                id: bluetoothPopup
                visible: panel.bluetoothPopupOpen
                panelWindow: panel
                anchorItem: bluetoothModule
            }

            SystemUsagePopup {
                id: systemUsagePopup
                visible: panel.systemUsagePopupOpen
                panelWindow: panel
                anchorItem: systemUsageModule
            }

            NetworkPopup {
                id: networkPopup
                visible: panel.networkPopupOpen
                panelWindow: panel
                anchorItem: networkModule
            }

            SpotifyPopup {
                id: spotifyPopup
                visible: panel.spotifyPopupOpen
                panelWindow: panel
                anchorItem: spotifyModule
            }

            Scrim {
                screen: panel.screen
                active: panel.volumePopupOpen || panel.bluetoothPopupOpen || panel.systemUsagePopupOpen || panel.networkPopupOpen || panel.spotifyPopupOpen
                onDismissed: {
                    panel.volumePopupOpen = false;
                    panel.bluetoothPopupOpen = false;
                    panel.systemUsagePopupOpen = false;
                    panel.networkPopupOpen = false;
                    panel.spotifyPopupOpen = false;
                }
            }
        }
    }
}
