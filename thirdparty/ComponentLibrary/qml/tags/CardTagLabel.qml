import QtQuick

import ComponentLibrary

Row {
    id: control

    property alias text: label.text

    property int dotWidth: 10
    property color dotColor: Theme.colorPrimary

    spacing: Theme.componentMarginXS

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: control.dotWidth
        height: control.dotWidth
        radius: control.dotWidth / 2
        color: control.dotColor
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        color: Theme.colorSubText
        font.pixelSize: Theme.fontSizeContentSmall
        font.weight: Font.Medium
    }
}
