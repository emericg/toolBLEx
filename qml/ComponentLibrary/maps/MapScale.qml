import QtQuick

import QtLocation

import ThemeEngine
import "qrc:/utils/UtilsString.js" as UtilsString

Item {
    id: mapScale

    implicitWidth: 128
    implicitHeight: 20

    property Map map: null

    property variant scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000,
                                    20000, 50000, 100000, 200000, 500000, 1000000, 2000000]

    ////////////////

    Component.onCompleted: computeScale()

    function computeScale() {
        if (!map) return

        var coord1 = map.toCoordinate(Qt.point(0, 100))
        var coord2 = map.toCoordinate(Qt.point(100, 100))
        var dist = Math.round(coord1.distanceTo(coord2))
        var f = 0

        //console.log("computeScale(zoom: " + map.zoomLevel + " | dist: " + dist +")")

        if (dist === 0) {
            // not visible
        } else {
            for (var i = 0; i < scaleLengths.length-1; i++) {
                if (dist < (scaleLengths[i] + scaleLengths[i+1]) / 2 ) {
                    f = scaleLengths[i] / dist
                    dist = scaleLengths[i]
                    break
                }
            }
            if (f === 0) {
                f = dist / scaleLengths[i]
                dist = scaleLengths[i]
            }
        }

        mapScale.width = 100 * f
        mapScaleText.text = UtilsString.distanceToString(dist, 0, settingsManager.appUnits)
    }

    ////////////////

    Text {
        id: mapScaleText
        anchors.centerIn: parent
        text: "100m"
        color: "#555"
        font.pixelSize: Theme.fontSizeContentVerySmall
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 2
        height: 6
        color: "#555"
    }
    Rectangle {
        anchors.bottom: parent.bottom

        width: parent.width
        height: 2
        color: "#555"
    }
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: 2
        height: 6
        color:"#555"
    }

    ////////////////
}
