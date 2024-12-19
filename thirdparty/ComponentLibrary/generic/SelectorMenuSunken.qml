import QtQuick

import ComponentLibrary

Item {
    id: control
    implicitWidth: 128
    implicitHeight: 32

    width: contentRow.width + Theme.componentBorderWidth*2

    opacity: enabled ? 1 : 0.66

    // colors
    property color colorBackground: Theme.colorComponent
    property color colorForeground: Theme.colorComponentBackground

    // states
    signal menuSelected(var index)
    property int currentSelection: 1

    // model
    property var model: null

    ////////////////

    Rectangle { // background
        anchors.fill: parent
        radius: Theme.componentRadius
        color: control.colorBackground
    }

    ////////////////

    Row {
        id: contentRow
        anchors.centerIn: parent
        height: parent.height - Theme.componentBorderWidth*2
        spacing: Theme.componentBorderWidth

        Repeater {
            model: control.model
            delegate: SelectorMenuItem {
                colorContent: Theme.colorComponentText
                colorContentHighlight: Theme.colorComponentText
                colorBackgroundHighlight: control.colorForeground
                height: parent.height
                highlighted: (control.currentSelection === idx)
                index: idx ?? 0
                text: txt ?? ""
                source: src ?? ""
                sourceSize: sz ?? 32
                onClicked: control.menuSelected(idx)
            }
        }
    }

    ////////////////
}
