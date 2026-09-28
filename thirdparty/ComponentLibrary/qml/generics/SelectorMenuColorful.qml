import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Item {
    id: selectorMenu

    implicitWidth: 128
    implicitHeight: 32

    width: fullWidth ? implicitWidth : contentRow.width

    opacity: enabled ? 1 : 0.66

    // settings
    property bool readOnly: false
    property bool fullWidth: false

    // colors
    property color colorBackground: Theme.colorComponentBackground
    property color colorBorder: Theme.colorComponentBorder

    // states
    signal menuSelected(var index)
    property int currentSelection: 0

    // model
    property var model: null

    ////////////////

    Rectangle { // background
        anchors.fill: parent

        radius: height
        color: selectorMenu.colorBackground

        border.width: 2
        border.color: selectorMenu.colorBorder
    }

    ////////////////

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: -4

        width: selectorMenu.fullWidth ? selectorMenu.width : implicitWidth

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuColorfulItem {
                required property var model

                Layout.preferredHeight: selectorMenu.height
                Layout.preferredWidth: selectorMenu.fullWidth ? 0 : implicitWidth
                Layout.fillWidth: selectorMenu.fullWidth

                readOnly: selectorMenu.readOnly
                highlighted: (selectorMenu.currentSelection === (model.idx ?? 0))
                index: model.idx ?? 0
                text: model.txt ?? ""
                source: model.src ?? ""
                sourceSize: model.sz ?? 32
                onClicked: selectorMenu.menuSelected(model.idx)
            }
        }
    }

    ////////////////
}
