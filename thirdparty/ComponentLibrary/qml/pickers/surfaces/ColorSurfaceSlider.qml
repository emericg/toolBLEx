pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

/*!
 * \brief Gradient slider for a single color channel (0..1), with an optional label.
 *
 * Built on the Slider template: keyboard (arrows, page up / down) and accessibility included.
 * Bind `value` to the channel and apply it back from onMoved().
 * Set `checkered` for alpha channels, to draw a checkerboard behind the gradient.
 */
T.Slider {
    id: control

    property string label
    property Gradient barGradient: null
    property bool checkered: false

    readonly property int labelWidth: (label.length > 0) ? 14 : 0
    readonly property int grooveHeight: 22

    implicitWidth: 200
    implicitHeight: grooveHeight + 8
    leftPadding: (labelWidth > 0) ? labelWidth + Theme.componentMarginS : 0

    from: 0.0
    to: 1.0
    stepSize: 0.01 // keyboard increment
    focusPolicy: Qt.StrongFocus

    Accessible.name: label

    background: Item {
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: control.labelWidth
            visible: control.labelWidth > 0
            text: control.label
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }

        Item {
            id: groove
            x: control.leftPadding
            anchors.verticalCenter: parent.verticalCenter
            width: control.availableWidth
            height: control.grooveHeight

            ColorCheckerBoard { // clipped to the pill shape
                anchors.fill: parent
                visible: control.checkered
                active: control.checkered

                layer.enabled: control.checkered
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskThresholdMin: 0.5
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: groove.width
                            height: groove.height
                            radius: groove.height / 2
                        }
                    }
                }
            }

            Rectangle { // gradient + border
                anchors.fill: parent
                radius: height / 2
                border.color: control.activeFocus ? Theme.colorPrimary : Theme.colorSeparator
                border.width: Theme.componentBorderWidth
                gradient: control.barGradient
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 14
        height: control.grooveHeight + 8
        radius: 4
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }
}
