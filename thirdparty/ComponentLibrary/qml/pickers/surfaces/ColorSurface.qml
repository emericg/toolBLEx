import QtQuick

/*!
 * \brief Base type of the color picker surfaces.
 *
 * Contract: HSV in (render only), picked(h, s, v) out, no state of its own.
 * The owner binds the channels, and decides whether to apply what is picked.
 * All channels are in the 0..1 range.
 */
Item {
    property real hue: 0.0
    property real sat: 0.0
    property real val: 1.0

    readonly property color color: Qt.hsva(hue, sat, val, 1.0) // opaque

    signal picked(real h, real s, real v)
}
