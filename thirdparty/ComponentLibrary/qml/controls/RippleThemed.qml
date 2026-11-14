import QtQuick
import QtQuick.Effects

import ComponentLibrary

/*!
 * \brief Ink ripple, drawn behind the content of a clickable item.
 *
 * Same API as the QQuickMaterial.Ripple, without depending on the QtQuick.Controls.Material module.
 *
 * A tint is shown while active (hovered, focused), and a wave grows from the press position while pressed.
 * The press position comes from the anchor pressX / pressY (AbstractButton) or mouseX / mouseY (MouseArea),
 * and falls back to the center of the ripple.
 * By default, pressed and active follow the anchor (pressed, enabled, down, hovered, visualFocus),
 * so a MouseArea anchor only gets the wave.
 * The wave is only created from a press until the end of its fade.
 */
Item {
    id: control

    clip: (control.clipRadius <= 0 && waveLoader.active)

    /*! \brief Item providing the press position, and the default pressed and active states. */
    property Item anchor
    /*! \brief Start a wave when set, fade it out when cleared. */
    property bool pressed: (anchor?.pressed === true)
    /*! \brief Show the tint while the anchor is hovered, by default. */
    property bool hoverTint: true
    /*! \brief Show the hover / focus tint. */
    property bool active: (anchor?.enabled === true) &&
                          (anchor.down === true || (hoverTint && anchor.hovered === true) || anchor.visualFocus === true)
    /*! \brief Radius of the rounded clipping, 0 for a rectangular clip. */
    property real clipRadius: 0

    property color color: Qt.alpha(Theme.colorForeground, 0.5)

    onPressedChanged: {
        if (pressed) startWave()
        else if (waveLoader.item) waveLoader.item.exit()
    }

    /*!
     * \brief Start a new wave, centered on the anchor press position.
     *
     * The wave grows until it covers the farthest corner from its origin.
     */
    function startWave() {
        var px = width / 2
        var py = height / 2
        if (anchor) {
            let pos = null
            if (typeof anchor.pressX === "number") pos = anchor.mapToItem(control, anchor.pressX, anchor.pressY)
            else if (typeof anchor.mouseX === "number") pos = anchor.mapToItem(control, anchor.mouseX, anchor.mouseY)
            if (pos) {
                px = pos.x
                py = pos.y
            }
        }

        var dx = Math.max(px, width - px)
        var dy = Math.max(py, height - py)

        waveLoader.active = true
        waveLoader.item.start(px, py, 2 * Math.sqrt(dx*dx + dy*dy))
    }

    ////////////////

    Rectangle { // hover / focus tint
        anchors.fill: parent
        radius: control.clipRadius
        color: control.color

        visible: (opacity > 0)
        opacity: control.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animationSpeedMedium } }
    }

    ////////////////

    Loader {
        id: waveLoader
        anchors.fill: parent

        active: false
        sourceComponent: Item {
            id: waves

            /*!
             * \brief Start a new wave.
             * \param px: horizontal center of the wave, in the ripple coordinates.
             * \param py: vertical center of the wave, in the ripple coordinates.
             * \param size: final diameter of the wave.
             */
            function start(px, py, size) {
                waveGrow.stop()
                waveExit.stop()

                wave.cx = px
                wave.cy = py
                wave.width = 0
                wave.opacity = 1
                waveGrow.to = size
                waveGrow.start()
            }

            /*!
             * \brief Fade the wave out, while it quickly grows to its full size,
             * then unload it.
             */
            function exit() {
                waveGrow.stop()
                waveFinish.to = waveGrow.to
                waveExit.start()
            }

            Item {
                id: waveLayer
                anchors.fill: parent

                readonly property bool rounded: (control.clipRadius > 0)

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

                // rounded clipping
                layer.enabled: waveLayer.rounded
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskInverted: false
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                    maskSpreadAtMax: 0.0
                    maskSource: waveMask
                }
            }

            Rectangle {
                id: waveMask
                anchors.fill: parent
                radius: control.clipRadius

                visible: false
                layer.enabled: waveLayer.rounded
            }

            NumberAnimation {
                id: waveGrow
                target: wave
                property: "width"
                duration: Theme.animationSpeedSlow * 2
                easing.type: Easing.OutCubic
            }
            ParallelAnimation {
                id: waveExit

                NumberAnimation {
                    id: waveFinish
                    target: wave
                    property: "width"
                    duration: Theme.animationSpeedSlow
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: wave
                    property: "opacity"
                    to: 0
                    duration: Theme.animationSpeedSlow
                }

                onFinished: waveLoader.active = false
            }
        }
    }

    ////////////////
}
