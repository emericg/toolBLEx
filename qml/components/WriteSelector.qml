import QtQuick
import QtQuick.Layouts

import ComponentLibrary

/*!
 * SelectorMenuColorful, with a dot on a "default" item, ex: the format matching a descriptor.
 */
Item {
    id: writeSelector

    implicitWidth: contentRow.width
    implicitHeight: 32

    opacity: enabled ? 1 : 0.66

    property var model: null
    property int currentSelection: 0

    //! Item marked with a dot (ex: the format matching a descriptor), -1 for none
    property int defaultSelection: -1

    Rectangle { // background
        anchors.fill: parent
        radius: height
        color: Theme.colorComponentBackground
        border.width: 2
        border.color: Theme.colorComponentBorder
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: -4

        Repeater {
            model: writeSelector.model

            delegate: SelectorMenuColorfulItem {
                id: writeSelectorItem
                required property var model

                Layout.preferredHeight: writeSelector.height

                readonly property bool isDefault: (writeSelector.defaultSelection === index)
                readonly property color colorCurrent: highlighted ? colorContentHighlight : colorContent

                highlighted: (writeSelector.currentSelection === index)
                index: model.idx
                text: model.txt
                onClicked: writeSelector.currentSelection = index

                contentItem: Row {
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: writeSelectorItem.text
                        textFormat: Text.PlainText
                        font: writeSelectorItem.font
                        color: writeSelectorItem.colorCurrent
                        opacity: writeSelectorItem.highlighted ? 1 : 0.66
                    }

                    Rectangle { // default item
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4

                        visible: writeSelectorItem.isDefault
                        color: writeSelectorItem.highlighted ? "white" : Theme.colorGreen
                    }
                }
            }
        }
    }
}
