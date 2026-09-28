import QtQuick
import QtQuick.Effects

Item {
    id: control

    implicitWidth: 32
    implicitHeight: 32

    ////////////////

    property color color: "transparent"

    property alias source: sourceImg.source
    property alias fillMode: sourceImg.fillMode
    property alias cache: sourceImg.cache
    property alias asynchronous: sourceImg.asynchronous

    ////////////////

    Image {
        id: sourceImg
        anchors.fill: parent

        smooth: parent.smooth
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)

        layer.enabled: (control.color.a > 0)
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: control.color
        }
    }

    ////////////////
}
