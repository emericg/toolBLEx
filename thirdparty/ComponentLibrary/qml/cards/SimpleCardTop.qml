import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

Rectangle {
    id: card

    width: 480
    height: 400
    radius: Theme.componentRadius
    border.width: Theme.componentBorderWidth
    border.color: Theme.colorSeparator

    color: cardArea.containsMouse ? Theme.colorForeground : Theme.colorBackground
    Behavior on border.color { ColorAnimation { duration: 133 } }

    ////////

    required property url icon
    required property color backgroundColor
    property color backgroundColorGradient: backgroundColor

    required property string title
    required property string hint

    signal clicked()

    ////////

    Rectangle { // top part: gradient banner with the centered icon
        id: cardBanner
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.round(card.height * 2 / 3)

        topLeftRadius: card.radius
        topRightRadius: card.radius

        color: card.backgroundColor

        gradient: Gradient {
            GradientStop { position: 0.0; color: card.backgroundColor }
            GradientStop { position: 1.0; color: card.backgroundColorGradient }
        }

        IconSvg {
            anchors.centerIn: parent
            width: 64
            height: 64
            color: "white"
            source: card.icon
        }
    }

    Item { // bottom part: title and optional hint
        anchors.top: cardBanner.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.centerIn: parent
            width: card.width - Theme.componentMargin * 2
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.title
                textFormat: Text.PlainText
                color: Theme.colorText
                font.pixelSize: Theme.fontSizeContentVeryBig
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (card.hint.length > 0)
                width: parent.width

                text: card.hint
                textFormat: Text.PlainText
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }

    ////////

    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: card.clicked()
    }
    Rectangle {
        anchors.fill: parent
        radius: Theme.componentRadius
        color: "transparent"
        opacity: cardArea.containsMouse ? 1 : 0
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorPrimary
    }

    ////////

    layer.enabled: true
    layer.effect: MultiEffect { // shadow
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: Theme.isLight ? "#22000000" : "#50000000"
    }

    ////////
}
