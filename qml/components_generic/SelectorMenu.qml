import QtQuick 2.15

import ThemeEngine 1.0

Item {
    id: selectorMenu
    implicitWidth: 128
    implicitHeight: 32

    width: contentRow.width
    opacity: enabled ? 1 : 0.4

    property var model: null

    // colors
    property string colorBackground: Theme.colorComponentBackground

    // states
    property int currentSelection: 1
    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: parent

        radius: height
        color: selectorMenu.colorBackground

        border.width: 2
        border.color: Theme.colorComponentDown
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: contentRow
        height: parent.height
        spacing: 0

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuItem {
                selected: (selectorMenu.currentSelection === idx)
                index: idx ?? 0
                text: txt ?? ""
                source: src ?? ""
                sourceSize: sz ?? 32
                onClicked: selectorMenu.menuSelected(idx)
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
