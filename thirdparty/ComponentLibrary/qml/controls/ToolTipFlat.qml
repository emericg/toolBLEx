import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.Popup {
    id: control

    x: {
        if (!parent) return 0
        if (positionInternal === "left") return -(width + 10)
        if (positionInternal === "right") return (parent.width + 10)

        var px = (parent.width - width) / 2
        if (positionInternal === "topRight" || positionInternal === "bottomRight") px = 0
        else if (positionInternal === "topLeft" || positionInternal === "bottomLeft") px = (parent.width - width)

        // clamp inside the window ourselves, so the arrow can follow the final position
        if (windowWidthInternal > 0) {
            px = Math.min(px, windowWidthInternal - margins - width - parentSceneXInternal)
            px = Math.max(px, margins - parentSceneXInternal)
        }
        return px
    }
    y: {
        if (!parent) return 0
        if (positionInternal === "top" || positionInternal === "topLeft" || positionInternal === "topRight") return -(height + 10)
        if (positionInternal === "bottom" || positionInternal === "bottomLeft" || positionInternal === "bottomRight") return (parent.height + 10)
        return ((parent.height / 2) - (height / 2))
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 6
    padding: 6

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    // settings
    property string text
    property string tooltipPosition: "bottom"

    // colors
    property color textColor: Theme.colorText
    property color backgroundColor: Theme.colorComponent

    // internal
    property string positionInternal: tooltipPosition
    property real parentSceneXInternal: 0
    property real windowWidthInternal: 0

    onAboutToShow: {
        positionInternal = tooltipPosition
        if (!parent || !parent.Window.window) return

        parentSceneXInternal = parent.mapToItem(null, 0, 0).x
        windowWidthInternal = parent.Window.width

        var thestart = parentSceneXInternal + (parent.width - width) / 2
        var theend = thestart + width + 24

        if (tooltipPosition === "top" || tooltipPosition === "bottom") {
            if (thestart < 0) positionInternal = tooltipPosition + "Right"
            else if (theend > windowWidthInternal) positionInternal = tooltipPosition + "Left"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Theme.animationSpeedFast; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Theme.animationSpeedFast; } }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        color: control.textColor
        font: control.font
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
    }

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: "white"
        radius: 4

        Rectangle { // arrow bg
            width: 12; height: 12; rotation: 45;
            color: "white"
            z: -1

            anchors.horizontalCenter: {
                if (control.positionInternal === "left") return parent.right
                if (control.positionInternal === "right") return parent.left
                return parent.horizontalCenter
            }
            anchors.horizontalCenterOffset: {
                if (!control.parent) return 0
                if (control.positionInternal === "left" || control.positionInternal === "right") return 0
                return (control.parent.width / 2) - (control.x + control.width / 2)
            }
            anchors.verticalCenter: {
                if (control.positionInternal === "left" || control.positionInternal === "right") return parent.verticalCenter
                if (control.positionInternal === "top" || control.positionInternal === "topLeft" || control.positionInternal === "topRight") return parent.bottom
                return parent.top
            }

            Rectangle { // colored arrow
                width: 12; height: 12; rotation: 0;
                color: control.backgroundColor
                anchors.centerIn: parent
            }
        }

        Rectangle { // actual background
            anchors.fill: parent
            color: control.backgroundColor
            radius: 4
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
