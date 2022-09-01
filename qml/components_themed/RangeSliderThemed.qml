import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.RangeSlider {
    id: control
    implicitWidth: 200
    implicitHeight: Theme.componentHeight

    first.value: 0.25
    second.value: 0.75
    snapMode: T.RangeSlider.SnapAlways

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.colorForeground

        Rectangle {
            x: (control.first.visualPosition * parent.width)
            width: (control.second.visualPosition * parent.width) - x
            height: parent.height
            radius: 2
            color: Theme.colorPrimary
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + (first.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 18
        height: width
        radius: (width / 2)
        color: first.pressed ? Theme.colorSecondary : Theme.colorPrimary
        border.color: first.pressed ? Theme.colorSecondary : Theme.colorPrimary

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
                opacity: parent.containsMouse ? 0.2 : 0
                Behavior on opacity { NumberAnimation { duration: 233 } }
            }
        }
    }

    second.handle: Rectangle {
        x: control.leftPadding + (second.visualPosition * (control.availableWidth - width))
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        width: 18
        height: width
        radius: (width / 2)
        color: second.pressed ? Theme.colorSecondary : Theme.colorPrimary
        border.color: second.pressed ? Theme.colorSecondary : Theme.colorPrimary

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
                opacity: parent.containsMouse ? 0.2 : 0
                Behavior on opacity { NumberAnimation { duration: 233 } }
            }
        }
    }
}
