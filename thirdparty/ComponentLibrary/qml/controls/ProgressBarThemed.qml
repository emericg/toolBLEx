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
        radius: control.radius
        color: control.colorBackground
        border.width: 1
        border.color: control.colorBorder
    }

    ////////////////

    contentItem: Item {
        width: control.width
        height: control.height

        Rectangle { // determinate progress
            width: control.visualPosition * control.width
            height: control.height
            color: control.colorForeground
            radius: control.radius

            visible: !control.indeterminate
        }

        Rectangle { // indeterminate progress
            width: control.width * 0.3
            height: control.height
            color: control.colorForeground
            radius: control.radius

            visible: control.indeterminate

            XAnimator on x {
                running: control.indeterminate && control.visible
                loops: Animation.Infinite
                from: -control.width * 0.3
                to: control.width
                duration: 1200
            }
        }

        layer.enabled: (control.radius > 0)
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
