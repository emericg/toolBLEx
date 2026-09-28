import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Item {
    id: control

    implicitWidth: 128
    implicitHeight: 32

    width: fullWidth ? implicitWidth : (contentRow.width + Theme.componentBorderWidth*2)

    opacity: enabled ? 1 : 0.66

    // settings
    property bool readOnly: false
    property bool fullWidth: false

    // colors
    property color colorBackground: Theme.colorComponent
    property color colorForeground: Theme.colorComponentBackground

    // states
    signal menuSelected(var index)
    property int currentSelection: 0

    // model
    property var model: null

    ////////////////

    Rectangle { // background
        anchors.fill: parent
        radius: Theme.componentRadius
        color: control.colorBackground
    }

    ////////////////

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.componentBorderWidth

        width: control.fullWidth ? (control.width - Theme.componentBorderWidth*2) : implicitWidth

        Repeater {
            model: control.model
            delegate: SelectorMenuItem {
                required property var model

                Layout.preferredHeight: control.height - Theme.componentBorderWidth*2
                Layout.preferredWidth: control.fullWidth ? 0 : implicitWidth
                Layout.fillWidth: control.fullWidth

                colorContent: Theme.colorComponentText
                colorContentHighlight: Theme.colorComponentText
                colorBackgroundHighlight: control.colorForeground
                readOnly: control.readOnly
                highlighted: (control.currentSelection === (model.idx ?? 0))
                index: model.idx ?? 0
                text: model.txt ?? ""
                source: model.src ?? ""
                sourceSize: model.sz ?? 32
                onClicked: control.menuSelected(model.idx)
            }
        }
    }

    ////////////////
}
