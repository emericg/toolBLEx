import QtQuick 2.15

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: control
    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    property string text
    property int textSize: Math.round(width * 0.333)

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool selected: false

    // settings
    property bool border: false
    property bool background: false
    property string highlightMode: "circle" // available: border, circle, color, both (circle+color), off

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

        opacity: {
            if (mouseArea.containsMouse) {
               return (control.highlightMode === "circle" || control.highlightMode === "both" || control.background) ? 1 : 0.75
            } else {
                return control.background ? 0.75 : 0
            }
        }
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }
    Rectangle { // border
        anchors.fill: control
        radius: width

        visible: control.border
        color: "transparent"
        border.width: Theme.componentBorderWidth
        border.color: control.borderColor
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
            if ((control.selected || mouseArea.containsMouse) && (control.highlightMode === "color" || control.highlightMode === "both")) {
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
            visible: mouseArea.containsMouse
            text: control.tooltipText
            textColor: control.textColor
            tooltipPosition: control.tooltipPosition
            backgroundColor: control.backgroundColor
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
