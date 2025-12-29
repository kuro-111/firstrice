import QtQuick
import Quickshell

PanelWindow {
    id: floatingMusicButton
    color: "transparent"
    mask: buttonRect
    aboveWindows: false

    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 20
        right: 20
    }

    implicitWidth: 50
    implicitHeight: 50

    Rectangle {
        id: buttonRect
        anchors.fill: parent
        radius: 25
        color: "#cba6f7"

        Text {
            anchors.centerIn: parent
            text: "🎵"
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                musicWidget.visible = !musicWidget.visible;
            }
        }
    }

    MusicWidget {
        id: musicWidget
        visible: false

        anchor {
            window: floatingMusicButton
        }
    }
}
