import QtQuick
import QtQuick.Layouts

ColumnLayout {
    property string label: ""
    property string value: ""
    property real percent: 0
    property string device: ""

    spacing: 5

    RowLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            font.family: "Anthropic Mono Web"
            font.pixelSize: 12
            color: "#eaf4fa"
            text: label
        }

        Text {
            font.family: "Anthropic Mono Web"
            font.pixelSize: 12
            color: "#6f93a8"
            text: value
        }
    }

    Text {
        visible: device.length > 0
        font.pixelSize: 10
        color: "#6f93a8"
        opacity: 0.75
        text: device
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 5
        radius: 999
        color: "#16324a"

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            radius: parent.radius
            width: parent.width * Math.min(1, Math.max(0, percent / 100))
            color: "#19b6ee"
        }
    }
}
