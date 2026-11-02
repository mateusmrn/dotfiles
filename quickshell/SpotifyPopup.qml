import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    property var panelWindow
    property var anchorItem

    property bool running: false
    property bool playing: false
    property string title: "--"
    property string artist: "--"
    property string artUrl: ""

    color: "transparent"
    implicitWidth: 240
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

    function refresh() {
        statusProc.running = true;
    }

    function control(action) {
        controlProc.command = ["playerctl", "-p", "spotify", action];
        controlProc.running = true;
    }

    // Fast polling while the popup is open.
    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Slow polling so the bar icon's running-state stays current when closed.
    Timer {
        interval: 3000
        running: !root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: ["playerctl", "-p", "spotify", "metadata", "--format", "{{status}}|{{title}}|{{artist}}|{{mpris:artUrl}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim();
                if (!text) {
                    root.running = false;
                    root.playing = false;
                    return;
                }
                try {
                    const parts = text.split("|");
                    root.running = true;
                    root.playing = parts[0] === "Playing";
                    root.title = parts[1] || "--";
                    root.artist = parts[2] || "--";
                    root.artUrl = parts[3] || "";
                } catch (e) {
                    root.running = false;
                }
            }
        }
    }

    Process {
        id: controlProc
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                radius: 10
                color: "#16324a"
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    font.family: "Anthropic Mono Web"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#eaf4fa"
                    elide: Text.ElideRight
                    text: root.title
                }

                Text {
                    Layout.fillWidth: true
                    font.pixelSize: 12
                    color: "#6f93a8"
                    elide: Text.ElideRight
                    text: root.artist
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                Layout.alignment: Qt.AlignHCenter
                spacing: 22

                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 8
                    color: prevHover.hovered ? "#16324a" : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        sourceSize: Qt.size(16, 16)
                        source: "icons/skip-back.svg"
                    }

                    HoverHandler { id: prevHover }
                    TapHandler { onTapped: root.control("previous") }
                }

                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: playHover.hovered ? "#16324a" : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        sourceSize: Qt.size(20, 20)
                        source: root.playing ? "icons/pause.svg" : "icons/play.svg"
                    }

                    HoverHandler { id: playHover }
                    TapHandler { onTapped: root.control("play-pause") }
                }

                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 8
                    color: nextHover.hovered ? "#16324a" : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        sourceSize: Qt.size(16, 16)
                        source: "icons/skip-forward.svg"
                    }

                    HoverHandler { id: nextHover }
                    TapHandler { onTapped: root.control("next") }
                }
            }
        }
    }
}
