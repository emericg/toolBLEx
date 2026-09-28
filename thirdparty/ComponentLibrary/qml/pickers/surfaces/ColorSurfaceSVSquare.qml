import QtQuick

import ComponentLibrary

/*!
 * \brief Saturation / value square (x = saturation, y = value) for a given hue.
 *
 * Building block of ColorSurfaceSquare and ColorSurfaceRingSquare, the hue is picked back as is.
 */
ColorSurface {
    id: root

    Rectangle { // saturation: white -> hue
        anchors.fill: parent
        radius: Theme.componentRadius
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 1.0; color: Qt.hsva(root.hue, 1.0, 1.0, 1.0) }
        }

        Rectangle { // value: transparent -> black, border on top of both gradients
            anchors.fill: parent
            radius: parent.radius
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "black" }
            }
        }
    }

    ColorSurfaceHandle {
        x: root.sat * root.width - width / 2
        y: (1.0 - root.val) * root.height - height / 2
        ringColor: UtilsColor.contrastColorThemed(root.color)
    }

    ColorSurfaceArea {
        anchors.fill: parent
        onDragged: (mx, my) => root.picked(root.hue,
                                           UtilsNumber.clamp(mx / root.width, 0.0, 1.0),
                                           UtilsNumber.clamp(1.0 - my / root.height, 0.0, 1.0))
    }
}
