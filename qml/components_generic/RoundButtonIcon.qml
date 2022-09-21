import QtQuick 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: control
    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool selected: false

    // settings
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property int rotation: 0
    property string highlightMode: "circle" // available: border, circle, color, both (circle+color), off

    property bool border: false
    property bool background: false

    // colors
    property string iconColor: Theme.colorIcon
    property string highlightColor: Theme.colorPrimary
    property string borderColor: Theme.colorComponentBorder
    property string backgroundColor: Theme.colorComponent

    // animation
    property string animation // available: rotate, fade
    property bool animationRunning: false

    // tooltip
    property string tooltipText
    property string tooltipPosition: "bottom"

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mouseArea
        anchors.fill: control

        hoverEnabled: (isDesktop && control.enabled)
        propagateComposedEvents: false

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // background
        anchors.fill: control
        radius: width

        visible: (control.highlightMode === "circle" || control.highlightMode === "both" || control.background)
        color: control.backgroundColor

        border.width: {
            if (control.border || ((mouseArea.containsMouse || control.selected) && control.highlightMode === "border"))
                return Theme.componentBorderWidth
            return 0
        }
        border.color: control.borderColor

        opacity: {
            if (mouseArea.containsMouse) {
               return (control.highlightMode === "circle" || control.highlightMode === "both" || control.background) ? 1 : 0.75
            } else {
                return control.background ? 0.75 : 0
            }
        }
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    IconSvg { // contentItem
        width: control.sourceSize
        height: control.sourceSize
        anchors.centerIn: control

        rotation: control.rotation
        opacity: control.enabled ? 1.0 : 0.33
        Behavior on opacity { NumberAnimation { duration: 333 } }

        source: control.source
        color: {
            if ((control.selected || mouseArea.containsMouse) && (control.highlightMode === "color" || control.highlightMode === "both")) {
                return control.highlightColor
            }
            return control.iconColor
        }

        SequentialAnimation on opacity {
            running: (control.animation === "fade" && control.animationRunning)
            alwaysRunToEnd: true
            loops: Animation.Infinite

            PropertyAnimation { to: 0.33; duration: 750; }
            PropertyAnimation { to: 1; duration: 750; }
        }
        NumberAnimation on rotation {
            running: (control.animation === "rotate" && control.animationRunning)
            alwaysRunToEnd: true
            loops: Animation.Infinite

            duration: 1500
            from: 0
            to: 360
            easing.type: Easing.Linear
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        anchors.fill: control
        active: control.tooltipText

        sourceComponent: ToolTipFlat {
            visible: mouseArea.containsMouse
            text: control.tooltipText
            textColor: control.iconColor
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.backgroundColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
