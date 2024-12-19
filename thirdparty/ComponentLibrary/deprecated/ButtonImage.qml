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

    // settings
    property string hoverMode: "off" // available: off, push, pull, glow
    property string clickMode: "off" // available: off, push, pull

    // image
    property url source
    property int sourceSize: 32

    // colors
    property color colorHighlight: Theme.colorPrimary

    hoverEnabled: (enabled && hoverMode !== "off")

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        opacity: control.enabled ? 1 : 0.66

        Rectangle {
            anchors.centerIn: parent
            width: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))
            height: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))

            color: control.colorHighlight
            radius: control.width

            visible: (control.hoverMode === "glow")
            opacity: control.hovered ? 0.33 : 0
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }

        layer.enabled: (control.hoverMode === "glow")
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            blurEnabled: true
            blur: 1.0
        }
    }

    ////////////////

    contentItem: Item {
        Image {
            id: contentImage
            anchors.centerIn: parent

            width: {
                var multiplier = 1.0
                if (control.pressed) {
                    if (clickMode === "pull") multiplier = 1.1
                    else if (clickMode === "push") multiplier = 0.9
                }
                return Math.round(control.sourceSize * multiplier)
            }
            height: {
                var multiplier = 1.0
                if (control.pressed) {
                    if (clickMode === "pull") multiplier = 1.1
                    else if (clickMode === "push") multiplier = 0.9
                } else if (control.hovered) {
                    if (hoverMode === "pull") multiplier = 1.1
                    else if (hoverMode === "push") multiplier = 0.9
                }
                return Math.round(control.sourceSize * multiplier)
            }

            source: control.source
            sourceSize: Qt.size(control.sourceSize, control.sourceSize)
            fillMode: Image.PreserveAspectFit

            opacity: control.enabled ? 1 : 0.66
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }
    }

    ////////////////
}
