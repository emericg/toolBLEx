import QtQuick

import ComponentLibrary

Item {
    id: selectorMenu
    implicitWidth: 128
    implicitHeight: 32

    width: contentRow.width

    opacity: enabled ? 1 : 0.66

    // settings
    property bool readOnly: false

    // colors
    property color colorBackground: Theme.colorComponentBackground

    // states
    property int currentSelection: 1
    signal menuSelected(var index)

    // model
    property var model: null

    ////////////////

    Rectangle { // background
        anchors.fill: parent

        radius: height
        color: selectorMenu.colorBackground

        border.width: 2
        border.color: Theme.colorComponentDown
    }

    ////////////////

    Row {
        id: contentRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: -4

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuColorfulItem {
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

    ////////////////
}
