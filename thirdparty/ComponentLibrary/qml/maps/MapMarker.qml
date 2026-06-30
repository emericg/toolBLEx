import QtQuick
import QtLocation

import ComponentLibrary

MapQuickItem {
    id: posMarker

    width: 64
    height: 64

    anchorPoint.x: (posMarker.width / 2)
    anchorPoint.y: (posMarker.height / 2)

    property url source: "../../assets/maps/gps_marker.svg"
    property url source_bearing: "../../assets/maps/gps_marker_bearing.svg"

    property bool has_bearing: (map_bearing !== 0.0 || compass_bearing !== 0.0)
    property real map_bearing: 0.0
    property real compass_bearing: 0.0

    //coordinate: QtPositioning.coordinate(1, 2)

    rotation: 360.0 - map_bearing - compass_bearing
    Behavior on rotation { RotationAnimation { duration: 133; direction: RotationAnimator.Shortest; } }

    sourceItem: Image {
        width: posMarker.width
        height: posMarker.height
        sourceSize: Qt.size(width, height)
        source: posMarker.has_bearing ? posMarker.source_bearing : posMarker.source
    }
}
