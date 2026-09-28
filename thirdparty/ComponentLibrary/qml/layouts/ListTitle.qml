import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: Theme.singleColumn ? 0 : Theme.componentMargin
    anchors.right: parent.right
    anchors.rightMargin: Theme.singleColumn ? 0 : Theme.componentMargin

    height: Theme.componentHeightXL
    z: 2

    // settings
    property bool shadow: !Theme.singleColumn
    property int headerPosition: 64
    property int radius: Theme.singleColumn ? 0 : Theme.componentRadius

    // colors
    property color backgroundColor: Qt.darker(Theme.colorForeground, Theme.isLight ? 0.72 : 1.24)
    property color borderColor: Qt.darker(Theme.colorComponentBorder, Theme.isLight ? 1.0 : 1.32)
    property color shadowColor: Theme.colorComponentShadow

    // icon
    property url source
    property int sourceSize: 24
    property int sourceRotation: 0
    property color sourceColor: Theme.colorIcon

    // text
    property string text: "title"
    property color textColor: Theme.colorText
    property int textSize: source.length ? Theme.fontSizeContentBig : Theme.fontSizeContentVeryBig
    property bool textBold: false

    ////////////////

    Rectangle { // background
        anchors.fill: parent

        radius: control.radius
        color: control.backgroundColor
        border.width: Theme.singleColumn ? 0 : Theme.componentBorderWidth
        border.color: control.borderColor

        layer.enabled: control.shadow
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: Theme.colorComponentShadow
            shadowOpacity: 0.66
        }
    }

    ////////////////

    IconSvg {
        anchors.left: control.left
        anchors.leftMargin: Theme.componentMarginL
        anchors.verticalCenter: control.verticalCenter

        visible: control.source.toString().length
        width: control.sourceSize
        height: control.sourceSize
        rotation: control.sourceRotation

        color: control.sourceColor
        source: control.source
    }

    Text {
        anchors.left: control.left
        anchors.leftMargin: {
            if (control.source.toString().length) {
                if (Theme.singleColumn) return control.headerPosition
                return (Theme.componentMarginL*2 + control.sourceSize)
            }
            return Theme.componentMarginL
        }
        anchors.right: control.right
        anchors.rightMargin: Theme.componentMarginL
        anchors.verticalCenter: control.verticalCenter

        text: control.text
        textFormat: Text.PlainText
        font.pixelSize: control.textSize
        font.bold: control.textBold
        color: control.textColor
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////
}
