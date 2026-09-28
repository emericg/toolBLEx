pragma ComponentBehavior: Bound

import QtQuick

import ComponentLibrary

/*!
 * \brief Draws the cards behind the children of a FrameStackColumn or FrameStackRow container.
 *
 * Must be placed below the container, sharing its geometry.
 * In separated mode each visible child gets its own card.
 * Vertical cards span the container width, horizontal cards span the container height.
 * In joined mode a single card covers the container, split by separators between children.
 */
Item {
    id: control

    required property Item container
    property int orientation: Qt.Vertical

    property bool joined: false
    property int radius: 8

    property color colorCard: Theme.colorBackground
    property color colorCardBorder: Theme.colorComponentBorder
    property color colorSeparator: Theme.colorComponentBorder

    readonly property bool vertical: (control.orientation === Qt.Vertical)

    ////////////////

    Rectangle { // joined card
        width: control.container.width
        height: control.container.height
        visible: control.joined

        radius: control.radius
        color: control.colorCard
        border.width: 1
        border.color: control.colorCardBorder
    }

    Repeater { // per child decorations
        model: control.container.children

        delegate: Item {
            id: deco

            required property Item modelData

            x: control.vertical ? 0 : modelData.x
            y: control.vertical ? modelData.y : 0
            width: control.vertical ? control.container.width : modelData.width
            height: control.vertical ? modelData.height : control.container.height
            visible: modelData.visible && modelData.width > 0 && modelData.height > 0

            Rectangle { // separated card
                anchors.fill: parent
                visible: !control.joined

                radius: control.radius
                color: control.colorCard
                border.width: 1
                border.color: control.colorCardBorder
            }

            Rectangle { // joined separator
                width: control.vertical ? parent.width : 1
                height: control.vertical ? 1 : parent.height
                visible: control.joined &&
                         (control.vertical ? deco.modelData.y > 0 : deco.modelData.x > 0)
                color: control.colorSeparator
            }
        }
    }

    ////////////////
}
