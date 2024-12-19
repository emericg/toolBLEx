import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Slider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding)

    padding: 6

    ////////////////

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : 4
        implicitHeight: control.horizontal ? 4 : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: 2
        opacity: control.enabled ? 1 : 0.66
        color: Theme.colorComponentBackground
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {
            x: control.horizontal ? 0 : -1
            y: control.horizontal ? -1 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : 6
            height: control.horizontal ? 6 : control.position * parent.height

            radius: 2
            color: Theme.colorPrimary
        }
    }

    ////////////////

    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))

        implicitWidth: 18
        implicitHeight: 18
        radius: 9

        opacity: control.enabled ? 1 : 0.8
        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary
        border.width: 1
        border.color: Theme.colorPrimary

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            z: -1

            acceptedButtons: Qt.NoButton
            hoverEnabled: (isDesktop && control.enabled)
            propagateComposedEvents: false

            Rectangle {
                anchors.fill: parent
                radius: width
                color: Theme.colorPrimary
                opacity: (control.pressed || parent.containsMouse) ? 0.2 : 0
                Behavior on opacity { NumberAnimation { duration: 133 } }
            }
        }
    }

    ////////////////
}
