import QtQuick 2.15

import ThemeEngine 1.0

Item {
    id: selectorMenu
    implicitWidth: 128
    implicitHeight: 32

    width: contentRow.width
    opacity: enabled ? 1 : 0.4

    signal menuSelected(var index)
    property int currentSelection: 1

    property var model: null

    ////////////////

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.componentRadius
        color: Theme.colorComponentBackground
    }

    ////////////////

    Row {
        id: contentRow
        height: parent.height
        spacing: Theme.componentBorderWidth

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuThemedItem {
                selected: (selectorMenu.currentSelection === idx)
                index: idx ?? 0
                text: txt ?? ""
                source: src ?? ""
                sourceSize: sz ?? 32
                onClicked: selectorMenu.menuSelected(idx)
            }
        }
    }

    Rectangle {
        id: foreground
        anchors.fill: parent
        radius: Theme.componentRadius

        color: "transparent"
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder
    }

    ////////////////
}
