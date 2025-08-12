import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Popup {
    id: control

    x: {
        if (tooltipPosition === "left") return -(implicitWidth + 10)
        if (tooltipPosition === "right") return +(parent.width + 10)
        if (tooltipPosition === "topRight" || tooltipPosition === "bottomRight") return 0
        if (tooltipPosition === "topLeft" || tooltipPosition === "bottomLeft") return (parent.width - implicitWidth)
        return (parent.width - implicitWidth) / 2
    }
    y: {
        if (tooltipPosition === "top" || tooltipPosition === "topLeft" || tooltipPosition === "topRight") return -(implicitHeight + 10)
        if (tooltipPosition === "bottom" || tooltipPosition === "bottomLeft" || tooltipPosition === "bottomRight") return (parent.height + 10)
        return ((parent.height / 2) - (implicitHeight / 2))
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 6
    padding: 6

    // settings
    property string text
    property string tooltipPosition

    // colors
    property color textColor: Theme.colorText
    property color backgroundColor: Theme.colorComponent

    onVisibleChanged: {
        if (!visible) return

        var obj = mapToItem(appContent, x, y)
        var thestart = obj.x
        var theend = obj.x + implicitWidth + 24
        //console.log("checking tooltip position: " + thestart + " > " + theend)

        if (tooltipPosition === "top") {
            if (thestart < 0) {
                tooltipPosition = "topRight"
            } else if (theend > appContent.width) {
                tooltipPosition = "topLeft"
            } else {
                tooltipPosition = "top"
            }
        } else if (tooltipPosition === "bottom") {
            if (thestart < 0) {
                tooltipPosition = "bottomRight"
            } else if (theend > appContent.width) {
                tooltipPosition = "bottomLeft"
            } else {
                tooltipPosition = "bottom"
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText

        font: control.font
        wrapMode: Text.Wrap
        color: control.textColor
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
                if (tooltipPosition === "left") return parent.right
                if (tooltipPosition === "right") return parent.left
                return parent.horizontalCenter
            }
            anchors.horizontalCenterOffset: {
                if (tooltipPosition === "topLeft" || tooltipPosition === "bottomLeft") return (control.implicitWidth / 2) - (control.parent.width / 2)
                if (tooltipPosition === "topRight" || tooltipPosition === "bottomRight") return -(control.implicitWidth / 2) + (control.parent.width / 2)
                return 0
            }
            anchors.verticalCenter: {
                if (tooltipPosition === "bottom" || tooltipPosition === "bottomLeft" || tooltipPosition === "bottomRight") return parent.top
                if (tooltipPosition === "top" || tooltipPosition === "topLeft" || tooltipPosition === "topRight") return parent.bottom
                if (tooltipPosition === "left" || tooltipPosition === "right") return parent.verticalCenter
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
