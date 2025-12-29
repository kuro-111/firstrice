import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls

PanelWindow {
    mask: Region {}
    color: "transparent"
    aboveWindows: true
    implicitHeight: 200
    implicitWidth: 100
    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
        left: true
        right: true
    }

    Item {
        id: jumpContainer

        property var jumpHeight: 100
        property var jumpDuration: 1000
        property var groundLevel: jumpContainer.height - bingus.height

        width: 200
        height: 300
        anchors.centerIn: parent

        Image {
            id: bingus

            source: Qt.resolvedUrl("../assets/bing.png")
            height: 50
            width: 50
            y: jumpContainer.groundLevel
            x: (parent.width - width) / 2
        }

        SequentialAnimation {
            id: jumpAnimation

            running: true
            loops: Animation.Infinite

            NumberAnimation {
                target: bingus
                property: "y"
                to: jumpContainer.groundLevel - jumpContainer.jumpHeight
                duration: jumpContainer.jumpDuration / 2
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: bingus
                property: "y"
                to: jumpContainer.groundLevel
                duration: jumpContainer.jumpDuration / 2
                easing.type: Easing.InQuad
            }
        }

        RotationAnimator {
            id: doAflip
            target: bingus
            from: 0
            to: 360
            duration: 400
        }

        Timer {
            interval: 2500
            running: true
            repeat: true
            onTriggered: {
                doAflip.start();
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Only jump if not already jumping
                if (!jumpAnimation.running)
                    jumpAnimation.start();
            }
        }
    }
}
