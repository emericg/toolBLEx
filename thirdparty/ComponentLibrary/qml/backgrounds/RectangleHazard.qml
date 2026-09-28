import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    implicitWidth: 128
    implicitHeight: 128

    ////////

    property int radius: 0
    property color colorBackground: "#1a1a1a"
    property color colorStripe: "#f2c21a"

    property real stripeAngle: 45
    property real stripeWidth: 40
    property real stripeSpacing: 40

    property bool antialiasing: false

    ////////

    readonly property real pitch: control.stripeWidth + control.stripeSpacing
    readonly property real overhang: control.height * 2

    readonly property real stripeThickness: Math.max(1, control.stripeWidth * Math.cos(Math.min(Math.abs(control.stripeAngle), 80) * Math.PI / 180))
    readonly property int stripeCount: Math.ceil((control.width + 2 * control.overhang) / control.pitch) + 1

    ////////

    Rectangle {
        anchors.fill: parent

        color: control.colorBackground
        radius: control.radius

        ////

        Repeater {
            model: control.stripeCount

            Rectangle {
                x: index * control.pitch - control.overhang
                y: (control.height - height) / 2

                width: control.stripeThickness
                height: control.height * 3

                color: control.colorStripe
                rotation: control.stripeAngle
                antialiasing: false
            }
        }

        ////

        clip: (control.radius <= 0)

        layer.enabled: (control.radius > 0)
        layer.effect: MultiEffect { // mask
            maskEnabled: true
            maskInverted: false
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    x: 0
                    y: 0
                    width: control.width
                    height: control.height
                    radius: control.radius
                }
            }
        }

        ////
    }

    ////////
}
