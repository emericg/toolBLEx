import QtQuick 2.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

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

    Rectangle {
        id: background
        anchors.fill: parent

        radius: Theme.componentRadius
        color: Theme.colorComponentBackground

        border.width: Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: background.x
                y: background.y
                width: background.width
                height: background.height
                radius: background.radius
            }
        }

        Row {
            id: contentRow
            height: parent.height
            spacing: 0

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
    }
}
