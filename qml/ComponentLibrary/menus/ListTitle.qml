import QtQuick
import QtQuick.Effects

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
    property int sourceRotation: 0
    property color sourceColor: Theme.colorIcon

    property string text: "title"
    property color textColor: Theme.colorText
    property int textSize: source ? Theme.fontSizeContentBig : Theme.fontSizeContentVeryBig

    property bool shadow: !singleColumn

    ////////////////

    IconSvg {
        anchors.left: control.left
        anchors.leftMargin: Theme.componentMarginL
        anchors.verticalCenter: control.verticalCenter

        visible: control.source
        width: control.sourceSize
        height: control.sourceSize
        rotation: control.sourceRotation

        color: control.sourceColor
        source: control.source
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

    layer.enabled: control.shadow
    layer.effect: MultiEffect {
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: ThemeEngine.isLight ? "#16000000" : "#88ffffff"
    }
}
