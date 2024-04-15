import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

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
            y: control.horizontal ? 0 : handle.y
            width: control.horizontal ? Math.max(control.position * parent.width, handle.x + handle.width*0.66) : control.hhh
            height: control.horizontal ? control.hhh : parent.height - handle.y

            radius: control.hhh
            color: control.colorForeground
        }

        layer.enabled: control.horizontal
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: false
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
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
