import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    spacing: 8

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        color: "#eaf4fa"
        font.family: "Anthropic Mono Web"
        font.pixelSize: 15
        text: Qt.formatDateTime(clock.date, "hh:mm")
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        color: "#6f93a8"
        font.family: "Anthropic Mono Web"
        font.pixelSize: 12
        text: Qt.formatDateTime(clock.date, "ddd, MMM d")
    }
}
