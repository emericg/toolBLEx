import QtQuick
import QtLocation

import ComponentLibrary

Item {
    id: mapScale

    implicitWidth: mapScale.referenceWidth
    implicitHeight: 20

    // maximum width of the scale bar, in pixels
    // the bar shrinks from here to fit a "nice" round distance
    property int referenceWidth: 100

    property Map map: null

    property int appUnits: 0 // QLocale::MeasurementSystem

    property color colorScale: "#555"

    ////////////////

    Component.onCompleted: computeScale()

    Connections {
        target: mapScale.map

        function onMapReadyChanged() {
            mapScale.computeScale()
        }
        function onZoomLevelChanged() {
            mapScale.computeScale()
        }
        function onCenterChanged() {
            mapScale.computeScale()
        }
    }

    ////////////////

    readonly property var scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000,
                                         20000, 50000, 100000, 200000, 500000, 1000000, 2000000]

    function computeScale() {
        if (!map || !map.mapReady) return

        // distance (in meters) covered by 'referenceWidth' pixels at the current zoom/latitude
        var y = 100 // arbitrary vertical sampling offset, away from the top edge
        var coord1 = map.toCoordinate(Qt.point(0, y))
        var coord2 = map.toCoordinate(Qt.point(mapScale.referenceWidth, y))
        var dist = Math.round(coord1.distanceTo(coord2))
        if (dist <= 0) return // not visible // not ready yet

        //console.log("computeScale(zoom: " + map.zoomLevel + " | dist: " + dist +")")

        // pick the nicest scale length, then scale the bar width accordingly
        var scale = scaleLengths[scaleLengths.length - 1]
        for (var i = 0; i < scaleLengths.length - 1; i++) {
            if (dist < (scaleLengths[i] + scaleLengths[i+1]) / 2) {
                scale = scaleLengths[i]
                break
            }
        }

        mapScale.width = mapScale.referenceWidth * (scale / dist)
        mapScaleText.text = UtilsString.distanceToString(scale, 0, mapScale.appUnits)
    }

    ////////////////

    Text {
        id: mapScaleText
        anchors.centerIn: parent
        text: "100m"
        textFormat: Text.PlainText
        color: mapScale.colorScale
        font.pixelSize: Theme.fontSizeContentVerySmall
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 2
        height: 6
        color: mapScale.colorScale
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 2
        color: mapScale.colorScale
    }
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: 2
        height: 6
        color: mapScale.colorScale
    }

    ////////////////
}
