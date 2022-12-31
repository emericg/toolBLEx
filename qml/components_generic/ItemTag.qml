import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: control
    implicitWidth: 80
    implicitHeight: 28

    width: contentText.contentWidth + 24

    radius: Theme.componentRadius
    color: Theme.colorForeground

    property string text: "TAG"
    property string textColor: Theme.colorText
    property int textSize: Theme.fontSizeComponent
    property int textCapitalization: Font.Normal // Font.AllUppercase

    Text {
        id: contentText
        anchors.centerIn: parent

        text: control.text
        textFormat: Text.PlainText

        color: control.textColor
        font.bold: true
        font.pixelSize: control.textSize
        font.capitalization: control.textCapitalization
    }
}
