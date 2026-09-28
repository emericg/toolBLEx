import QtQuick

import ComponentLibrary

/*!
 * \brief Saturation / value square (x = saturation, y = value) with a vertical hue bar.
 */
ColorSurface {
    id: root

    property int barWidth: 24
    property int gap: Theme.componentMargin

    ColorSurfaceSVSquare {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: hueBar.left
        anchors.rightMargin: root.gap

        hue: root.hue
        sat: root.sat
        val: root.val
        onPicked: (h, s, v) => root.picked(h, s, v)
    }

    Rectangle { // hue bar, top to bottom
        id: hueBar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.barWidth
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
        gradient: ColorHueGradient { }

        ColorSurfaceHandle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width + 6
            height: 6
            y: root.hue * parent.height - height / 2
        }

        ColorSurfaceArea {
            anchors.fill: parent
            onDragged: (mx, my) => root.picked(UtilsNumber.clamp(my / hueBar.height, 0.0, 1.0), root.sat, root.val)
        }
    }
}
