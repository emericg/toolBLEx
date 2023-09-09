import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.RangeSlider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            first.implicitHandleWidth + leftPadding + rightPadding,
                            second.implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             first.implicitHandleHeight + topPadding + bottomPadding,
                             second.implicitHandleHeight + topPadding + bottomPadding)

    padding: 4

    // settings
    property int hhh: 18
    property string unit
    property int tofixed: 0
    property bool kshort: false

    // colors
    property string colorBg: Theme.colorForeground
    property string colorFg: Theme.colorPrimary
    property string colorTxt: "white"

    ////////////////

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : hhh
        implicitHeight: control.horizontal ? hhh : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: hhh
        color: control.colorBg
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {
            x: control.horizontal ? control.first.handle.x : 0
            y: control.horizontal ? 0 : control.second.handle.y
            width: control.horizontal ? control.second.handle.x - control.first.handle.x + control.second.handle.width*0.66 : hhh
            height: control.horizontal ? hhh : control.first.handle.y - control.second.handle.y + control.second.handle.height*0.66

            radius: hhh
            color: control.colorFg
        }
    }

    ////////////////

    first.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
        implicitWidth: hhh
        implicitHeight: hhh

        width: control.horizontal ? t1.contentWidth + 16 : hhh
        height: hhh
        radius: hhh
        color: control.colorFg
        border.color: control.colorFg

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
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            color: control.colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////

    second.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        implicitWidth: hhh
        implicitHeight: hhh

        width: control.horizontal ? t2.contentWidth + 16 : hhh
        height: hhh
        radius: hhh
        color: control.colorFg
        border.color: control.colorFg

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
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            color: control.colorTxt
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////
}
