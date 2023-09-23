import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0

T.ScrollBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    visible: control.policy !== T.ScrollBar.AlwaysOff
    minimumSize: orientation === Qt.Horizontal ? height / width : width / height

    states: State {
        name: "active"
        when: control.policy === T.ScrollBar.AlwaysOn || (control.active && control.size < 1.0)
        PropertyChanges { control.background.opacity: 0.75 }
        PropertyChanges { control.contentItem.opacity: 0.75 }
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
        implicitWidth: orientation === Qt.Vertical ? 12 : 100
        implicitHeight: orientation === Qt.Vertical ? 100 : 12

        x: control.leftPadding
        width: control.width - control.leftPadding - control.rightPadding

        y: control.topPadding
        height: control.height - control.topPadding - control.bottomPadding

        color: Theme.colorForeground
        opacity: 0.0
    }

    ////////////////

    contentItem: Rectangle {
        implicitWidth: control.interactive ? 12 : 6
        implicitHeight: control.interactive ? 12 : 6

        color: control.pressed ? Theme.colorSecondary : control.palette.mid // Qt.darker(Theme.colorForeground, 1.1)
        opacity: 0.0
    }

    ////////////////
}
