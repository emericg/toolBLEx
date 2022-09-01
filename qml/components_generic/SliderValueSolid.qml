import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.Slider {
    id: control
    implicitWidth: 200
    implicitHeight: 20
    padding: 4

    value: 0.5
    snapMode: T.RangeSlider.SnapAlways

    // settings
    property int hhh: 18
    property string unit
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
            visible: (handle.x > 4)
            width: (handle.x + (handle.width / 2))
            height: parent.height
            color: control.colorFg
            radius: hhh
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: hhh
        implicitHeight: hhh
        width: t1.width + 16

        radius: hhh
        color: control.colorFg
        border.color: control.colorFg
        opacity: control.pressed ? 1 : 1

        Text {
            id: t1
            height: hhh
            anchors.centerIn: parent

            text: {
                var vvalue = control.value
                if (control.unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(0)
                return ((control.kshort && control.value > 999) ? (vvalue / 1000) : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: true
            fontSizeMode: Text.VerticalFit
            font.pixelSize: isDesktop ? 12 : 13
            color: control.colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
