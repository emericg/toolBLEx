import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: singleColumn ? 0 : Theme.componentMargin
    anchors.right: parent.right
    anchors.rightMargin: singleColumn ? 0 : Theme.componentMargin

    height: Theme.componentHeightL
    radius: singleColumn ? 0 : Theme.componentRadius
    z: 2

    color: backgroundColor
    border.width: singleColumn ? 0 : Theme.componentBorderWidth
    border.color: borderColor

    property string icon
    property string iconColor: Theme.colorIcon
    property int iconSize: 24

    property string text: "title"
    property string textColor: Theme.colorText
    property int textSize: source ? Theme.fontSizeContentBig :
                                    Theme.fontSizeContentVeryBig

    property string backgroundColor: Theme.colorForeground
    property string borderColor: Theme.colorSeparator

    ////////////////

    IconSvg {
        anchors.left: control.left
        anchors.leftMargin: Theme.componentMarginL
        anchors.verticalCenter: control.verticalCenter

        width: control.iconSize
        height: control.iconSize

        source: control.icon
        visible: control.icon
        color: control.iconColor
    }

    Text {
        anchors.left: control.left
        anchors.leftMargin: control.icon ? (singleColumn ? appHeader.headerPosition : Theme.componentMarginL*2 + iconSize)
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
