import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    // image
    property url source_top: "qrc:/gfx/compass_top.svg"
    property url source_bottom: "qrc:/gfx/compass_bottom.svg"
    property int sourceSize: UtilsNumber.alignTo(height * 0.8, 2)
    property int sourceRotation: 0

    // settings
    property int radius: width * 0.28
    property string hoverMode: "off" // available: off
    property string highlightMode: "off" // available: off

    // colors
    property color iconColor: Theme.colorIcon
    property color highlightColor: Theme.colorComponent
    property color borderColor: Theme.colorSeparator
    property color backgroundColor: Theme.colorLowContrast

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
                shadowColor: "#66000000"
            }
        }
        Rectangle { // background
            anchors.fill: parent
            radius: control.radius
            color: control.backgroundColor
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
                color: Qt.rgba(control.highlightColor.r, control.highlightColor.g, control.highlightColor.b, 0.66)
            }
*/
            Rectangle { // button_bg
                anchors.fill: parent
                color: control.highlightColor
                opacity: control.hovered ? 0.66 : 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
            }

            layer.enabled: true
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
        Behavior on rotation { RotationAnimation { duration: 333; direction: RotationAnimator.Shortest} }

        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            color: Theme.colorRed
            source: control.source_top
        }
        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            color: control.iconColor
            source: control.source_bottom
        }
    }

    ////////////////
}
