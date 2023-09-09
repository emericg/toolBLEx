import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T
import Qt.labs.qmlmodels 1.0

import ThemeEngine 1.0

T.Popup {
    id: actionMenu

    width: parent.width
    height: contentColumn.height

    padding: 0
    margins: 0

    modal: true
    dim: true
    focus: isMobile
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside
    parent: Overlay.overlay

    property var model: null

    property int layoutDirection: Qt.LeftToRight

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    y: appWindow.height

    property int realHeight: 0
    Component.onCompleted: realHeight = actionMenu.height + screenPaddingNavbar + screenPaddingBottom

    enter: Transition {
        NumberAnimation { duration: 233; property: "height"; from: 0; to: realHeight }
    }
    exit: Transition {
        NumberAnimation { duration: 233; property: "height"; from: realHeight; to: 0 }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        Rectangle {
            width: parent.width
            height: Theme.componentBorderWidth
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Column {
            id: contentColumn
            width: parent.width

            topPadding: 12
            bottomPadding: 8
            spacing: 4

            DelegateChooser {
                id: chooser
                role: "t"
                DelegateChoice {
                    roleValue: "sep"
                    ListSeparatorPadded {
                        anchors.leftMargin: Theme.componentMargin
                        anchors.rightMargin: Theme.componentMargin
                        height: 9
                    }
                }
                DelegateChoice {
                    roleValue: "itm"
                    ActionMenuItem {
                        width: actionMenu.width
                        index: idx
                        text: txt
                        source: src
                        layoutDirection: actionMenu.layoutDirection
                        onClicked: {
                            actionMenu.menuSelected(idx)
                            actionMenu.close()
                        }
                    }
                }
            }

            Repeater {
                model: actionMenu.model
                delegate: chooser
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
