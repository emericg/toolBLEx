import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Frame {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12
    leftPadding: 16
    rightPadding: 16

    // settings
    property int radius: height * 0.28

    // colors
    property string borderColor: Theme.colorSeparator
    property string backgroundColor: Theme.colorLowContrast

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle { // background_alpha_borders
            anchors.fill: parent
            anchors.margins: isPhone ? -2 : -3
            radius: control.radius
            color: control.borderColor
            opacity: 0.66

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: Theme.colorBoxShadow
            }
        }
        Rectangle { // background
            anchors.fill: parent
            radius: control.radius
            color: control.backgroundColor
        }
    }

    ////////////////
}
