import QtQuick

import ComponentLibrary

Rectangle {
    id: control

    implicitWidth: 20
    implicitHeight: 20
    radius: width

    // settings
    property string text
    property bool fade: false

    // colors
    color: Theme.colorPrimary
    property color colorText: "white"

    function blink() { blinkAnim.start() }

    ////////////////

    Rectangle {
        id: blinkRect
        anchors.centerIn: parent
        z: -1
        width: 0
        height: width
        radius: width
        color: control.color
    }
    ParallelAnimation {
        id: blinkAnim
        NumberAnimation { target: blinkRect; property: "width"; from: 12; to: 40; duration: 666; }
        NumberAnimation { target: blinkRect; property: "opacity"; from: 0.85; to: 0; duration: 666; }
    }
    SequentialAnimation on opacity {
        running: control.fade
        loops: Animation.Infinite
        alwaysRunToEnd: true
        PropertyAnimation { to: 0.33; duration: 666; }
        PropertyAnimation { to: 0.66; duration: 666; }
    }

    ////////////////

    Text {
        anchors.fill: parent

        text: control.text
        textFormat: Text.PlainText
        fontSizeMode: Text.HorizontalFit
        font.bold: true
        font.pixelSize: Theme.fontSizeContentVerySmall
        minimumPixelSize: Theme.fontSizeContentVeryVerySmall
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: control.colorText
        opacity: 0.8
    }

    ////////////////
}
