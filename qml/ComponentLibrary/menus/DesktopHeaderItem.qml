import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine

T.Button {
    id: control

    implicitWidth: 64
    implicitHeight: 64

    width: Math.max(parent.height, content.width + 32)
    height: parent.height // height drive the size of this element

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: 32
    property string highlightMode: "background" // available: background, indicator, content

    // colors
    property color colorContent: Theme.colorHeaderContent
    property color colorHighlight: Theme.colorHeaderHighlight
    property color colorRipple: Qt.rgba(colorContent.r, colorContent.g, colorContent.b, 0.08)

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: 64

        width: (control.highlightMode === "circle") ? height : parent.width
        height: parent.height
        radius: (control.highlightMode === "circle") ? width : 0

        visible: (control.highlightMode === "background" ||
                  control.highlightMode === "indicator" ||
                  control.highlightMode === "circle")
        color: control.colorHighlight
        opacity: {
            if (control.highlighted) return 1
            if (control.hovered) return 0.5
            return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 233 } }

        RippleThemed {
            anchors.fill: parent
            anchor: control
            clip: true

            pressed: control.pressed
            active: control.enabled && control.down
            color: control.colorRipple
        }

        Rectangle { // backgroundIndicator
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            width: 6
            visible: (control.highlighted && control.highlightMode === "indicator")
            color: Theme.colorPrimary
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        IconSvg {
            width: control.sourceSize
            height: control.sourceSize

            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            visible: source.toString().length

            source: control.source
            color: (!control.highlighted && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            opacity: control.enabled ? 1 : 0.66
        }

        Text {
            height: parent.height

            visible: text

            text: control.text
            textFormat: Text.PlainText
            color: (!control.highlighted && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            font.pixelSize: Theme.componentFontSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
