import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: implicitBackgroundWidth
    implicitHeight: implicitBackgroundHeight

    flat: true
    checkable: false
    hoverEnabled: isDesktop
    focusPolicy: Qt.NoFocus

    // settings
    property int radius: (width / 4)

    // icon
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.66, 2)
    property int sourceRotation: 0

    // colors
    property color colorBackground: Theme.colorPrimary
    property color colorHighlight: Theme.colorComponentBorder
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.2)
    property color colorBorder: Theme.colorComponentBorder
    property color colorIcon: "white"

    // animation
    property string animation // available: rotate, fade, both
    property bool animationRunning: false

    // tooltip
    property string tooltipText
    property string tooltipPosition: "bottom"

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            radius: control.radius
            color: control.colorBackground
            border.width: Theme.componentBorderWidth
            border.color: control.colorBorder

            layer.enabled: !control.flat
            layer.effect: MultiEffect {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowScale: 1.04
                shadowVerticalOffset: 4
                shadowColor: Theme.colorComponentShadow
            }
        }

        RippleThemed {
            width: parent.width
            height: parent.height

            anchor: control
            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple

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
                        radius: control.radius
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: Item {
        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            visible: control.source.toString().length
            color: control.colorIcon
            opacity: control.enabled ? 1 : 0.66
            rotation: control.sourceRotation

            source: control.source

            SequentialAnimation on opacity {
                running: (control.animationRunning &&
                          (control.animation === "fade" || control.animation === "both"))
                alwaysRunToEnd: true
                loops: Animation.Infinite

                PropertyAnimation { to: 0.5; duration: 666; }
                PropertyAnimation { to: 1; duration: 666; }
            }
            NumberAnimation on rotation {
                running: (control.animationRunning &&
                          (control.animation === "rotate" || control.animation === "both"))
                alwaysRunToEnd: true
                loops: Animation.Infinite

                duration: 1500
                from: 0
                to: 360
                easing.type: Easing.Linear
            }
        }
    }

    ////////////////

    Loader {
        anchors.fill: control
        active: control.tooltipText

        sourceComponent: ToolTipFlat {
            visible: control.hovered
            text: control.tooltipText
            textColor: control.colorIcon
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.colorBackground
        }
    }

    ////////////////
}
