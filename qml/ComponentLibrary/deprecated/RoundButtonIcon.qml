import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property int sourceRotation: 0

    // settings
    property bool borderVisible: false
    property bool backgroundVisible: false
    property string highlightMode: "circle" // available: border, circle, color, both (circle+color), off

    // colors
    property color iconColor: Theme.colorIcon
    property color highlightColor: Theme.colorPrimary
    property color borderColor: Theme.colorComponentBorder
    property color backgroundColor: Theme.colorComponent

    // animation
    property string animation // available: rotate, fade
    property bool animationRunning: false

    // tooltip
    property string tooltipText
    property string tooltipPosition: "bottom"

    ////////////////

    background: Rectangle {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight
        radius: Theme.componentHeight

        visible: (control.highlightMode === "circle" || control.highlightMode === "both" || control.backgroundVisible)
        color: control.backgroundColor

        opacity: {
            if (control.hovered) {
               return (control.highlightMode === "circle" ||
                       control.highlightMode === "both" ||
                       control.backgroundVisible) ? 1 : 0.75
            } else if (control.highlightMode === "off") {
                return control.backgroundVisible ? 1 : 0
            } else {
                return control.backgroundVisible ? 0.75 : 0
            }
        }
        Behavior on opacity { NumberAnimation { duration: 333 } }

        Rectangle { // border
            anchors.fill: parent
            radius: width

            visible: control.borderVisible
            color: "transparent"
            border.width: Theme.componentBorderWidth
            border.color: control.borderColor
        }
    }

    ////////////////

    contentItem: Item {
        IconSvg {
            anchors.centerIn: parent

            width: control.sourceSize
            height: control.sourceSize

            rotation: control.sourceRotation
            opacity: control.enabled ? 1 : 0.66
            Behavior on opacity { NumberAnimation { duration: 333 } }

            source: control.source
            color: {
                if ((control.highlighted || control.hovered || control.pressed) &&
                    (control.highlightMode === "color" || control.highlightMode === "both")) {
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
    }

    ////////////////

    Loader {
        anchors.fill: control
        active: control.tooltipText

        sourceComponent: ToolTipFlat {
            visible: control.hovered
            text: control.tooltipText
            textColor: control.iconColor
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.backgroundColor
        }
    }

    ////////////////
}
