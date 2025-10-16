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

    RowLayout {
        id: contentRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.componentBorderWidth

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuItem {
                Layout.preferredHeight: selectorMenu.height
                Layout.preferredWidth: selectorMenu.fullWidth ? (selectorMenu.width / selectorMenu.model.count) : width

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
