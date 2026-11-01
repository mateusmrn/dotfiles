import QtQuick
import Quickshell.Services.Pipewire

Rectangle {
    id: root

    property bool active: false
    signal clicked()

    implicitWidth: volumeRow.implicitWidth + 18
    implicitHeight: volumeRow.implicitHeight + 10
    radius: 9
    color: (hoverHandler.hovered || root.active) ? "#16324a" : "transparent"

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6

        Image {
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            sourceSize: Qt.size(14, 14)

            property var sink: Pipewire.defaultAudioSink

            source: {
                if (!sink || !sink.ready || !sink.audio || sink.audio.muted)
                    return "icons/volume-x.svg";
                const v = sink.audio.volume;
                if (v < 0.01) return "icons/volume.svg";
                if (v < 0.5) return "icons/volume-1.svg";
                return "icons/volume-2.svg";
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Anthropic Mono Web"
            font.pixelSize: 12
            color: "#eaf4fa"

            property var sink: Pipewire.defaultAudioSink

            text: {
                if (!sink || !sink.ready || !sink.audio) return "--";
                if (sink.audio.muted) return "muted";
                return Math.round(sink.audio.volume * 100) + "%";
            }
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
