import QtQuick

import ThemeEngine

Rectangle {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: singleColumn ? 0 : Theme.componentMargin
    anchors.right: parent.right
    anchors.rightMargin: singleColumn ? 0 : Theme.componentMargin

    height: Theme.componentHeightL
    radius: singleColumn ? 0 : Theme.componentRadius
    z: 2

    color: Theme.colorForeground
    border.width: singleColumn ? 0 : Theme.componentBorderWidth
    border.color: Theme.colorSeparator

    property string source
    property int sourceSize: 24
    property color sourceColor: Theme.colorIcon

    property string text: "title"
    property color textColor: Theme.colorText
    property int textSize: source ? Theme.fontSizeContentBig : Theme.fontSizeContentVeryBig

    ////////////////

    IconSvg {
        anchors.left: control.left
        anchors.leftMargin: Theme.componentMarginL
        anchors.verticalCenter: control.verticalCenter

        width: control.sourceSize
        height: control.sourceSize

        source: control.source
        visible: control.source
        color: control.sourceColor
    }

    Text {
        anchors.left: control.left
        anchors.leftMargin: control.source ? (singleColumn ? appHeader.headerPosition : Theme.componentMarginL*2 + sourceSize)
                                           : Theme.componentMarginL
        anchors.right: control.right
        anchors.rightMargin: Theme.componentMarginL
        anchors.verticalCenter: control.verticalCenter

        text: control.text
        textFormat: Text.PlainText
        font.pixelSize: control.textSize
        font.bold: false
        color: control.textColor
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////
}
