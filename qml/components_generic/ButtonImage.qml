import QtQuick 2.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    // actions
    signal clicked()
    signal pressAndHold()

    // states
    property bool hovered: false
    property bool pressed: false

    // image
    property url source
    property int sourceSize: 32

    // settings
    property string hoverMode: "off" // available: off, circle, glow
    property string highlightMode: "off" // available: off

    // colors
    property string highlightColor: Theme.colorPrimary

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        hoverEnabled: (isDesktop && control.enabled)

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: control.pressed = true
        onReleased: control.pressed = false

        onEntered: control.hovered = true
        onExited: control.hovered = false
        onCanceled: {
            control.hovered = false
            control.pressed = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: bgRect
        anchors.fill: contentImage
        anchors.margins: -8
        enabled: (control.hoverMode === "circle")
        visible: (control.hoverMode === "circle")

        radius: control.width
        color: control.highlightColor

        opacity: control.hovered ? 0.33 : 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }
    }
    Glow {
        id: bgGlow
        anchors.fill: contentImage
        enabled: (control.hoverMode === "glow")
        visible: (control.hoverMode === "glow")

        source: contentImage
        color: control.highlightColor
        radius: 24
        cached: true
        //samples: 16
        transparentBorder: true

        opacity: control.hovered ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 333 } }
    }

    ////////////////////////////////////////////////////////////////////////////

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
