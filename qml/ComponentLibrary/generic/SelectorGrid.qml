import QtQuick

import ThemeEngine

Item {
    id: selectorGrid

    implicitWidth: 512
    implicitHeight: Theme.componentHeight

    width: parent.width
    height: (selectorGrid.btnRows * btnHeight) + ((selectorGrid.btnRows-1) * contentPositioner.spacing)

    opacity: enabled ? 1 : 0.66

    property int btnCols: 4
    property int btnRows: 3
    property int btnWidth: ((width - ((selectorGrid.btnCols-1) * contentPositioner.spacing)) / selectorGrid.btnCols)
    property int btnHeight: Theme.componentHeight

    signal menuSelected(var index)
    property int currentSelection: 0

    property var model: null

    ////////////////

    Rectangle { // background
        anchors.fill: parent
        radius: Theme.componentRadius
        color: Theme.colorComponentBackground
    }

    ////////////////

    Grid {
        id: contentPositioner
        anchors.fill: parent
        spacing: 1

        columns: selectorGrid.btnCols
        rows: selectorGrid.btnRows

        Repeater {
            model: selectorGrid.model
            delegate: SelectorGridItem {
                width: selectorGrid.btnWidth
                height: selectorGrid.btnHeight

                highlighted: (selectorGrid.currentSelection === idx)
                index: idx ?? 0
                text: txt ?? ""
                onClicked: selectorGrid.menuSelected(idx)
            }
        }
    }

    ////////////////

    Rectangle { // foreground border
        anchors.fill: parent
        radius: Theme.componentRadius

        color: "transparent"
        border.width: Theme.componentBorderWidth
        border.color: Theme.colorComponentBorder
    }

    ////////////////
}
