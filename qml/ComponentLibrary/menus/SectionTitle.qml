import QtQuick
import QtQuick.Controls

import ThemeEngine

Rectangle {
    id: control

    implicitWidth: 512
    implicitHeight: Theme.componentHeightL

    radius: singleColumn ? 0 : Theme.componentRadius
    z: 2

    color: Theme.colorForeground
    border.width: singleColumn ? 0 : Theme.componentBorderWidth
    border.color: Theme.colorSeparator

    property string source

    property string text: "title"
    property int textSize: source ? Theme.fontSizeContentBig :
                                    Theme.fontSizeContentVeryBig

    ////////////////////////////////////////////////////////////////////////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: singleColumn ? 24 : 16

        IconSvg {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            source: control.source
            visible: control.source
            color: Theme.colorIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: control.textSize
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
