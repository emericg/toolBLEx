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

    padding: 6

    // settings
    property int hhh: 22
    property string unit
    property int floatprecision: 0

    // colors
    property color colorBackground: Theme.colorComponentBackground
    property color colorForeground: Theme.colorPrimary
    property color colorText: "white"

    ////////////////

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : 4
        implicitHeight: control.horizontal ? 4 : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: 2
        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {
            x: control.horizontal ? control.first.position * parent.width + 3 : -1
            y: control.horizontal ? -1 : control.second.visualPosition * parent.height + 3
            width: control.horizontal ? control.second.position * parent.width - control.first.position * parent.width - 6 : 6
            height: control.horizontal ? 6 : control.second.position * parent.height - control.first.position * parent.height - 6

            radius: 2
            color: control.colorForeground
        }
    }

    ////////////////

    first.handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))

        implicitWidth: 22
        implicitHeight: 22
        width: t1.width + 16
        radius: 6

        opacity: control.enabled ? 1 : 0.8
        color: first.pressed ? Theme.colorSecondary : control.colorForeground
        border.width: 1
        border.color: control.colorForeground

        Text {
            id: t1
            height: control.hhh
            anchors.centerIn: parent
            //anchors.verticalCenter: parent.verticalCenter
            //anchors.verticalCenterOffset: 1
            //anchors.horizontalCenter: parent.horizontalCenter

            text: {
                var vvalue = first.value
                if (unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.floatprecision)
                return ((first.value > 999) ? vvalue / 1000 : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: false
            font.pixelSize: Theme.fontSizeContentVerySmall
            //fontSizeMode: Text.Fit
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
        width: t2.width + 16

        radius: 6
        color: control.colorForeground
        border.color: control.colorForeground
        opacity: second.pressed ? 0.9 : 1

        Text {
            id: t2
            height: control.hhh
            anchors.centerIn: parent
            //anchors.verticalCenter: parent.verticalCenter
            //anchors.verticalCenterOffset: 1
            //anchors.horizontalCenter: parent.horizontalCenter

            text: {
                var vvalue = second.value
                if (unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.floatprecision)
                return ((second.value > 999) ? vvalue / 1000 : vvalue) + control.unit
            }
            textFormat: Text.PlainText
            font.bold: false
            font.pixelSize: Theme.fontSizeContentVerySmall
            //fontSizeMode: Text.Fit
            minimumPixelSize: Theme.fontSizeContentVerySmall
            color: control.colorText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////
}
