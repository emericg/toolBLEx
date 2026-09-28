import QtQuick

import ComponentLibrary

PopupThemed {
    id: popupChoice

    property string title: "PopupChoice"
    property color titleTextColor: headerArea.solid ? "white" : Theme.colorText

    property string bannerText

    property string text: "This is a generic message, empty of any kind of meaning."

    property string buttonClose: qsTr("Close")
    property string buttonCancel: qsTr("Cancel")
    property string buttonPrimary: qsTr("OK")
    property string buttonSecondary: qsTr("Maybe")

    signal rejected()
    signal accepted()
    signal acceptedSecondary()

    ////////////////

    headerArea.solid: false
    bannerArea.shown: bannerText.length > 0
    footerArea.solid: false

    footerArea.leftPadding: Theme.componentMarginXL
    footerArea.rightPadding: Theme.componentMarginXL

    ////////////////

    header: Text {
        width: parent.width
        text: popupChoice.title
        font.pixelSize: Theme.fontSizeContentVeryBig
        color: popupChoice.titleTextColor
        wrapMode: Text.WordWrap
    }

    ////

    banner: Text {
        width: parent.width
        text: popupChoice.bannerText
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorSubText
        wrapMode: Text.WordWrap
    }

    ////

    content: Text {
        width: parent.width
        text: popupChoice.text
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorSubText
        wrapMode: Text.WordWrap
    }

    ////

    footer: Flow { // buttons
        width: parent.width
        spacing: Theme.componentMargin

        property int btnCount: popupChoice.buttonSecondary ? 3 : 2
        property int btnSize: Theme.singleColumn ? width : ((width - (spacing * (btnCount - 1))) / btnCount)

        ButtonClear {
            width: parent.btnSize

            text: popupChoice.buttonClose
            color: Theme.colorGrey

            onClicked: {
                popupChoice.rejected()
                popupChoice.close()
            }
        }

        ButtonFlat {
            width: parent.btnSize

            visible: popupChoice.buttonSecondary
            text: popupChoice.buttonSecondary
            color: Theme.colorWarning

            onClicked: {
                popupChoice.acceptedSecondary()
                popupChoice.close()
            }
        }

        ButtonFlat {
            width: parent.btnSize

            text: popupChoice.buttonPrimary
            color: Theme.colorError

            onClicked: {
                popupChoice.accepted()
                popupChoice.close()
            }
        }
    }

    ////////////////
}
