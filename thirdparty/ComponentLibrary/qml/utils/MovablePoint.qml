import QtQuick

import ComponentLibrary

Item {
    id: control

    width: 0
    height: 0

    property color color: Theme.colorHighContrast
    property color colorHighlight: Theme.colorPrimary

    property bool boundToParent: true
    property bool boundHorizontal: false // when true, horizontal movement is locked
    property bool boundVertical: false   // when true, vertical movement is locked

    property bool isMoving: false
    signal moved()

    MouseArea {
        anchors.centerIn: parent
        width: 32
        height: 32

        hoverEnabled: true

        // Offset between the point origin and the grab position, so the point
        // doesn't jump under the cursor when grabbed away from its center.
        property real grabOffsetX: 0
        property real grabOffsetY: 0

        onPressed: (mouse) => {
            var m = mapToItem(control.parent, mouse.x, mouse.y)
            grabOffsetX = control.x - m.x
            grabOffsetY = control.y - m.y
            control.isMoving = true
        }
        onReleased: {
            control.isMoving = false
        }
        onCanceled: {
            control.isMoving = false
        }
        onPositionChanged: (mouse) => {
            if (!control.isMoving) return

            var m = mapToItem(control.parent, mouse.x, mouse.y)
            var xWas = control.x
            var yWas = control.y

            if (!control.boundHorizontal) {
                var nx = m.x + grabOffsetX
                if (control.boundToParent) nx = Math.max(0, Math.min(nx, control.parent.width))
                control.x = nx
            }
            if (!control.boundVertical) {
                var ny = m.y + grabOffsetY
                if (control.boundToParent) ny = Math.max(0, Math.min(ny, control.parent.height))
                control.y = ny
            }

            if (control.x !== xWas || control.y !== yWas) control.moved()
        }

        Rectangle {
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: 40

            color: control.colorHighlight
            opacity: (parent.containsMouse || parent.pressed) ? 0.333 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animationFastSpeed } }
        }
        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 12
            radius: 12

            color: control.color
        }
    }
}
