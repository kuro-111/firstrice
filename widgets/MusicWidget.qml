import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell
import Quickshell.Services.Mpris
import qs.components.controls

PopupWindow {
    id: musicPopup

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"

    function getActivePlayer() {
        for (var i = 0; i < Mpris.players.values.length; i++) {
            if (Mpris.players.values[i].playbackState === MprisPlaybackState.Playing) {
                return Mpris.players.values[i];
            }
        }

        // 3. Fallback
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }

    // Bind the property to the function
    property var activePlayer: getActivePlayer()
    property real playerProgress: {
        const active = activePlayer;
        return active?.length ? active.position / active.length : 0;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Instead of closing immediately, start the exit animation
            exitAnimation.start();
        }
    }

    Rectangle {
        id: card
        width: 300
        height: 150
        color: "#1e1e2e"
        radius: 12
        border.color: "#cba6f7"
        border.width: 2

        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 20
            bottomMargin: 80 // Push it up above the button (50px button + 30px gap)
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true // Optional: allows hover effects
            onClicked: {
                // Do nothing, just consume the event so it doesn't pass to the background
            }
        }

        transformOrigin: Item.BottomRight
        scale: 0 // Start hidden (scale 0)

        Connections {
            target: musicPopup
            function onVisibleChanged() {
                if (musicPopup.visible) {
                    card.scale = 0; // Reset scale
                    enterAnimation.start();
                }
            }
        }

        NumberAnimation {
            id: enterAnimation
            target: card
            property: "scale"
            from: 0.0
            to: 1.0
            duration: 350
            easing.type: Easing.OutBack // The "Pop" effect
            easing.overshoot: 1.2
        }

        NumberAnimation {
            id: exitAnimation
            target: card
            property: "scale"
            from: 1.0
            to: 0.0
            duration: 300
            easing.type: Easing.InBack // The "Anticipation" pull effect

            onFinished: {
                musicPopup.visible = false;
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            AnimatedImage {
                Layout.preferredHeight: 80
                Layout.preferredWidth: 80
                source: "../assets/bongo_cat.gif"
                playing: (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing)
                fillMode: Image.PreserveAspectFit
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "No Music Playing"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""
                    color: "#a6adc8"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                StyledSlider {
                    id: slider

                    enabled: !!activePlayer
                    implicitWidth: parent.width
                    implicitHeight: 10

                    onMoved: {
                        const active = activePlayer;
                        if (active?.canSeek && active?.positionSupported)
                            active.position = value * active.length;
                    }

                    Binding {
                        target: slider
                        property: "value"
                        value: musicPopup.playerProgress
                        when: !slider.pressed
                    }

                    CustomMouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton

                        function onWheel(event: WheelEvent) {
                            const active = activePlayer;
                            if (!active?.canSeek || !active?.positionSupported)
                                return;

                            event.accepted = true;
                            const delta = event.angleDelta.y > 0 ? 10 : -10;    // Time 10 seconds
                            Qt.callLater(() => {
                                active.position = Math.max(0, Math.min(active.length, active.position + delta));
                            });
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8

                    Button {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        text: "⏮"

                        onClicked: {
                            if (activePlayer && activePlayer.canGoPrevious) {
                                activePlayer.previous();
                            }
                        }
                        // Basic styling for the button
                        background: Rectangle {
                            color: parent.down ? "#45475a" : "#313244"
                            radius: 5
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) ? "⏸" : "▶"

                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        onClicked: {
                            if (activePlayer) {
                                activePlayer.togglePlaying();
                            }
                        }

                        // Basic styling for the button
                        background: Rectangle {
                            color: parent.down ? "#45475a" : "#313244"
                            radius: 5
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "⏭"

                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        onClicked: {
                            if (activePlayer && activePlayer.canGoNext) {
                                activePlayer.next();
                            }
                        }

                        // Basic styling for the button
                        background: Rectangle {
                            color: parent.down ? "#45475a" : "#313244"
                            radius: 5
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
