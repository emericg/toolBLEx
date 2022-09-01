import QtQuick 2.15

import ThemeEngine 1.0

Item {
    id: selectorMenu
    implicitWidth: 128
    implicitHeight: 32
    width: contentRow.width

    signal menuSelected(var index)
    property int currentSelection: 1

    property var model: null

    Rectangle {
        id: background
        anchors.fill: parent

        radius: height
        color: Theme.colorComponentBackground

        border.width: 2
        border.color: Theme.colorComponentDown
    }

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
}
