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
        sourceSize: Qt.size(width, height)

        visible: !(parent.color.a > 0)
        fillMode: Image.PreserveAspectFit
        smooth: parent.smooth
    }

    MultiEffect {
        id: overlayImg
        anchors.fill: sourceImg
        source: sourceImg

        visible: (parent.color.a > 0)
        brightness: 1.0
        colorization: 1.0
    }
}
