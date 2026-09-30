import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    clip: true

    // settings (same API as RippleThemed)
    property Item anchor
    property bool pressed: false
    property bool active: false
    property real clipRadius: 0

    // colors
    property color color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.5)

    onPressedChanged: {
        if (pressed) startWave()
        else waveFade.start()
    }

    /*!
     * \brief Start a new wave, centered on the anchor press position.
     *
     * Falls back to the center of the ripple when the anchor doesn't expose pressX/pressY.
     * The wave grows until it covers the farthest corner from its origin.
     */
    function startWave() {
        waveGrow.stop()
        waveFade.stop()

        var px = width / 2
        var py = height / 2
        if (anchor && typeof anchor.pressX === "number") {
            var pos = anchor.mapToItem(control, anchor.pressX, anchor.pressY)
            px = pos.x
            py = pos.y
        }

        var dx = Math.max(px, width - px)
        var dy = Math.max(py, height - py)

        wave.cx = px
        wave.cy = py
        wave.width = 0
        wave.opacity = 1
        waveGrow.to = 2 * Math.sqrt(dx*dx + dy*dy)
        waveGrow.start()
    }

    ////////////////

    Rectangle { // hover / focus tint
        anchors.fill: parent
        radius: control.clipRadius
        color: control.color

        opacity: control.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animationSpeedMedium } }
    }

    ////////////////

    Item {
        id: waveLayer
        anchors.fill: parent

        visible: wave.opacity > 0

        Rectangle {
            id: wave

            property real cx: 0
            property real cy: 0

            x: cx - (width / 2)
            y: cy - (width / 2)
            width: 0
            height: width
            radius: (width / 2)

            color: control.color
            opacity: 0
        }

        // rounded clipping, only while a wave is visible
        layer.enabled: (control.clipRadius > 0 && visible)
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: false
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    width: waveLayer.width
                    height: waveLayer.height
                    radius: control.clipRadius
                }
            }
        }
    }

    NumberAnimation {
        id: waveGrow
        target: wave
        property: "width"
        duration: Theme.animationSpeedSlow * 2
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: waveFade
        target: wave
        property: "opacity"
        to: 0
        duration: Theme.animationSpeedSlow
    }

    ////////////////
}
