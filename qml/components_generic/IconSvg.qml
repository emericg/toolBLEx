import QtQuick 2.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

Item {
    implicitWidth: 32
    implicitHeight: 32

    property alias source: sourceImg.source
    property alias color: overlayImg.color
    property alias fillMode: sourceImg.fillMode
    property alias asynchronous: sourceImg.asynchronous
    //property alias smooth: sourceImg.smooth

    Image {
        id: sourceImg
        anchors.fill: parent

        visible: parent.color ? false : true
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        asynchronous: false
        smooth: false
    }

    ColorOverlay {
        id: overlayImg
        anchors.fill: parent

        visible: parent.color ? true : false
        source: sourceImg
        color: parent.color
        cached: true
    }
}
