import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.TabButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            rowrowrow.width + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12
    spacing: 6

    font.pixelSize: Theme.componentFontSize
    font.bold: false

    // settings
    hoverEnabled: isDesktop
    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)

    // colors
    property color colorBackground: Theme.colorForeground
    property color colorBackgroundChecked: Theme.colorPrimary
    property color colorHighlight: Theme.colorComponentBorder
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.16)
    property color colorText: Theme.colorText
    property color colorTextChecked: "white"

    readonly property color colorContent: checked ? colorTextChecked : colorText

    ////////////////

    background: Item {
        implicitWidth: control.text ? 80 : Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            color: control.checked ? control.colorBackgroundChecked : control.colorBackground
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control

            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple
            clip: true
        }
    }

    ////////////////

    contentItem: Item {

        RowLayout {
            id: rowrowrow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            spacing: control.spacing

            IconSvg {
                Layout.preferredWidth: control.sourceSize
                Layout.preferredHeight: control.sourceSize
                Layout.alignment: Qt.AlignVCenter

                visible: control.source.toString().length

                source: control.source
                color: control.colorContent
                opacity: control.enabled ? 1 : 0.66
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: control.sourceSize

                color: control.colorContent
                opacity: control.enabled ? 1 : 0.66

                visible: control.text
                text: control.text
                textFormat: Text.PlainText

                font: control.font
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ////////////////
}
