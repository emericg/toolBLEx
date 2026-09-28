import QtQuick
import QtQuick.Shapes

import ComponentLibrary

/*!
 * \brief Hue / saturation wheel: angle is hue, distance from the center is saturation.
 *
 * Value isn't pickable here, it only dims the wheel (see the value hint overlay).
 * Presses outside of the disc are left to the items below,
 * once started, a drag keeps tracking outside (saturation clamps at the rim).
 */
ColorSurface {
    id: root

    readonly property real _cx: width / 2
    readonly property real _cy: height / 2
    readonly property real _radius: Math.min(_cx, _cy)

    Shape { // static wheel at full value
        anchors.centerIn: parent
        width: root._radius * 2
        height: width
        preferredRendererType: Shape.CurveRenderer

        ShapePath { // hue
            strokeColor: "transparent"
            fillGradient: ColorHueConicalGradient {
                centerX: root._radius
                centerY: root._radius
            }
            PathAngleArc {
                centerX: root._radius; centerY: root._radius
                radiusX: root._radius; radiusY: root._radius
                startAngle: 0; sweepAngle: 360
            }
        }

        ShapePath { // saturation, white center fading out to the rim
            strokeColor: "transparent"
            fillGradient: RadialGradient {
                centerX: root._radius; centerY: root._radius; centerRadius: root._radius
                focalX: root._radius; focalY: root._radius; focalRadius: 0
                GradientStop { position: 0.0; color: "#ffffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
            PathAngleArc {
                centerX: root._radius; centerY: root._radius
                radiusX: root._radius; radiusY: root._radius
                startAngle: 0; sweepAngle: 360
            }
        }
    }

    Rectangle { // value hint, capped so hue and saturation stay readable at val = 0
        anchors.centerIn: parent
        width: root._radius * 2
        height: width
        radius: width / 2
        color: "black"
        opacity: (1.0 - root.val) * 0.45
    }

    ColorSurfaceHandle {
        readonly property var point: UtilsColor.hueSatToPoint(root.hue, root.sat,
                                                              root._cx, root._cy, root._radius)
        x: point.x - width / 2
        y: point.y - height / 2
        ringColor: UtilsColor.contrastColorThemed(root.color)
    }

    ColorSurfaceArea {
        anchors.fill: parent
        outerRadius: root._radius
        onDragged: (mx, my) => {
            const hs = UtilsColor.pointToHueSat(mx, my, root._cx, root._cy, root._radius)
            root.picked(hs.hue, hs.sat, root.val)
        }
    }
}
