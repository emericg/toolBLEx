import QtQuick
import QtQuick.Shapes

import ComponentLibrary

Item {
    id: control

    implicitWidth: 512
    implicitHeight: 512

    ////////////////

    // Gradient
    property int type: GradientPresets.Linear
    property var stops: GradientPresets.grape

    // Linear angle, in degrees (0: left to right, 90: top to bottom, 180: right to left, 270: bottom to top)
    property real angle: 0

    // Radial focal point, normalized to the item [0.0, 1.0]
    property real centerX: 0.5
    property real centerY: 0.5

    // Rounded corners
    property real radius: 0

    ////////////////

    // Rebuild the stop objects of the active gradient (holded by the Shape component) from the 'stops' array
    function rebuildStops() {
        let grad = shapePath.fillGradient
        if (!grad) return

        let built = []
        for (let i = 0; i < control.stops.length; ++i) {
            built.push(stopComponent.createObject(grad, {
                position: control.stops[i].position,
                color: control.stops[i].color
            }))
        }
        grad.stops = built
    }

    onStopsChanged: Qt.callLater(rebuildStops)
    onTypeChanged: Qt.callLater(rebuildStops)
    Component.onCompleted: rebuildStops()

    Component {
        id: stopComponent
        GradientStop {}
    }

    ////////////////

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath

            strokeWidth: -1

            fillGradient: (control.type === GradientPresets.Radial) ? radialFill : linearFill

            PathRectangle {
                width: control.width
                height: control.height
                radius: control.radius
            }
        }
    }

    // The fill gradients live as plain resources and are selected by type

    LinearGradient {
        id: linearFill

        readonly property real rad: control.angle * Math.PI / 180
        readonly property real dx: Math.cos(rad)
        readonly property real dy: Math.sin(rad)
        readonly property real half: Math.abs(dx) * control.width / 2 +
                                     Math.abs(dy) * control.height / 2

        x1: control.width / 2 - linearFill.dx * linearFill.half
        y1: control.height / 2 - linearFill.dy * linearFill.half
        x2: control.width / 2 + linearFill.dx * linearFill.half
        y2: control.height / 2 + linearFill.dy * linearFill.half
    }

    RadialGradient {
        id: radialFill

        centerX: control.width * control.centerX
        centerY: control.height * control.centerY
        centerRadius: Math.max(control.width, control.height) / 2
        focalX: centerX
        focalY: centerY
    }

    ////////////////
}
