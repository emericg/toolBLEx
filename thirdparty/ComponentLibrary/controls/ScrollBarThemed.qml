import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.ScrollBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 0
    rightPadding: 0

    visible: (policy !== T.ScrollBar.AlwaysOff)

    minimumSize: (orientation === Qt.Horizontal) ? (height / width) : (width / height)

    property int radius: isDesktop ? 0 : 0

    property int sz: isDesktop ? 12 : 20

    property color colorBackground: Theme.colorBackground
    property color colorMoving: Theme.colorSecondary
    property color colorPressed: Theme.colorPrimary

    ////////////////

    states: State {
        name: "active"
        when: (control.policy === T.ScrollBar.AlwaysOn) || (control.active && control.size < 1.0)
        PropertyChanges { control.background.opacity: 0.77 }
        PropertyChanges { control.contentItem.opacity: 0.66 }
    }

    transitions: Transition {
        from: "active"
        SequentialAnimation {
            PauseAnimation { duration: 450 }
            NumberAnimation { target: control.background; duration: 200; property: "opacity"; to: 0.0 }
            NumberAnimation { target: control.contentItem; duration: 200; property: "opacity"; to: 0.0 }
        }
    }

    ////////////////

    background: Rectangle {
        implicitWidth: orientation === Qt.Vertical ? control.sz : 100
        implicitHeight: orientation === Qt.Vertical ? 100 : control.sz

        x: control.leftPadding
        width: control.width - control.leftPadding - control.rightPadding

        y: control.topPadding
        height: control.height - control.topPadding - control.bottomPadding

        radius: control.radius
        color: control.colorBackground
        opacity: 0.0
    }

    ////////////////

    contentItem: Rectangle {
        implicitWidth: control.interactive ? control.sz : (control.sz/2)
        implicitHeight: control.interactive ? control.sz : (control.sz/2)

        radius: control.radius
        color: control.pressed ? control.colorPressed : control.colorMoving
        opacity: 0.0
    }

    ////////////////
}
