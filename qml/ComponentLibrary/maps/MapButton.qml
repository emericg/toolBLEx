import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    // image
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // settings
    property int radius: width * 0.28
    property string hoverMode: "off" // available: off
    property string highlightMode: "off" // available: off

    // colors
    property string iconColor: Theme.colorIcon
    property string highlightColor: Theme.colorPrimary
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
/*
        RippleThemed {
            width: parent.width
            height: parent.height

            clip: visible
            anchor: control
            pressed: control.pressed
            active: enabled && (control.down || control.visualFocus || control.hovered)
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.9)
        }
*/
    }

    ////////////////

    contentItem: Item {
        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            color: control.iconColor
            source: control.source
            rotation: control.sourceRotation
        }
    }

    ////////////////
}
