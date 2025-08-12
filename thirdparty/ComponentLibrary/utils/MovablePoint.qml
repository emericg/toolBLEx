import QtQuick

import ComponentLibrary

Item {
    id: control

    width: 0
    height: 0

    property color color: Theme.colorHighContrast
    property color colorHighlight: Theme.colorPrimary

    property bool boundToParent: true
    property bool boundVertical: false
    property bool boundHorizontal: false

    property bool isMoving: false
    signal moved()

    MouseArea {
        anchors.centerIn: parent
        width: 32
        height: 32

        hoverEnabled: true
        property point beginDrag

        onPressed: (mouse) => {
            beginDrag = mapToItem(control.parent, mouse.x, mouse.y)
            control.isMoving = true
        }
        onReleased: {
            control.isMoving = false
        }
        onCanceled: {
            control.isMoving = false
        }
        onPositionChanged: (mouse) => {
            if (control.isMoving) {
                var globalMouse = mapToItem(control.parent, mouse.x, mouse.y)
                //console.log("mouse > " + globalMouse.x + " " + globalMouse.y)

                var xWas = control.x
                var yWas = control.y

                if (!control.boundVertical) {
                    if (control.boundToParent) {
                        if (globalMouse.x < 0) control.x = 0
                        else if (globalMouse.x > control.parent.width) control.x = control.parent.width
                        else control.x = globalMouse.x
                    }
                }
                if (!control.boundHorizontal) {
                    if (control.boundToParent) {
                        if (globalMouse.y < 0) control.y = 0
                        else if (globalMouse.y > control.parent.height) control.y = control.parent.height
                        else control.y = globalMouse.y
                    }
                }

                if (control.x != xWas || control.y != yWas) control.moved()
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: 40

            color: control.colorHighlight
            opacity: (parent.containsMouse || parent.pressed) ? 0.333 : 0
            Behavior on opacity { NumberAnimation { duration: 133 } }
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
