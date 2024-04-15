import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12

    focusPolicy: Qt.NoFocus

    // colors
    property color colorPrimary: Theme.colorPrimary

    ////////////////

    background: Item {
        implicitWidth: 80
        implicitHeight: 48

        RippleThemed {
            width: parent.width
            height: parent.height

            anchor: control
            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: Qt.rgba(control.colorPrimary.r, control.colorPrimary.g, control.colorPrimary.b, 0.1)

            layer.enabled: true
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
                        radius: 8
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font.bold: false
        font.pixelSize: Theme.componentFontSize
        font.capitalization: Font.AllUppercase

        elide: Text.ElideMiddle
        //wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: control.colorPrimary
        opacity: control.enabled ? 1 : 0.66
    }

    ////////////////
}
