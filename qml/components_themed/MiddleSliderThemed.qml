import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Slider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight

    padding: 8

    value: 0.5

    ////////////////

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colorComponentBackground

        Rectangle {
            x: (handle.x < control.availableWidth / 2) ? handle.x : (control.width / 2)
            width: Math.abs((control.width / 2) - handle.x)
            height: parent.height
            radius: 2
            color: Theme.colorPrimary
        }
    }

    ////////////////

    handle: Rectangle {
        x: control.leftPadding + (control.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 18
        height: width
        radius: (width / 2)
        color: control.pressed ? Theme.colorSecondary : Theme.colorPrimary
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
