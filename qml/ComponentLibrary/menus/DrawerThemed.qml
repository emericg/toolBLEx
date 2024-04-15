import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

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
