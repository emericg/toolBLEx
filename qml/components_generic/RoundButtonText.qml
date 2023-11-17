import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Theme.componentHeight
    implicitHeight: Theme.componentHeight

    focusPolicy: Qt.NoFocus

    property int textSize: Math.round(width * 0.333)

    // settings
    property bool borderVisible: false
    property bool backgroundVisible: false
    property string highlightMode: "circle" // available: border, circle, color, both (circle+color), off

    // colors
    property string textColor: Theme.colorText
    property string highlightColor: Theme.colorPrimary
    property string borderColor: Theme.colorComponentBorder
    property string backgroundColor: Theme.colorComponent

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
               return (control.highlightMode === "circle" || control.highlightMode === "both" || control.backgroundVisible) ? 1 : 0.75
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

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        elide: Text.ElideMiddle
        font.bold: true
        font.pixelSize: control.textSize
        font.capitalization: Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: {
            if ((control.highlighted || control.hovered || control.pressed) &&
                (control.highlightMode === "color" || control.highlightMode === "both")) {
                return control.highlightColor
            }
            return control.textColor
        }

        opacity: control.enabled ? 1.0 : 0.33
        Behavior on opacity { NumberAnimation { duration: 333 } }
    }

    ////////////////

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

    ////////////////
}
