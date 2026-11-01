import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    property var panelWindow
    property var anchorItem

    property real cpuPercent: 0
    property string memValue: "--"
    property real memPercent: 0
    property string diskValue: "--"
    property real diskPercent: 0
    property string diskModel: "--"
    property real gpuPercent: 0
    property string gpuModel: "--"

    property real prevCpuTotal: -1
    property real prevCpuIdle: -1

    color: "transparent"
    implicitWidth: 230
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
        cpuProc.running = true;
        memProc.running = true;
        diskProc.running = true;
        gpuProc.running = true;
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: diskModelProc
        command: ["lsblk", "-d", "-n", "-o", "MODEL", "/dev/nvme0n1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.diskModel = this.text.trim()
        }
    }

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const line = this.text.split("\n")[0];
                    const parts = line.trim().split(/\s+/).slice(1).map(Number);
                    const idle = parts[3] + parts[4];
                    const total = parts.reduce((a, b) => a + b, 0);
                    if (root.prevCpuTotal >= 0) {
                        const totalDelta = total - root.prevCpuTotal;
                        const idleDelta = idle - root.prevCpuIdle;
                        if (totalDelta > 0)
                            root.cpuPercent = Math.round((1 - idleDelta / totalDelta) * 100);
                    }
                    root.prevCpuTotal = total;
                    root.prevCpuIdle = idle;
                } catch (e) {}
            }
        }
    }

    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = this.text.split("\n");
                    let total = 0, avail = 0;
                    for (const l of lines) {
                        if (l.startsWith("MemTotal:")) total = parseInt(l.match(/\d+/)[0]);
                        if (l.startsWith("MemAvailable:")) avail = parseInt(l.match(/\d+/)[0]);
                    }
                    const used = total - avail;
                    root.memPercent = total > 0 ? Math.round((used / total) * 100) : 0;
                    root.memValue = (used / 1048576).toFixed(1) + " GB / " + (total / 1048576).toFixed(0) + " GB";
                } catch (e) {}
            }
        }
    }

    Process {
        id: diskProc
        command: ["df", "-B1", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = this.text.trim().split("\n");
                    const parts = lines[lines.length - 1].trim().split(/\s+/);
                    const used = parseFloat(parts[2]);
                    const size = parseFloat(parts[1]);
                    root.diskPercent = size > 0 ? Math.round((used / size) * 100) : 0;
                    root.diskValue = (used / 1e9).toFixed(0) + " GB / " + (size / 1e9).toFixed(0) + " GB";
                } catch (e) {}
            }
        }
    }

    Process {
        id: gpuProc
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,name", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parts = this.text.trim().split(",");
                    if (parts.length >= 2) {
                        root.gpuPercent = parseInt(parts[0].trim()) || 0;
                        root.gpuModel = parts[1].trim();
                    }
                } catch (e) {}
            }
        }
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
            spacing: 12

            SystemStat {
                Layout.fillWidth: true
                label: "CPU"
                value: root.cpuPercent + "%"
                percent: root.cpuPercent
            }

            SystemStat {
                Layout.fillWidth: true
                label: "Memory"
                value: root.memValue
                percent: root.memPercent
            }

            SystemStat {
                Layout.fillWidth: true
                label: "Disk"
                value: root.diskValue
                percent: root.diskPercent
                device: root.diskModel
            }

            SystemStat {
                Layout.fillWidth: true
                label: "GPU"
                value: root.gpuPercent + "%"
                percent: root.gpuPercent
                device: root.gpuModel
            }
        }
    }
}
