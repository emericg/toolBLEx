import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

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
        color: Theme.colorComponentBackground
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {
            x: control.horizontal ? ((handle.x < control.availableWidth / 2) ? handle.x : control.width / 2) : -1
            y: control.horizontal ? -1 : ((handle.y < control.availableHeight / 2) ? handle.y : control.height / 2)
            width: control.horizontal ? Math.abs((control.width / 2) - handle.x) : 6
            height: control.horizontal ? 6 : Math.abs((control.height / 2) - handle.y)

            radius: 2
            color: Theme.colorPrimary
        }
    }

    ////////////////

    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? (control.visualPosition * (control.availableWidth - width)) : (control.availableWidth - width))
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : (control.visualPosition * (control.availableHeight - height)))

        implicitWidth: 18
        implicitHeight: 18
        radius: 9

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
                Behavior on opacity { NumberAnimation { duration: 233 } }
            }
        }
    }

    ////////////////
}
