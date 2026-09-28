import QtQuick
import QtQuick.Layouts

import ComponentLibrary

ComboBoxThemed {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.right: parent.right

    height: Theme.componentHeight

    leftPadding: 16
    rightPadding: 16

    property url source
    property int sourceSize: 16

    property int contentSpacing: 12

    property string placeholderText: ""

    readonly property url leadingIconSource: control.hasCurrentIcon ? control.currentIconSource
                                                                    : control.source
    readonly property bool hasLeadingIcon: leadingIconSource.toString().length > 0

    font.bold: down

    property color color: down ? Theme.colorPrimary : Theme.colorSidebarContent
    colorBackground: Qt.rgba(color.r, color.g, color.b, down ? 0.2 : 1)
    colorBackgroundBorder: colorBackground

    property color colorContent: down ? Theme.colorPrimary : Theme.colorText
    property color colorHighlight: Theme.colorSidebarHighlight
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.16)

    ////////////////

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.height

        radius: control.radius
        opacity: control.enabled ? 1 : 0.66
        color: control.colorBackground
        border.width: 2
        border.color: control.colorBackgroundBorder

        RippleThemed {
            anchors.fill: parent
            anchor: control
            clip: true
            clipRadius: control.radius

            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple
        }
    }

    ////////////////

    indicator: Canvas {
        x: control.leftPadding + ((control.sourceSize - width) / 2)
        y: control.topPadding + ((control.availableHeight - height) / 2)
        width: control.sourceSize - 4
        height: control.sourceSize - 8
        visible: !control.hasLeadingIcon
        opacity: control.enabled ? 1 : 0.66
        rotation: control.popup.visible ? 180 : 0

        property color fillColor: control.colorContent
        onFillColorChanged: requestPaint()

        Connections {
            target: Theme
            function onCurrentThemeChanged() { control.indicator.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = fillColor
            ctx.fill()
        }
    }

    ////////////////

    contentItem: RowLayout {
        spacing: control.contentSpacing

        Item {
            Layout.preferredWidth: control.sourceSize
            Layout.preferredHeight: control.sourceSize
            Layout.alignment: Qt.AlignVCenter

            IconSvg {
                anchors.fill: parent

                visible: control.hasLeadingIcon
                source: control.leadingIconSource
                color: control.colorContent
                opacity: control.enabled ? 1 : 0.66
            }
        }

        Text {
            Layout.fillWidth: true

            verticalAlignment: Text.AlignVCenter

            text: control.displayText ? control.displayText : control.placeholderText
            textFormat: Text.PlainText

            font: control.font
            elide: Text.ElideRight

            color: control.colorContent
            opacity: control.enabled ? 1 : 0.66
        }
    }

    ////////////////
}
