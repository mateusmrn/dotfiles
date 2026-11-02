import QtQuick
import Quickshell.Io

Row {
    id: root
    spacing: 5

    property bool recording: false
    visible: recording

    Process {
        id: poller
        command: ["pgrep", "-x", "wf-recorder"]
        onExited: (exitCode) => root.recording = (exitCode === 0)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poller.running = true
    }

    Rectangle {
        id: dot
        width: 8
        height: 8
        radius: 4
        anchors.verticalCenter: parent.verticalCenter
        color: "#ff5a5f"

        SequentialAnimation on opacity {
            running: root.recording
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1; duration: 600; easing.type: Easing.InOutQuad }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Anthropic Mono Web"
        font.pixelSize: 11
        color: "#ff5a5f"
        text: "REC"
    }
}
