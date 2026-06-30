import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Item {
    id: selectorMenu

    implicitWidth: 128
    implicitHeight: 32

    width: contentRow.width

    opacity: enabled ? 1 : 0.66

    // settings
    property bool readOnly: false
    property bool fullWidth: false

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

    RowLayout {
        id: contentRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.componentBorderWidth

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuItem {
                required property var model

                Layout.preferredHeight: selectorMenu.height
                Layout.preferredWidth: selectorMenu.fullWidth ? (selectorMenu.width / Math.max(1, selectorMenu.count)) : implicitWidth

                readOnly: selectorMenu.readOnly
                highlighted: (selectorMenu.currentSelection === model.idx)
                index: model.idx ?? 0
                text: model.txt ?? ""
                source: model.src ?? ""
                sourceSize: model.sz ?? 32
                onClicked: selectorMenu.menuSelected(model.idx)
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
