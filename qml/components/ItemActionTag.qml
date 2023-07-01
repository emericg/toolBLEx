import QtQuick

import ThemeEngine

Rectangle {
    id: control
    implicitWidth: 80
    implicitHeight: 28

    width: contentText.contentWidth + 24

    radius: Theme.componentRadius
    color: (mousearea.containsMouse || control.highlighted) ? Qt.darker(Theme.colorForeground, 1.1) : Theme.colorForeground
    Behavior on color { ColorAnimation { duration: 333; } }

    // actions
    signal clicked()

    // settings
    property string text: "TAG"
    property string textColor: Theme.colorText
    property int textSize: Theme.componentFontSize
    property bool textBold: false
    property int textCapitalization: Font.Normal
    property bool highlighted: false

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

    MouseArea {
        id: mousearea
        anchors.fill: parent
        enabled: control.enabled
        hoverEnabled: control.enabled
        onClicked: control.clicked()
    }
}
