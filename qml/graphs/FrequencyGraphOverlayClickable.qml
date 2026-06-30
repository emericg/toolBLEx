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
                    leftMarker.visible = false
                } else {
                    lastMouse1 = Qt.point(mouse.x, mouse.y)
                    lastMouse2 = null
                    moveIndicator(mouse, 1)
                }
            } else if (mouse.button === Qt.RightButton) {
                if (lastMouse2 && lastMouse2 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse2 = null
                    rightMarker.visible = false
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

        ClickableMarker {
            id: leftMarker
            color: Theme.colorYellow
            freqUnit: dataSource.freqUnit
        }

        ClickableMarker {
            id: rightMarker
            color: Theme.colorOrange
            freqUnit: dataSource.freqUnit
        }

        ClickableMarker {
            id: barPeak
            color: Theme.colorRed
            freqUnit: dataSource.freqUnit

            visible: spectrumGraph2D_container.showPeak && (dataSource.peakDbm > actionBar.minRSSI)

            textFreq: {
                var freq = dataSource.peakFreq
                if (freqUnit === 1) freq = (freq / 1000).toFixed(1)
                qsTr("[peak: %1 MHz · %2 dBm]").arg(freq).arg(dataSource.peakDbm)
            }

            posX: UtilsNumber.mapNumber(dataSource.peakFreq,
                                        dataSource.freqMin, dataSource.freqMax,
                                        0, overlayClickable.width).toFixed(0) - 1

            posY: UtilsNumber.mapNumber(dataSource.peakDbm,
                                        actionBar.maxRSSI, actionBar.minRSSI,
                                        0, overlayClickable.height).toFixed(0) - 1
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    function hasIndicators() {
        return (leftMarker.visible || rightMarker.visible)
    }

    function moveIndicator(mouse, idx) {
        var freqtxt = UtilsNumber.mapNumber(mouse.x, 0, overlayClickable.width, dataSource.freqMin, dataSource.freqMax).toFixed(0)
        var rssitxt = UtilsNumber.mapNumber(mouse.y, 0, overlayClickable.height, -20, -100).toFixed(0)

        if (idx === 1) {
            leftMarker.visible = true
            leftMarker.posY = mouse.y
            leftMarker.posX = mouse.x
            if (leftMarker.freqUnit === 0) leftMarker.textFreq = qsTr("freq: ") + freqtxt + " MHz"
            else leftMarker.textFreq = qsTr("freq: ") + (freqtxt / 1000).toFixed(1) + " MHz"
            leftMarker.textRSSI = "RSSI: " + rssitxt + " dB"
        } else if (idx === 2) {
            rightMarker.visible = true
            rightMarker.posY = mouse.y
            rightMarker.posX = mouse.x
            if (leftMarker.freqUnit === 0) rightMarker.textFreq = qsTr("freq: ") + freqtxt + " MHz"
            else rightMarker.textFreq = qsTr("freq: ") + (freqtxt / 1000).toFixed(1) + " MHz"
            rightMarker.textRSSI = "RSSI: " + rssitxt + " dB"
        }
    }

    function resetIndicators() {
        leftMarker.visible = false
        rightMarker.visible = false
        clickableGraphArea.lastMouse1 = null
        clickableGraphArea.lastMouse2 = null
    }

    ////////////////////////////////////////////////////////////////////////////

    component ClickableMarker: Item {
        id: control

        anchors.fill: parent

        visible: false

        property color color: Theme.colorPrimary
        property int thickness: 2
        property int freqUnit: 0

        property alias posX: v.x
        property alias posY: h.y

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
            anchors.fill: columnContent
            anchors.margins: -4

            visible: true
            opacity: 0.1
            color: control.color
        }

        ////

        Column {
            id: columnContent

            anchors.left: v.right
            anchors.leftMargin: (posX > (control.width / 2)) ? - width - 8 - 2 : 8
            anchors.bottom: h.bottom
            anchors.bottomMargin: (posY < (control.height / 2)) ? - height - 8 - 2 : 8

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
