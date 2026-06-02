import QtQuick

import ComponentLibrary

Item {
    id: overlayClickable

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: clickableGraphArea
        anchors.fill: parent

        acceptedButtons: (Qt.LeftButton | Qt.RightButton)

        property var lastMouse1: null
        property var lastMouse2: null

        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (lastMouse1 && lastMouse1 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse1 = null
                    group1.visible = false
                } else {
                    lastMouse1 = Qt.point(mouse.x, mouse.y)
                    lastMouse2 = null
                    moveIndicator(mouse, 1)
                }
            } else if (mouse.button === Qt.RightButton) {
                if (lastMouse2 && lastMouse2 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse2 = null
                    group2.visible = false
                } else {
                    lastMouse1 = null
                    lastMouse2 = Qt.point(mouse.x, mouse.y)
                    moveIndicator(mouse, 2)
                }
            }
        }
        onPositionChanged: (mouse) => {
           if (lastMouse1) {
               moveIndicator(mouse, 1)
            } else if (lastMouse2) {
               moveIndicator(mouse, 2)
            }
        }

        ////

        Item {
            id: group1
            anchors.fill: parent
            visible: false

            Rectangle {
                id: h1
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.colorYellow
            }
            Rectangle {
                id: v1
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2
                color: Theme.colorYellow
            }

            Column {
                anchors.left: v1.right
                anchors.leftMargin: 8
                anchors.bottom: h1.top
                anchors.bottomMargin: 8

                Text {
                    id: lfreq1
                    text: "freq: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorYellow
                }
                Text {
                    id: lrssi1
                    text: "rssi: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorYellow
                }
            }
        }

        ////

        Item {
            id: group2
            anchors.fill: parent
            visible: false

            Rectangle {
                id: h2
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.colorOrange
            }
            Rectangle {
                id: v2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2
                color: Theme.colorOrange
            }

            Column {
                anchors.left: v2.right
                anchors.leftMargin: 8
                anchors.bottom: h2.top
                anchors.bottomMargin: 8

                Text {
                    id: lfreq2
                    text: "freq: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorOrange
                }
                Text {
                    id: lrssi2
                    text: "rssi: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorOrange
                }
            }
        }

        ////
    }

    ////////////////////////////////////////////////////////////////////////////

    function hasIndicators() {
        return (group1.visible || group2.visible)
    }

    function moveIndicator(mouse, idx) {
        var freqtxt = UtilsNumber.mapNumber(mouse.x, 0, overlayClickable.width, ubertooth.freqMin, ubertooth.freqMax).toFixed(0)
        var rssitxt = UtilsNumber.mapNumber(mouse.y, 0, overlayClickable.height, -20, -100).toFixed(0)

        if (idx === 1) {
            group1.visible = true
            h1.y = mouse.y
            v1.x = mouse.x
            lfreq1.text = "freq: " + freqtxt + " MHz"
            lrssi1.text = "rssi: " + rssitxt + " dB"
        } else if (idx === 2) {
            group2.visible = true
            h2.y = mouse.y
            v2.x = mouse.x
            lfreq2.text = "freq: " + freqtxt + " MHz"
            lrssi2.text = "rssi: " + rssitxt + " dB"
        }
    }

    function resetIndicators() {
        group1.visible = false
        group2.visible = false
        clickableGraphArea.lastMouse1 = null
        clickableGraphArea.lastMouse2 = null
    }

    ////////////////////////////////////////////////////////////////////////////
}
