import QtQuick

import ComponentLibrary

/*!
 * \brief Selection handle for the color surfaces: a colored ring with a dark inner ring.
 *
 * The inner ring keeps the handle visible over light colors, whatever ringColor is.
 * Round by default, set width and height for a pill (ex: on a hue bar).
 */
Rectangle {
    property color ringColor: "white"

    width: Math.round(Theme.componentHeight / 2)
    height: width
    radius: Math.min(width, height) / 2

    color: "transparent"
    border.color: ringColor
    border.width: 2

    Rectangle { // dark inner ring
        anchors.fill: parent
        anchors.margins: 2
        radius: Math.max(0, parent.radius - 2)
        color: "transparent"
        border.color: "#80000000"
        border.width: 1
    }
}
