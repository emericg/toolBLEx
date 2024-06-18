import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.ProgressBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    property color colorBackground: Theme.colorComponentBackground
    property color colorForeground: Theme.colorPrimary

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 12
        y: (control.height - height) / 2
        color: control.colorBackground
    }

    ////////////////

    contentItem: Item {
        Rectangle {
            width: control.visualPosition * control.width
            height: control.height
            color: control.colorForeground
        }
    }

    ////////////////

    layer.enabled: true
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
                radius: Theme.componentRadius
            }
        }
    }

    ////////////////
}
