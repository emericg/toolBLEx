import QtQuick
import QtQuick.Shapes

/*!
 * \brief Full hue spectrum around a center, for hue wheels and rings.
 *
 * Hue 0 (red) is at 3 o'clock, increasing clockwise, matching UtilsColor.hueSatToPoint().
 * ConicalGradient runs counter-clockwise, hence the reversed stops.
 * Set centerX and centerY.
 */
ConicalGradient {
    angle: 0

    GradientStop { position: 0.000; color: Qt.hsva(1.000, 1, 1, 1) }
    GradientStop { position: 0.167; color: Qt.hsva(0.833, 1, 1, 1) }
    GradientStop { position: 0.333; color: Qt.hsva(0.667, 1, 1, 1) }
    GradientStop { position: 0.500; color: Qt.hsva(0.500, 1, 1, 1) }
    GradientStop { position: 0.667; color: Qt.hsva(0.333, 1, 1, 1) }
    GradientStop { position: 0.833; color: Qt.hsva(0.167, 1, 1, 1) }
    GradientStop { position: 1.000; color: Qt.hsva(0.000, 1, 1, 1) }
}
