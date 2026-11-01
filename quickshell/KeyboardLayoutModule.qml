import QtQuick
import Quickshell.Io

Row {
    id: root
    spacing: 6

    property string layoutText: "--"

    function shortName(code) {
        if (!code) return "--";
        const lower = code.toLowerCase();
        if (lower.indexOf("intl") !== -1) return "US-Intl";
        if (lower.indexOf("us") !== -1) return "US";
        return code;
    }

    Process {
        id: poller
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    const keyboards = data.keyboards || [];
                    const kb = keyboards.find(k => k.main) || keyboards[0];
                    if (kb) {
                        const layouts = (kb.layout || "").split(",");
                        const current = layouts[kb.active_layout_index] || layouts[0];
                        root.layoutText = root.shortName(current);
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poller.running = true
    }

    Image {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        sourceSize: Qt.size(14, 14)
        source: "icons/keyboard.svg"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Anthropic Mono Web"
        font.pixelSize: 12
        color: "#eaf4fa"
        text: root.layoutText
    }
}
