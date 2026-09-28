import QtQuick

import ComponentLibrary

/*!
 * \brief Three gradient sliders (hue, saturation, value), for compact or touch layouts.
 *
 * Each gradient previews its channel with the two other channels fixed.
 * Keyboard and accessibility come from ColorSurfaceSlider.
 */
ColorSurface {
    id: root

    implicitWidth: 240
    implicitHeight: column.implicitHeight

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.componentMarginL

        ColorSurfaceSlider {
            width: parent.width
            label: qsTr("H")
            value: root.hue
            barGradient: ColorHueGradient { orientation: Gradient.Horizontal }
            onMoved: root.picked(value, root.sat, root.val)
        }

        ColorSurfaceSlider {
            width: parent.width
            label: qsTr("S")
            value: root.sat
            barGradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.hsva(root.hue, 0.0, root.val, 1) }
                GradientStop { position: 1.0; color: Qt.hsva(root.hue, 1.0, root.val, 1) }
            }
            onMoved: root.picked(root.hue, value, root.val)
        }

        ColorSurfaceSlider {
            width: parent.width
            label: qsTr("V")
            value: root.val
            barGradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "black" }
                GradientStop { position: 1.0; color: Qt.hsva(root.hue, root.sat, 1.0, 1) }
            }
            onMoved: root.picked(root.hue, root.sat, value)
        }
    }
}
