import QtQuick
import QtQuick.Templates as T
import Qt.labs.qmlmodels

import ComponentLibrary

T.Popup {
    id: actionMenu

    implicitWidth: parent.width
    implicitHeight: actualHeight

    // We use Screen.width/height on this mobile component,
    // it's (mostly) equivalent to the dimension of the app window

    y: Screen.height

    padding: 0
    margins: 0

    modal: true
    dim: true
    focus: Theme.isMobile
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside
    parent: T.Overlay.overlay

    property string titleTxt
    property string titleSrc // disabled

    property var model: null

    property int layoutDirection: Qt.LeftToRight

    signal menuSelected(var index)

    ////////////////

    property int actualHeight: {
        if (typeof mobileMenu !== "undefined" && mobileMenu.height)
            return contentColumn.height + Math.max(Theme.screenPaddingNavbar, Theme.screenPaddingBottom)
        return contentColumn.height
    }

    property bool opening: false
    property bool closing: false

    onAboutToShow: {
        opening = true
        closing = false
    }
    onAboutToHide: {
        opening = false
        closing = true
    }

    ////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animationMediumSpeed; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.66; duration: Theme.animationMediumSpeed; } }

    ////////////////

    T.Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.24 : 0.48
    }

    background: Item { }

    contentItem: Item { }

    ////////////////

    Rectangle {
        id: actualPopup
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: actionMenu.opening ? actionMenu.actualHeight : 0
        Behavior on height { NumberAnimation { duration: 233 } }

        color: Theme.colorComponentBackground

        Rectangle { // separator
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.componentBorderWidth
            color: Theme.colorSeparator
        }

        Column { // content
            id: contentColumn
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: Theme.screenPaddingLeft
            anchors.right: parent.right
            anchors.rightMargin: Theme.screenPaddingRight

            topPadding: Theme.componentMargin
            bottomPadding: 4
            spacing: 0

            ////

            Text { // title
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin + 4
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin

                height: Theme.componentHeight
                visible: actionMenu.titleTxt

                text: actionMenu.titleTxt
                textFormat: Text.PlainText

                color: Theme.colorSubText
                font.bold: false
                font.pixelSize: Theme.fontSizeContentVeryBig
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            ////

            Repeater {
                model: actionMenu.model
                delegate: DelegateChooser {
                    id: chooser
                    role: "t"
                    DelegateChoice {
                        roleValue: "sep"
                        ActionMenuItem_separator {
                            width: actionMenu.width
                        }
                    }
                    DelegateChoice {
                        roleValue: "itm"
                        ActionMenuItem_button {
                            width: actionMenu.width
                            height: Theme.componentHeightL
                            layoutDirection: actionMenu.layoutDirection
                            index: idx
                            text: txt
                            source: src
                            onClicked: {
                                actionMenu.menuSelected(idx)
                                actionMenu.close()
                            }
                        }
                    }
                }
            }

            ////
        }
    }

    ////////////////
}
