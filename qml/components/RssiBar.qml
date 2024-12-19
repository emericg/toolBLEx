import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

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

    property color colorBackground: (Theme.currentTheme === Theme.THEME_DESKTOP_LIGHT) ? "#ccffffff" : "#cc333333"
    property color colorForeground: Theme.colorPrimary

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
            width: ((100-Math.abs(value)) / 100) * control.width
            height: control.height
            radius: (Theme.componentRadius / 2)
            color: control.colorForeground
            opacity: 0.4
        }
    }
}
