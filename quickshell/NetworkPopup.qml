import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    property var panelWindow
    property var anchorItem

    property string connectionType: "none"
    property string iface: "--"
    property string ipAddress: "--"
    property string speed: "--"
    property string ssid: ""
    property string signal_: ""
    property string downloadRate: "-- KB/s"
    property string uploadRate: "-- KB/s"

    property real prevRx: -1
    property real prevTx: -1
    property real prevSampleTime: -1

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

    function refresh() {
        statusProc.running = true;
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec >= 1048576) return (bytesPerSec / 1048576).toFixed(1) + " MB/s";
        return (bytesPerSec / 1024).toFixed(0) + " KB/s";
    }

    // Fast polling (throughput, full stats) only while the popup is open.
    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Slow polling so the bar icon's connection-type stays current even when closed.
    Timer {
        interval: 5000
        running: !root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: ["bash", "-c", "iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}'); if [ -z \"$iface\" ]; then echo TYPE=none; exit 0; fi; if [ -d \"/sys/class/net/$iface/wireless\" ]; then type=wifi; else type=ethernet; fi; ip=$(ip -4 -o addr show \"$iface\" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1); if [ \"$type\" = ethernet ]; then speed=$(cat /sys/class/net/$iface/speed 2>/dev/null); speed=\"${speed:-0} Mbps\"; ssid=\"\"; signal=\"\"; else ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '/^yes/ {print $2; exit}'); rate=$(nmcli -t -f active,rate dev wifi 2>/dev/null | awk -F: '/^yes/ {print $2; exit}'); signal=$(nmcli -t -f active,signal dev wifi 2>/dev/null | awk -F: '/^yes/ {print $2; exit}'); speed=\"$rate\"; fi; rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null); tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null); echo \"TYPE=$type\"; echo \"IFACE=$iface\"; echo \"IP=$ip\"; echo \"SPEED=$speed\"; echo \"SSID=$ssid\"; echo \"SIGNAL=$signal\"; echo \"RX=$rx\"; echo \"TX=$tx\""]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const fields = {};
                    for (const line of this.text.split("\n")) {
                        const idx = line.indexOf("=");
                        if (idx === -1) continue;
                        fields[line.slice(0, idx)] = line.slice(idx + 1);
                    }

                    root.connectionType = fields.TYPE || "none";

                    if (root.connectionType === "none") {
                        root.iface = "--";
                        root.ipAddress = "--";
                        root.speed = "--";
                        root.ssid = "";
                        root.signal_ = "";
                        root.prevRx = -1;
                        root.prevTx = -1;
                        return;
                    }

                    root.iface = fields.IFACE || "--";
                    root.ipAddress = fields.IP || "--";
                    root.speed = fields.SPEED || "--";
                    root.ssid = fields.SSID || "";
                    root.signal_ = fields.SIGNAL || "";

                    const rx = parseFloat(fields.RX);
                    const tx = parseFloat(fields.TX);
                    const now = Date.now();

                    if (root.prevRx >= 0 && root.prevSampleTime > 0) {
                        const dt = (now - root.prevSampleTime) / 1000;
                        if (dt > 0) {
                            root.downloadRate = root.formatRate((rx - root.prevRx) / dt);
                            root.uploadRate = root.formatRate((tx - root.prevTx) / dt);
                        }
                    }

                    root.prevRx = rx;
                    root.prevTx = tx;
                    root.prevSampleTime = now;
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
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    font.family: "Anthropic Mono Web"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#eaf4fa"
                    text: {
                        if (root.connectionType === "wifi") return "Wi-Fi";
                        if (root.connectionType === "ethernet") return "Ethernet";
                        return "Not Connected";
                    }
                }

                Text {
                    visible: root.connectionType !== "none"
                    font.pixelSize: 11
                    color: "#6f93a8"
                    text: root.connectionType === "wifi" && root.ssid ? root.ssid : root.iface
                }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: root.connectionType !== "none"
                implicitHeight: 1
                color: "#295ec1eb"
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: root.connectionType !== "none"
                spacing: 3

                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; font.pixelSize: 12; color: "#6f93a8"; text: "IP Address" }
                    Text { font.family: "Anthropic Mono Web"; font.pixelSize: 12; color: "#eaf4fa"; text: root.ipAddress }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: root.connectionType === "wifi" && root.signal_ !== ""
                    Text { Layout.fillWidth: true; font.pixelSize: 12; color: "#6f93a8"; text: "Signal" }
                    Text { font.family: "Anthropic Mono Web"; font.pixelSize: 12; color: "#eaf4fa"; text: root.signal_ + "%" }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; font.pixelSize: 12; color: "#6f93a8"; text: "Link Speed" }
                    Text { font.family: "Anthropic Mono Web"; font.pixelSize: 12; color: "#eaf4fa"; text: root.speed }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; font.pixelSize: 12; color: "#6f93a8"; text: "Download" }
                    Text { font.family: "Anthropic Mono Web"; font.pixelSize: 12; color: "#eaf4fa"; text: root.downloadRate }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; font.pixelSize: 12; color: "#6f93a8"; text: "Upload" }
                    Text { font.family: "Anthropic Mono Web"; font.pixelSize: 12; color: "#eaf4fa"; text: root.uploadRate }
                }
            }
        }
    }
}
