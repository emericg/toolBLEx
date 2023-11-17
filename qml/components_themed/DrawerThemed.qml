import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.Drawer {
    id: control

    parent: T.Overlay.overlay

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    width: (appWindow.singleColumn || appWindow.screenOrientation === Qt.PortraitOrientation || appWindow.width < 480)
            ? 0.8 * appWindow.width : 0.5 * appWindow.width
    height: appWindow.height

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0

    enter: Transition { SmoothedAnimation { velocity: 5 } }
    exit: Transition { SmoothedAnimation { velocity: 5 } }

    T.Overlay.modal: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.5)
    }

    T.Overlay.modeless: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.12)
    }

    ////////////////

    background: Rectangle {
        color: Theme.colorBackground

        Rectangle { // left border line
            x: parent.width
            width: 1
            height: parent.height
            color: Theme.colorSeparator
        }
    }

    ////////////////
}
