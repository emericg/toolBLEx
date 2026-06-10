import QtQuick

import ComponentLibrary

Item {
    id: overlayFrequencyBands

    ////////////////////////////////////////////////////////////////////////////

    Repeater { // wifi // 802.11 b/g/n
        model: 14
        BandLine {
            required property int index
            active: actionBar.wifi
            color: Theme.colorGreen
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
            color: (index === 0 || index === 12 || index === 39) ? Theme.colorYellow : Theme.colorBlue
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
            color: Theme.colorBlue
            freq: 2402 + index
            label: (index % 10 === 0) ? ("ch " + index) : ""
        }
    }

    Repeater { // zigbee // 802.15.4
        model: 16
        BandLine {
            required property int index
            active: actionBar.zigbee
            color: Theme.colorYellow
            freq: 2405 + index * 5
            label: "ch " + (11 + index)
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    component BandLine: Item {
        id: control

        property bool active: true

        property real freq: 0
        property string label
        property int thickness: 2
        property color color: Theme.colorBlue

        function freqToY(f) {
            return UtilsNumber.mapNumber_nocheck(f, dataSource.freqMin, dataSource.freqMax,
                                                 overlayFrequencyBands.height, 0)
        }

        x: 0
        y: freqToY(freq) - (height / thickness)

        width: overlayFrequencyBands.width
        height: thickness

        visible: active && (freq >= dataSource.freqMin) && (freq <= dataSource.freqMax)

        Rectangle { // Horizontal guide line at a given frequency
            anchors.fill: parent
            color: control.color
            opacity: 0.5
        }

        Text { // Label
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter

            visible: (control.label.length > 0)
            text: control.label
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVerySmall
            color: "white"
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
