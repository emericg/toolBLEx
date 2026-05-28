import QtQuick

import ComponentLibrary

Item {
    id: control

    width: contentRow.width
    height: 20
    z: 100

    property int fps: 0
    property int fpsAvg: 0

    ////////

    Rectangle {
        anchors.fill: contentRow
        color: "black"
        opacity: 0.33
    }

    ////////

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 4
        rightPadding: 4

        ////

        IconSvg {
            id: fpsAnimation
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            color: "white"
            source: "qrc:/IconLibrary/material-symbols/autorenew.svg"

            property int frameCounter: 0
            property int frameCounterAvg: 0
            property int counter: 0

            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
            onRotationChanged: fpsAnimation.frameCounter++

            Timer {
                interval: 2000
                repeat: true
                running: (typeof utilsFpsMonitor === "undefined" || !utilsFpsMonitor)

                onTriggered: {
                    fpsAnimation.frameCounterAvg += fpsAnimation.frameCounter
                    control.fps = fpsAnimation.frameCounter / 2
                    fpsAnimation.counter++
                    fpsAnimation.frameCounter = 0
                    if (fpsAnimation.counter >= 3) {
                        control.fpsAvg = fpsAnimation.frameCounterAvg / (2*fpsAnimation.counter)
                        fpsAnimation.frameCounterAvg = 0
                        fpsAnimation.counter = 0
                    }
                }
            }
        }

        ////

        Text {
            anchors.verticalCenter: parent.verticalCenter

            color: "#c0c0c0"
            font.pixelSize: 16
            textFormat: Text.PlainText
            text: {
                var txt = ""
                if (typeof utilsFpsMonitor !== "undefined" && utilsFpsMonitor) {
                    // FPS from utilsFpsMonitor
                    txt += utilsFpsMonitor.fps + " FPS"
                } else {
                    // FPS from the UI animation
                    //txt += "Ø " + control.fpsAvg
                    if (txt.length) txt += " | "
                    txt += control.fps + " FPS"
                }
                return txt
            }
        }

        ////
    }

    ////////
}
