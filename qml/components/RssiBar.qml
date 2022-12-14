import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

// https://www.sonicwall.com/fr-fr/support/knowledge-base/wireless-snr-rssi-and-noise-basics-of-wireless-troubleshooting/180314090744170/
//
// measured in decibels from 0 (zero) to -120 (minus 120)
// RSSI < -90 dBm   this signal is extremely weak, at the edge of what a receiver can receive
// RSSI -67dBm      this is a fairly strong signal
// RSSI > -55dBm    this is a very strong signal
// RSSI > -30dBm    your sniffer is sitting right next to the transmitter

T.ProgressBar {
    id: control
    implicitWidth: 200
    implicitHeight: 16

    from: -100
    to: 0

    value: 0
    property real value2: 0

    property string colorBackground: "transparent"
    property string colorForeground: Theme.colorPrimary

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 12

        radius: (Theme.componentRadius / 2)
        color: control.colorBackground
        border.width: 1
        border.color: control.colorForeground
    }

    contentItem: Item {
        Rectangle { // max
            width: ((100-Math.abs(value2)) / 100) * control.width
            height: control.height
            radius: (Theme.componentRadius / 2)
            color: control.colorForeground
            opacity: 0.4
        }
        Rectangle { // mean
            //width: control.visualPosition * control.width
            width: ((100-Math.abs(value)) / 100) * control.width
            height: control.height
            radius: (Theme.componentRadius / 2)
            color: control.colorForeground
            opacity: 0.4
        }
    }
}
