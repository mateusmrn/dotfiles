import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

PopupWindow {
    id: root

    property var panelWindow
    property var anchorItem

    color: "transparent"
    implicitWidth: 236
    implicitHeight: volumeColumn.implicitHeight + 24

    onVisibleChanged: if (!visible) {
        outputSelector.listOpen = false;
        inputSelector.listOpen = false;
    }

    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.audio && (n.isSink || (n.type & PwNodeType.Source) !== 0) && !n.isStream)
    }

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

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: "#e011293c"
        border.width: 1
        border.color: "#295ec1eb"

        ColumnLayout {
            id: volumeColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            VolumeSlider {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#295ec1eb"
            }

            AudioDeviceSelector {
                id: outputSelector
                Layout.fillWidth: true
                iconSource: "icons/headphones.svg"
                currentNode: Pipewire.defaultAudioSink
                currentLabel: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.ready)
                    ? (Pipewire.defaultAudioSink.description || Pipewire.defaultAudioSink.nickname || Pipewire.defaultAudioSink.name)
                    : "--"
                devices: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
                onDeviceSelected: (node) => Pipewire.preferredDefaultAudioSink = node
            }

            AudioDeviceSelector {
                id: inputSelector
                Layout.fillWidth: true
                iconSource: "icons/mic.svg"
                currentNode: Pipewire.defaultAudioSource
                currentLabel: (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.ready)
                    ? (Pipewire.defaultAudioSource.description || Pipewire.defaultAudioSource.nickname || Pipewire.defaultAudioSource.name)
                    : "--"
                devices: Pipewire.nodes.values.filter(n => n.audio && (n.type & PwNodeType.Source) !== 0 && !n.isStream)
                onDeviceSelected: (node) => Pipewire.preferredDefaultAudioSource = node
            }
        }
    }
}
