import QtQuick
import Quickshell.Io

Row {
    id: root
    spacing: 5

    property bool running: false
    property bool paused: false
    property int elapsedSec: 0

    visible: running || paused

    IpcHandler {
        target: "stopwatch"

        function toggle(): void {
            if (root.running) {
                root.running = false;
                root.paused = true;
            } else {
                root.running = true;
                root.paused = false;
            }
        }

        function kill(): void {
            root.running = false;
            root.paused = false;
            root.elapsedSec = 0;
        }
    }

    Timer {
        interval: 1000
        running: root.running
        repeat: true
        onTriggered: root.elapsedSec += 1
    }

    Image {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        sourceSize: Qt.size(14, 14)
        source: "icons/timer.svg"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Anthropic Mono Web"
        font.pixelSize: 11
        color: root.paused ? "#f5a623" : "#5ec1eb"

        text: {
            const h = Math.floor(root.elapsedSec / 3600);
            const m = Math.floor((root.elapsedSec % 3600) / 60);
            const s = root.elapsedSec % 60;
            const pad = n => (n < 10 ? "0" : "") + n;
            return h > 0 ? (pad(h) + ":" + pad(m) + ":" + pad(s)) : (pad(m) + ":" + pad(s));
        }
    }
}
