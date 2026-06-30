import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    // icon
    property url source_top: "../../assets/maps/compass_top.svg"
    property url source_bottom: "../../assets/maps/compass_bottom.svg"
    property int sourceSize: UtilsNumber.alignTo(height * 0.8, 2)
    property int sourceRotation: 0

    // settings
    property int radius: width * 0.28
    property string hoverMode: "off" // available: off
    property string highlightMode: "off" // available: off

    // colors
    property color colorIcon: Theme.colorIcon
    property color colorNeedle: Theme.colorRed
    property color colorHighlight: Theme.colorComponent
    property color colorBorder: Theme.colorSeparator
    property color colorBackground: Theme.colorLowContrast

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle { // background_alpha_borders
            anchors.fill: parent
            anchors.margins: Theme.isPhone ? -2 : -3
            radius: control.radius
            color: control.colorBorder
            opacity: 0.66

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: "#66000000"
            }
        }
        Rectangle { // background
            anchors.fill: parent
            radius: control.radius
            color: control.colorBackground
        }

        Item {
            id: bglayer
            anchors.fill: parent
/*
            RippleThemed {
                anchors.fill: parent
                anchor: control

                clip: visible
                pressed: control.pressed
                active: enabled && (control.down || control.visualFocus || control.hovered)
                color: Qt.rgba(control.colorHighlight.r, control.colorHighlight.g, control.colorHighlight.b, 0.66)
            }
*/
            Rectangle { // button_bg
                anchors.fill: parent
                radius: control.radius
                color: control.colorHighlight
                opacity: control.hovered ? 0.66 : 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
            }

            layer.enabled: false // only if ripple is enabled
            layer.effect: MultiEffect {
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: bglayer.x
                        y: bglayer.y
                        width: bglayer.width
                        height: bglayer.height
                        radius: control.radius
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: Item {
        rotation: control.sourceRotation
        Behavior on rotation { RotationAnimation { duration: 333; direction: RotationAnimator.Shortest } }

        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            color: control.colorNeedle
            source: control.source_top
        }
        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            color: control.colorIcon
            source: control.source_bottom
        }
    }

    ////////////////
}
