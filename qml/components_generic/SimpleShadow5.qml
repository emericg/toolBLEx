import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    anchors.fill: parent
    z: -1

    property string color: "#666"
    property alias radius: shadowarea.radius
    property bool filled: true

    Rectangle {
        id: shadowarea
        anchors.fill: parent

        visible: false
        color: parent.filled ? parent.color : "transparent"

        border.width: parent.filled ? 0 : 4
        border.color: parent.color
    }
    DropShadow {
        anchors.fill: parent

        source: shadowarea
        cached: true
        radius: 16.0
        samples: (radius*2 + 1)
        color: parent.color
        horizontalOffset: 0
        verticalOffset: 0
    }
}
