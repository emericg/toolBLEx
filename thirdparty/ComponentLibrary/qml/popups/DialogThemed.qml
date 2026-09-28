import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ComponentLibrary

Dialog {
    id: control

    x: Theme.singleColumn ? 0 : Math.round((Theme.appWidth / 2) - (width / 2))
    y: Theme.singleColumn ? (Theme.appHeight - height)
                          : Math.round((Theme.appHeight / 2) - (height / 2))

    width: {
        if (Theme.singleColumn) return Theme.appWidth
        if (Theme.isTablet && Theme.screenOrientation === Qt.LandscapeOrientation) return 512
        return 720
    }
    padding: Theme.componentMarginXL
    margins: 0

    dim: true
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    property string text // message body

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.5; to: 1.0; duration: Theme.animationSpeedFast; } }
    //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animationSpeedMedium; } }

    Overlay.modal: Item {
        Rectangle {
            anchors.fill: parent
            anchors.margins: Theme.windowBorders
            radius: Theme.windowCornersRadius
            color: "#000000"
            opacity: Theme.isLight ? 0.24 : 0.48
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.singleColumn ? 0 : Theme.componentBorderWidth
        radius: Theme.singleColumn ? 0 : Theme.componentRadius

        ////

        Rectangle { // top separator (single column)
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.componentBorderWidth
            visible: Theme.singleColumn
            color: Theme.colorSeparator
        }

        layer.enabled: !Theme.singleColumn
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            blurMax: 64
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#cc000000"
        }

        ////
    }

    ////////////////////////////////////////////////////////////////////////////

    header: Text {
        visible: control.title.length > 0
        height: visible ? implicitHeight : 0

        padding: Theme.componentMarginXL
        bottomPadding: 0

        text: control.title
        font.pixelSize: Theme.fontSizeContentVeryBig
        color: Theme.colorText
        wrapMode: Text.WordWrap
    }

    contentItem: Text {
        text: control.text
        font.pixelSize: Theme.fontSizeContent
        color: Theme.colorSubText
        wrapMode: Text.WordWrap
    }

    footer: DialogButtonBox {
        id: buttonbox

        implicitHeight: contentItem.implicitHeight
        spacing: Theme.componentMargin
        alignment: Qt.AlignRight

        property int btnCount: buttonbox.count
        property int btnFlowWidth: buttonbox.width - 2*Theme.componentMarginXL
        property int btnSize: Theme.singleColumn ? btnFlowWidth : ((btnFlowWidth-(spacing*(btnCount-1))) / btnCount)

        background: Item {}

        contentItem: Flow {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL

            topPadding: 0
            bottomPadding: Theme.componentMarginXL + Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)
            spacing: Theme.componentMargin
            layoutDirection: Qt.RightToLeft
        }

        delegate: ButtonFlat {
            width: buttonbox.btnSize

            color: {
                switch (DialogButtonBox.buttonRole) {
                case DialogButtonBox.DestructiveRole:
                    return Theme.colorError
                case DialogButtonBox.AcceptRole:
                case DialogButtonBox.YesRole:
                case DialogButtonBox.ApplyRole:
                    return Theme.colorPrimary
                default:
                    return Theme.colorSubText
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
