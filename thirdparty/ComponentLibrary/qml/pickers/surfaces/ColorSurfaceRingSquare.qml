import QtQuick
import QtQuick.Shapes

import ComponentLibrary

/*!
 * \brief Hue ring around a saturation / value square.
 *
 * A hue drag must start on the ring, then follows the angle wherever the pointer goes.
 */
ColorSurface {
    id: root

    property int ringThickness: 22
    property int squareGap: Theme.componentMarginXXS // between the square corners and the ring

    readonly property real _cx: width / 2
    readonly property real _cy: height / 2
    readonly property real _outerR: Math.min(_cx, _cy)
    readonly property real _innerR: _outerR - ringThickness
    readonly property real _ringR: (_innerR + _outerR) / 2
    readonly property real _squareSide: Math.max(0, _innerR * Math.SQRT2 - squareGap * 2)

    Shape { // static hue ring, two circles with an odd-even fill
        anchors.centerIn: parent
        width: root._outerR * 2
        height: width
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillRule: ShapePath.OddEvenFill
            fillGradient: ColorHueConicalGradient {
                centerX: root._outerR
                centerY: root._outerR
            }
            PathAngleArc {
                centerX: root._outerR; centerY: root._outerR
                radiusX: root._outerR; radiusY: root._outerR
                startAngle: 0; sweepAngle: 360
            }
            PathAngleArc {
                centerX: root._outerR; centerY: root._outerR
                radiusX: root._innerR; radiusY: root._innerR
                startAngle: 0; sweepAngle: 360
                moveToStart: true
            }
        }
    }

    ColorSurfaceHandle { // hue, on the ring centerline
        readonly property var point: UtilsColor.hueSatToPoint(root.hue, 1.0, root._cx, root._cy, root._ringR)
        x: point.x - width / 2
        y: point.y - height / 2
    }

    ColorSurfaceArea { // hue, below the square
        anchors.fill: parent
        innerRadius: root._innerR
        outerRadius: root._outerR
        onDragged: (mx, my) => {
            const hs = UtilsColor.pointToHueSat(mx, my, root._cx, root._cy, root._outerR)
            root.picked(hs.hue, root.sat, root.val)
        }
    }

    ColorSurfaceSVSquare {
        anchors.centerIn: parent
        width: root._squareSide
        height: root._squareSide

        hue: root.hue
        sat: root.sat
        val: root.val
        onPicked: (h, s, v) => root.picked(h, s, v)
    }
}
