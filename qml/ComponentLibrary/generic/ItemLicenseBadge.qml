import QtQuick
import QtQuick.Controls

import ThemeEngine

AbstractButton {
    id: control
    width: leftText.contentWidth + rightText.contentWidth + 24
    height: 22

    text: "text"
    property string legend: "legend"

    Rectangle {
        id: leftRect
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: leftText.right
        anchors.rightMargin: -6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        color: "#555555"
    }

    Rectangle {
        id: rightRect
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: leftRect.right
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        color: "#97ca00"
    }

    Text {
        id: leftText
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        color: "white"
        text: control.legend
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeContentVerySmall
    }

    Text {
        id: rightText
        anchors.left: rightRect.left
        anchors.leftMargin: 6
        anchors.right: rightRect.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        color: "white"
        text: control.text
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeContentVerySmall
        font.bold: true
    }

    HoverHandler {
        acceptedDevices: PointerDevice.Mouse
        cursorShape: Qt.PointingHandCursor
    }
}
