import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.RangeSlider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            first.implicitHandleWidth + leftPadding + rightPadding,
                            second.implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             first.implicitHandleHeight + topPadding + bottomPadding,
                             second.implicitHandleHeight + topPadding + bottomPadding)

    padding: 0

    property int hhh: 18

    // settings
    property string unit
    property int floatprecision: 0
    property bool kshort: false
    property bool showvalue: true

    // colors
    property color colorBackground: Theme.colorForeground
    property color colorForeground: Theme.colorPrimary
    property color colorText: "white"

    ////////////////

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : control.hhh
        implicitHeight: control.horizontal ? control.hhh : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: control.hhh
        color: control.colorBackground
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {
            x: control.horizontal ? control.first.handle.x : 0
            y: control.horizontal ? 0 : control.second.handle.y
            width: control.horizontal ? control.second.handle.x - control.first.handle.x + control.second.handle.width*0.66 : control.hhh
            height: control.horizontal ? control.hhh : control.first.handle.y - control.second.handle.y + control.second.handle.height*0.80
            visible: (control.horizontal && width >= control.hhh) || (control.vertical && height >= control.hhh)

            radius: control.hhh
            color: control.colorForeground
        }
    }

    ////////////////

    first.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
        implicitWidth: control.hhh
        implicitHeight: control.hhh

        width: (control.horizontal && control.showvalue) ? t1.contentWidth + 16 : control.hhh
        height: control.hhh
        radius: control.hhh
        color: control.colorForeground
        border.color: control.colorForeground

        Text {
            id: t1
            height: control.hhh
            anchors.centerIn: parent
            visible: control.showvalue

            text: {
                var vvalue = first.value
                if (control.unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.floatprecision)
                return ((control.kshort && first.value > 999) ? (vvalue / 1000) : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: isDesktop ? 12 : 13
            fontSizeMode: Text.Fit
            minimumPixelSize: Theme.fontSizeContentVerySmall
            color: control.colorText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////

    second.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
        implicitWidth: control.hhh
        implicitHeight: control.hhh

        width: (control.horizontal && control.showvalue) ? t2.contentWidth + 16 : control.hhh
        height: control.hhh
        radius: control.hhh
        color: control.colorForeground
        border.color: control.colorForeground

        Text {
            id: t2
            height: control.hhh
            anchors.centerIn: parent
            visible: control.showvalue

            text: {
                var vvalue = second.value
                if (control.unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.floatprecision)
                return ((control.kshort && second.value > 999) ? (vvalue / 1000) : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: isDesktop ? 12 : 13
            fontSizeMode: Text.Fit
            minimumPixelSize: Theme.fontSizeContentVerySmall
            color: control.colorText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////
}
