import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.RangeSlider {
    id: control
    implicitWidth: 200
    implicitHeight: 20

    padding: 4

    first.value: 0.25
    second.value: 0.75
    snapMode: T.RangeSlider.SnapAlways

    // settings
    property int hhh: 18
    property string unit
    property int tofixed: 0
    property bool kshort: false

    // colors
    property string colorBg: Theme.colorForeground
    property string colorFg: Theme.colorPrimary
    property string colorTxt: "white"

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth

        height: hhh
        radius: hhh
        opacity: 1
        color: control.colorBg

        Rectangle {
            x: (first.handle.x)
            width: ((second.handle.x + (second.handle.width / 2)) - x)
            height: parent.height
            radius: hhh
            color: control.colorFg
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    first.handle: Rectangle {
        x: control.leftPadding + first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: hhh
        implicitHeight: hhh
        width: t1.width + 16

        radius: hhh
        color: control.colorFg
        border.color: control.colorFg
        opacity: first.pressed ? 1 : 1

        Text {
            id: t1
            height: hhh
            anchors.centerIn: parent

            text: {
                var vvalue = first.value
                if (control.unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.tofixed)
                return ((control.kshort && first.value > 999) ? (vvalue / 1000) : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: isDesktop ? 12 : 13
            fontSizeMode: Text.VerticalFit
            color: control.colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    second.handle: Rectangle {
        x: control.leftPadding + second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: hhh
        implicitHeight: hhh
        width: t2.width + 16

        radius: hhh
        color: control.colorFg
        border.color: control.colorFg
        opacity: second.pressed ? 1 : 1

        Text {
            id: t2
            height: hhh
            anchors.centerIn: parent

            text: {
                var vvalue = second.value
                if (control.unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.tofixed)
                return ((control.kshort && second.value > 999) ? (vvalue / 1000) : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: isDesktop ? 12 : 13
            fontSizeMode: Text.VerticalFit
            color: control.colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
