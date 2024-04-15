import QtQuick

import ThemeEngine

Rectangle {
    id: control

    implicitWidth: 48
    implicitHeight: 20

    width: contentText.contentWidth + 12

    radius: Theme.componentRadius
    color: Theme.colorPrimary

    // settings
    property string text: "0"
    property color textColor: "white"
    property int textSize: Theme.fontSizeContentSmall
    property int textCapitalization: Font.Normal
    property bool textBold: true

    Text {
        id: contentText
        anchors.centerIn: parent

        text: control.text
        textFormat: Text.PlainText

        color: control.textColor
        font.bold: control.textBold
        font.pixelSize: control.textSize
        font.capitalization: control.textCapitalization
    }
}
