import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

T.ProgressBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    property color colorBackground: Theme.colorComponentBackground
    property color colorForeground: Theme.colorPrimary
    property color colorBorder: Theme.colorComponentBorder

    property int radius: Theme.componentRadius

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 12
        y: (control.height - height) / 2
        radius: control.radius
        color: control.colorBackground
        border.width: 1
        border.color: control.colorBorder
    }

    ////////////////

    contentItem: Item {
        width: control.width
        height: control.height

        Rectangle {
            width: control.visualPosition * control.width
            height: control.height
            color: control.colorForeground
            radius: control.radius
        }

        layer.enabled: (control.roundedradius > 0)
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: false
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    width: control.width
                    height: control.height
                    radius: control.radius
                }
            }
        }
    }

    ////////////////
}
