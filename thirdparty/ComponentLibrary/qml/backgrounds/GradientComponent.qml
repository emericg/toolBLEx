import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    implicitWidth: 512
    implicitHeight: 512

    ////////////////

    // Gradient fill
    property int type: GradientPresets.Linear
    property var stops: GradientPresets.grape

    // Linear angle, in degrees (0: left to right, 90: top to bottom, 180: right to left, 270: bottom to top)
    property real angle: 315

    // Radial focal point, normalized to the item [0.0, 1.0]
    property real centerX: 0.5
    property real centerY: 0.5

    // Rounded corners
    property real radius: 0

    // Tileable texture overlay (optional)
    property url texture: {
        if (texturePattern.length <= 0) return ""
        return "qrc:/ComponentLibraryAssets/patterns/" + texturePattern + ".svg"
    }
    property string texturePattern
    property int textureFillMode: Image.Tile
    property int textureTileSize: 48
    property real textureOpacity: 0.12
    property color textureColor: "white"

    // Content overlay (optional)
    default property alias content: contentContainer.data

    ////////////////

    GradientRectangle { // background gradient
        id: fill
        anchors.fill: parent

        type: control.type
        stops: control.stops
        angle: control.angle
        centerX: control.centerX
        centerY: control.centerY
        radius: control.radius
    }

    Image { // background geometric pattern
        anchors.fill: parent

        visible: control.texture != ""
        opacity: control.textureOpacity
        fillMode: control.textureFillMode

        source: control.texture
        sourceSize.width: control.textureTileSize

        asynchronous: true
        cache: true

        layer.enabled: (control.textureColor.a > 0)
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: control.textureColor
        }
    }

    ////////////////

    Item {
        id: contentContainer
        anchors.fill: parent
    }

    ////////////////
}
