import QtQuick

import ComponentLibrary

Item {
    id: overlayFrequencyBands
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    // Frequency axis is vertical: freqMax at the top, freqMin at the bottom
    // (matches WaterfallGraph_QuickItem, which flips Y so the lowest freq bin is at the bottom)
    function freqToY(f) {
        return UtilsNumber.mapNumber_nocheck(f, ubertooth.freqMin, ubertooth.freqMax,
                                             overlayFrequencyBands.height, 0)
    }

    // Horizontal guide line at a given frequency, with an upright label
    component BandLine: Item {
        id: line

        property real freq: 0
        property string label: ""
        property color lineColor: Theme.colorBlue
        property bool active: true

        x: 0
        y: overlayFrequencyBands.freqToY(freq) - height / 2

        width: overlayFrequencyBands.width
        height: 2

        visible: active && (freq >= ubertooth.freqMin) && (freq <= ubertooth.freqMax)

        Rectangle {
            anchors.fill: parent
            color: line.lineColor
            opacity: 0.7
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter

            visible: (line.label.length > 0)
            text: line.label
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVerySmall
            color: "white"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Repeater { // wifi // 802.11 b/g/n
        model: 14
        BandLine {
            required property int index
            active: actionBar.wifi
            lineColor: Theme.colorGreen
            freq: (index === 13) ? 2484 : 2412 + index * 5
            label: "ch " + (index + 1)
        }
    }

    Repeater { // bluetooth // low energy
        model: 40
        BandLine {
            required property int index
            active: (actionBar.bluetooth && actionBar.bluetooth_lowenergy)
            freq: 2402 + index * 2
            // color advertising channels
            lineColor: (index === 0 || index === 12 || index === 39) ? Theme.colorYellow
                                                                     : Theme.colorBlue
            label: {
                if (index === 0) return "adv 37"
                if (index === 12) return "adv 38"
                if (index === 39) return "adv 39"
                return (index % 5 === 0) ? ("ch " + index) : ""
            }
        }
    }

    Repeater { // bluetooth // classic
        model: 79
        BandLine {
            required property int index
            active: (actionBar.bluetooth && actionBar.bluetooth_classic)
            lineColor: Theme.colorBlue
            freq: 2402 + index
            label: (index % 10 === 0) ? ("ch " + index) : ""
        }
    }

    Repeater { // zigbee // 802.15.4
        model: 16
        BandLine {
            required property int index
            active: actionBar.zigbee
            lineColor: Theme.colorYellow
            freq: 2405 + index * 5
            label: "ch " + (11 + index)
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
