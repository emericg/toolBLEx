import QtQuick

import ComponentLibrary

PopupThemed {
    id: popupMessage

    property string title: "PopupMessage"
    property color titleTextColor: headerArea.solid ? "white" : Theme.colorText

    property string bannerText

    property string text: "This is a generic message, empty of any kind of meaning."

    property string buttonText: qsTr("OK")

    signal confirmed()

    ////////////////

    headerArea.solid: false
    bannerArea.shown: bannerText.length > 0
    footerArea.solid: false

    ////////////////

    header: Text {
        width: parent.width
        text: popupMessage.title
        font.pixelSize: Theme.fontSizeContentVeryBig
        color: popupMessage.titleTextColor
        wrapMode: Text.WordWrap
    }

    ////

    banner: Text {
        width: parent.width
        text: popupMessage.bannerText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorSubText
        wrapMode: Text.WordWrap
    }

    ////

    content: Text {
        width: parent.width
        text: popupMessage.text
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorText
        wrapMode: Text.WordWrap
    }

    ////

    footer: Item { // button
        width: parent.width
        height: Theme.componentHeightXL

        ButtonFlat {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.singleColumn ? parent.width : (parent.width / 2)

            text: popupMessage.buttonText
            color: Theme.colorPrimary

            onClicked: {
                popupMessage.confirmed()
                popupMessage.close()
            }
        }
    }

    ////////////////
}
