import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Slider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding)

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
    property color colorForegroundDisabled: Qt.tint(Theme.colorPrimary, "#44eeeeee")
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
            x: control.horizontal ? ((control.visualPosition <= 0.5) ? handle.x : control.availableWidth / 2) : 0
            y: !control.horizontal ? ((control.visualPosition <= 0.5) ? handle.y : control.availableHeight / 2) : 0
            width: control.horizontal ? Math.abs((control.width / 2) - handle.x - ((control.visualPosition > 0.5) ? handle.width : 0)) : control.hhh
            height: !control.horizontal ? Math.abs((control.height / 2) - handle.y - ((control.visualPosition > 0.5) ? handle.height : 0)) : control.hhh
            visible: (control.horizontal && width >= control.hhh) || (control.vertical && height >= control.hhh)

            radius: control.hhh
            color: control.colorForeground
        }
    }

    ////////////////

    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        implicitWidth: control.hhh
        implicitHeight: control.hhh

        width: (control.horizontal && control.showvalue) ? t1.contentWidth + 16 : control.hhh
        height: control.hhh
        radius: control.hhh
        color: control.colorForeground
        border.color: control.colorForeground

        Text {
            id: t1
            width: control.hhh
            height: control.hhh
            anchors.centerIn: parent
            visible: control.showvalue

            text: {
                var vvalue = control.value
                if (control.unit === "°" && settingsManager.tempUnit === "F") vvalue = UtilsNumber.tempCelsiusToFahrenheit(vvalue)
                vvalue = vvalue.toFixed(control.floatprecision)
                return ((control.kshort && control.value > 999) ? (vvalue / 1000) : vvalue) + control.unit
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
