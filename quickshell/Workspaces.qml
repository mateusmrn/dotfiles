import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 4

    function sortedWorkspaces() {
        const list = Hyprland.workspaces.values.slice();
        list.sort((a, b) => a.id - b.id);
        return list;
    }

    Repeater {
        model: root.sortedWorkspaces()

        Rectangle {
            required property var modelData

            width: 22
            height: 22
            radius: 7
            color: modelData.active ? "#19b6ee" : "transparent"

            Text {
                anchors.centerIn: parent
                text: modelData.id
                font.pixelSize: 12
                font.family: "Anthropic Mono Web"
                color: modelData.active ? "#06202c" : "#6f93a8"
            }

            TapHandler {
                onTapped: modelData.activate()
            }
        }
    }
}
