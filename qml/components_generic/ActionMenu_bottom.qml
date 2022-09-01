import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.qmlmodels 1.0

import ThemeEngine 1.0

Popup {
    id: actionMenu
    width: parent.width
    y: appWindow.height

    padding: 0
    margins: 0

    parent: Overlay.overlay
    modal: true
    dim: false
    focus: isMobile
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var model: null
    property int layoutDirection: Qt.LeftToRight

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    property real realHeight: 0
    Component.onCompleted: realHeight = height

    enter: Transition {
        NumberAnimation { duration: 233; property: "height"; from: 0; to: realHeight }
    }
    exit: Transition {
        NumberAnimation { duration: 233; property: "height"; from: realHeight; to: 0 }
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground
        radius: Theme.componentRadius
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        padding: Theme.componentBorderWidth

        topPadding: 8
        bottomPadding: 8
        spacing: 4

        DelegateChooser {
            id: chooser
            role: "t"
            DelegateChoice {
                roleValue: "sep"
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Theme.componentBorderWidth
                    color: Theme.colorSeparator
                }
            }
            DelegateChoice {
                roleValue: "itm"
                ActionMenuItem {
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

    ////////////////////////////////////////////////////////////////////////////
}
