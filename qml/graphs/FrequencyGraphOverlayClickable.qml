import QtQuick

import ComponentLibrary

Item {
    id: overlayClickable

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: clickableGraphArea
        anchors.fill: parent

        property var lastMouse1: null
        property var lastMouse2: null

        acceptedButtons: (Qt.LeftButton | Qt.RightButton)

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

        ////////

        ClickableLine {
            id: group1
            color: Theme.colorYellow
        }

        ClickableLine {
            id: group2
            color: Theme.colorOrange
        }

        ClickableLine {
            id: barPeak
            color: Theme.colorRed

            visible: frequencyGraph.showPeak && (ubertooth.peakDbm > barPeak.floorDb)

            // keep in sync with FrequencyGraph axisRSSI
            property real floorDb: -100
            property real ceilDb: -20

            textFreq: qsTr("[peak: %1 MHz · %2 dBm]").arg(ubertooth.peakFreq).arg(ubertooth.peakDbm)

            posV: UtilsNumber.mapNumber_nocheck(ubertooth.peakFreq,
                                                ubertooth.freqMin, ubertooth.freqMax,
                                                0, overlayClickable.width).toFixed(0) - 1

            posH: UtilsNumber.mapNumber_nocheck(ubertooth.peakDbm,
                                                barPeak.ceilDb, barPeak.floorDb,
                                                0, overlayClickable.height).toFixed(0) - 1
        }

        ////////
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
            group1.posH = mouse.y
            group1.posV = mouse.x
            group1.textFreq = qsTr("freq: ") + freqtxt + " MHz"
            group1.textRSSI = "RSSI: " + rssitxt + " dB"
        } else if (idx === 2) {
            group2.visible = true
            group2.posH = mouse.y
            group2.posV = mouse.x
            group2.textFreq = qsTr("freq: ") + freqtxt + " MHz"
            group2.textRSSI = "RSSI: " + rssitxt + " dB"
        }
    }

    function resetIndicators() {
        group1.visible = false
        group2.visible = false
        clickableGraphArea.lastMouse1 = null
        clickableGraphArea.lastMouse2 = null
    }

    ////////////////////////////////////////////////////////////////////////////

    component ClickableLine: Item {
        id: control

        anchors.fill: parent

        visible: false

        property int thickness: 2
        property color color: Theme.colorPrimary

        property alias posH: h.y
        property alias posV: v.x

        property alias textFreq: lfreq.text
        property alias textRSSI: lrssi.text

        ////

        Rectangle {
            id: h
            anchors.left: parent.left
            anchors.right: parent.right
            height: control.thickness
            color: control.color
            opacity: 0.66
        }
        Rectangle {
            id: v
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: control.thickness
            color: control.color
            opacity: 0.66
        }
/*
        Rectangle { // dot marker
            anchors.horizontalCenter: v.horizontalCenter
            anchors.verticalCenter: h.verticalCenter
            width: 6
            height: 6
            radius: 6
            color: control.color
        }
*/
        ////

        Rectangle { // background
            anchors.fill: col
            anchors.margins: -4

            visible: true
            opacity: 0.08
            color: control.color
        }

        ////

        Column {
            id: col
            anchors.left: v.right
            anchors.leftMargin: 8
            anchors.bottom: h.top
            anchors.bottomMargin: 8

            Text {
                id: lfreq
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                color: control.color
            }
            Text {
                id: lrssi
                textFormat: Text.PlainText
                font.pixelSize: Theme.componentFontSize
                color: control.color
            }
        }

        ////
    }

    ////////////////////////////////////////////////////////////////////////////
}
