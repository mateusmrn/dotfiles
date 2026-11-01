import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

RowLayout {
    spacing: 10

    Image {
        Layout.alignment: Qt.AlignVCenter
        width: 16
        height: 16
        sourceSize: Qt.size(16, 16)

        property var sink: Pipewire.defaultAudioSink

        source: {
            if (!sink || !sink.ready || !sink.audio || sink.audio.muted)
                return "icons/volume-x.svg";
            const v = sink.audio.volume;
            if (v < 0.01) return "icons/volume.svg";
            if (v < 0.5) return "icons/volume-1.svg";
            return "icons/volume-2.svg";
        }

        TapHandler {
            onTapped: {
                const sink = Pipewire.defaultAudioSink;
                if (sink && sink.ready && sink.audio)
                    sink.audio.muted = !sink.audio.muted;
            }
        }
    }

    Rectangle {
        id: volTrack
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: 6
        radius: 3
        color: "#16324a"

        property var sink: Pipewire.defaultAudioSink
        property real level: (sink && sink.ready && sink.audio && !sink.audio.muted) ? sink.audio.volume : 0

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            radius: parent.radius
            width: parent.width * Math.min(1, volTrack.level)
            color: "#19b6ee"
        }

        Rectangle {
            width: 13
            height: 13
            radius: 7
            color: "#eaf4fa"
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width * Math.min(1, volTrack.level) - width / 2
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            preventStealing: true

            function applyAt(mx) {
                const ratio = Math.min(1, Math.max(0, mx / volTrack.width));
                const sink = Pipewire.defaultAudioSink;
                if (!sink || !sink.ready || !sink.audio) return;
                sink.audio.volume = ratio;
                if (ratio > 0) sink.audio.muted = false;
            }

            onPressed: (mouse) => applyAt(mouse.x)
            onPositionChanged: (mouse) => { if (pressed) applyAt(mouse.x); }
        }
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        font.family: "Anthropic Mono Web"
        font.pixelSize: 12
        color: "#6f93a8"

        property var sink: Pipewire.defaultAudioSink

        text: {
            if (!sink || !sink.ready || !sink.audio) return "--";
            if (sink.audio.muted) return "muted";
            return Math.round(sink.audio.volume * 100) + "%";
        }
    }
}
