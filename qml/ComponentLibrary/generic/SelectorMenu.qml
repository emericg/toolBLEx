import QtQuick

import ThemeEngine

Item {
    id: selectorMenu
    implicitWidth: 128
    implicitHeight: 32

    width: contentRow.width

    opacity: enabled ? 1 : 0.66

    // settings
    property bool readOnly: false

    // states
    signal menuSelected(var index)
    property int currentSelection: 1

    // model
    property var model: null

    ////////////////

    Rectangle { // background
        anchors.fill: parent
        radius: Theme.componentRadius
        color: Theme.colorComponentBackground
    }

    ////////////////

    Row {
        id: contentRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.componentBorderWidth

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuItem {
                height: selectorMenu.height
                readOnly: selectorMenu.readOnly
                highlighted: (selectorMenu.currentSelection === idx)
                index: idx ?? 0
                text: txt ?? ""
                source: src ?? ""
                sourceSize: sz ?? 32
                onClicked: selectorMenu.menuSelected(idx)
            }
        }
    }

    Rectangle { // foreground border
        anchors.fill: parent
        radius: Theme.componentRadius

        color: "transparent"
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder
    }

    ////////////////
}
