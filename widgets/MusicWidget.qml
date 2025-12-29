import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell
import Quickshell.Services.Mpris

PopupWindow {
    id: musicPopup

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

    // 2. DEBUGGING: Check raw data on load
    Component.onCompleted: {
        console.log("Debug: Checking Players...");
        console.log(Mpris.players.values.length);

        if (Mpris.players.values.length === 0) {
            console.log("Debug: Mpris.players list is EMPTY.");
            console.log("Debug: Please run 'playerctl -l' in your terminal to verify system visibility.");
        } else {
            console.log("Length" + Mpris.players.values.length);
            for (var i = 0; i < Mpris.players.values.length; i++) {
                // Print specific ID of each player found
                console.log("Debug: Found player -> " + Mpris.players.values[i].identity);
            }
        }
    }

    width: Screen.width
    height: Screen.height

    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            musicPopup.visible = false;
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

                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    color: "#45475a"
                    radius: 2

                    Rectangle {
                        height: parent.height
                        // Calculate width percentage based on song position
                        width: (activePlayer && activePlayer.length > 0) ? (parent.width * (activePlayer.position / activePlayer.length)) : 0
                        color: "#cba6f7"
                        radius: 2
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
