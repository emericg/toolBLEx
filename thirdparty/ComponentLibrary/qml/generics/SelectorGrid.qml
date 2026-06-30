import QtQuick

import ComponentLibrary

Item {
    id: selectorGrid

    implicitWidth: 512
    implicitHeight: Theme.componentHeight

    width: parent.width
    height: (selectorGrid.btnRows * btnHeight) + ((selectorGrid.btnRows-1) * contentPositioner.spacing)

    opacity: enabled ? 1 : 0.66

    // settings
    property bool readOnly: false

    property int btnCols: 4
    property int btnRows: Math.max(1, Math.ceil(selectorGrid.count / selectorGrid.btnCols))
    property int btnWidth: ((width - ((selectorGrid.btnCols-1) * contentPositioner.spacing)) / selectorGrid.btnCols)
    property int btnHeight: Theme.componentHeight

    // states
    signal menuSelected(var index)
    property int currentSelection: 0

    // model
    property var model: null
    readonly property int count: model ? (model.count ?? model.length ?? 0) : 0

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
                required property var model

                width: selectorGrid.btnWidth
                height: selectorGrid.btnHeight

                readOnly: selectorGrid.readOnly
                highlighted: (selectorGrid.currentSelection === model.idx)
                source: model.src ?? ""
                text: model.txt ?? ""
                index: model.idx ?? 0
                onClicked: selectorGrid.menuSelected(model.idx)
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
