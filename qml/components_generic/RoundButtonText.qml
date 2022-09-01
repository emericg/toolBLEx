import QtQuick 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

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
    property bool selected: false

    // settings
    property string text
    property int textSize: Math.round(width * 0.33)
    property string highlightMode: "circle" // available: border, circle, color, both (circle+color), off

    property bool border: false
    property bool background: false

    // colors
    property string textColor: Theme.colorText
    property string highlightColor: Theme.colorPrimary
    property string borderColor: Theme.colorComponentBorder
    property string backgroundColor: Theme.colorComponent

    // tooltip
    property string tooltipText
    property string tooltipPosition: "bottom"

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: control

        hoverEnabled: (isDesktop && control.enabled)
        propagateComposedEvents: false

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: control.pressed = true
        onReleased: control.pressed = false

        onEntered: control.hovered = true
        onExited: control.hovered = false
        onCanceled: {
            control.pressed = false
            control.hovered = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // background
        anchors.fill: control
        radius: width

        visible: (control.highlightMode === "circle" || control.highlightMode === "both" || control.background)
        color: control.backgroundColor

        border.width: {
            if (control.border || ((control.hovered || control.selected) && control.highlightMode === "border"))
                return Theme.componentBorderWidth
            return 0
        }
        border.color: control.borderColor

        opacity: {
            if (control.hovered) {
               return (control.highlightMode === "circle" || control.highlightMode === "both" || control.background) ? 1 : 0.75
            } else {
                return control.background ? 0.75 : 0
            }
        }
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    Text { // contentText
        anchors.fill: control

        opacity: control.enabled ? 1.0 : 0.33
        Behavior on opacity { NumberAnimation { duration: 333 } }

        text: control.text
        textFormat: Text.PlainText
        elide: Text.ElideMiddle
        font.bold: true
        font.pixelSize: control.textSize
        font.capitalization: Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: {
            if ((control.selected || control.hovered) && (control.highlightMode === "color" || control.highlightMode === "both")) {
                return control.highlightColor
            }
            return control.textColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        anchors.fill: control
        active: control.tooltipText

        sourceComponent: ToolTipFlat {
            visible: control.hovered
            text: control.tooltipText
            textColor: control.textColor
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.backgroundColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
