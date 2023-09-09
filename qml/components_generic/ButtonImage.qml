import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    // image
    property url source
    property int sourceSize: 32

    // settings
    property string hoverMode: "off" // available: off, circle, glow
    property string highlightMode: "off" // available: off

    // colors
    property string highlightColor: Theme.colorPrimary

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Glow {
            anchors.centerIn: parent
            width: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))
            height: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))

            visible: (control.hoverMode === "glow")

            source: contentImage
            color: control.highlightColor
            radius: 12
            cached: true
            //samples: 16
            transparentBorder: true

            opacity: control.hovered ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))
            height: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))

            //visible: (control.hoverMode === "circle")

            radius: control.width
            color: control.highlightColor

            opacity: control.hovered ? 0.33 : 0
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }
    }

    ////////////////

    contentItem: Item {
        Image {
            id: contentImage
            anchors.centerIn: parent

            width: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))
            height: Math.round(control.sourceSize * (control.pressed ? 0.9 : 1))

            source: control.source
            sourceSize: Qt.size(control.sourceSize, control.sourceSize)
            fillMode: Image.PreserveAspectFit

            opacity: enabled ? 1.0 : 0.4
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }
    }

    ////////////////
}
