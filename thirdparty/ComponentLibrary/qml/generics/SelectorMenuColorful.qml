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

    // colors
    property color colorBackground: Theme.colorComponentBackground

    // states
    signal menuSelected(var index)
    property int currentSelection: 0

    // model
    property var model: null
    readonly property int count: model ? (model.count ?? model.length ?? 0) : 0

    ////////////////

    Rectangle { // background
        anchors.fill: parent

        radius: height
        color: selectorMenu.colorBackground

        border.width: 2
        border.color: Theme.colorComponentDown
    }

    ////////////////

    RowLayout {
        id: contentRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: -4

        Repeater {
            model: selectorMenu.model
            delegate: SelectorMenuColorfulItem {
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

    ////////////////
}
