import QtQuick
import QtQuick.Window

import ComponentLibrary

Item {
    id: control

    width: contentRow.width
    height: 20
    z: 100

    property int frameCounter: 0
    property int frameCounterAvg: 0
    property int counter: 0
    property int fps: 0
    property int fpsAvg: 0

    ////////

    Rectangle {
        anchors.fill: contentRow
        color: "black"
        opacity: 0.33
    }

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            color: "white"
            source: "qrc:/IconLibrary/material-symbols/autorenew.svg"

            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
            onRotationChanged: frameCounter++

            Timer {
                interval: 2000
                repeat: true
                running: true
                onTriggered: {
                    frameCounterAvg += frameCounter
                    control.fps = frameCounter / 2
                    counter++
                    frameCounter = 0
                    if (counter >= 3) {
                        control.fpsAvg = frameCounterAvg / (2*counter)
                        frameCounterAvg = 0
                        counter = 0
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            color: "#c0c0c0"
            font.pixelSize: 16
            textFormat: Text.PlainText
            text: {
                var txt = ""
                if (utilsFpsMonitor) {
                    // FPS from utilsFpsMonitor
                    txt += utilsFpsMonitor.fps + " fps"
                } else {
                    // FPS from the UI animation
                    txt += "Ø " + control.fpsAvg
                    if (txt.length) txt += " | "
                    txt += control.fps + " fps"
                }
                return txt
            }
        }
    }

    ////////
}
