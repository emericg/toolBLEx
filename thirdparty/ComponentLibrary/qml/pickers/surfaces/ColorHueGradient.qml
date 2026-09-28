import QtQuick

/*!
 * \brief Full hue spectrum (red -> red), for hue bars and sliders.
 *
 * Seven stops are exact: at full saturation and value,
 * linear RGB interpolation between primaries and secondaries matches the HSV hue.
 * Vertical by default, set `orientation` for an horizontal spectrum.
 */
Gradient {
    orientation: Gradient.Vertical

    GradientStop { position: 0.000; color: Qt.hsva(0.000, 1, 1, 1) }
    GradientStop { position: 0.167; color: Qt.hsva(0.167, 1, 1, 1) }
    GradientStop { position: 0.333; color: Qt.hsva(0.333, 1, 1, 1) }
    GradientStop { position: 0.500; color: Qt.hsva(0.500, 1, 1, 1) }
    GradientStop { position: 0.667; color: Qt.hsva(0.667, 1, 1, 1) }
    GradientStop { position: 0.833; color: Qt.hsva(0.833, 1, 1, 1) }
    GradientStop { position: 1.000; color: Qt.hsva(1.000, 1, 1, 1) }
}
