import QtQuick
import QtQuick.Effects

Item {
    id: control

    implicitWidth: 32
    implicitHeight: 32

    property alias source: sourceImg.source
    property alias color: overlayImg.colorizationColor
    property alias fillMode: sourceImg.fillMode
    property alias asynchronous: sourceImg.asynchronous

    Image {
        id: sourceImg
        anchors.fill: parent

        visible: parent.color ? false : true
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        smooth: control.smooth
        asynchronous: false
    }

    MultiEffect {
        id: overlayImg
        source: sourceImg
        anchors.fill: sourceImg
        brightness: 1.0
        colorization: 1.0
    }
}
