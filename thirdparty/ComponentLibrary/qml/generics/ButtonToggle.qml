import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentRow.width + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12
    spacing: 6

    font.pixelSize: Theme.componentFontSize
    font.bold: false

    // settings
    flat: true
    checkable: true
    hoverEnabled: Theme.isDesktop
    focusPolicy: Qt.NoFocus

    // layout
    property int layoutAlignment: Qt.AlignCenter // Qt.AlignLeft // Qt.AlignRight
    property int layoutDirection: Qt.LeftToRight // Qt.RightToLeft
    property bool layoutFillWidth: false

    // icon
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // colors
    property color colorBackground: Theme.colorBackground
    property color colorHighlight: Theme.colorForeground
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.5)
    property color colorText: Theme.colorText

    ////////////////

    background: Item {
        implicitWidth: control.text ? 80 : Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            radius: Theme.componentRadius
            color: control.colorHighlight
            opacity: {
                if (control.checked && !control.down) return 1.0
                if (control.hovered && !control.down) return 0.66
                return 0
            }
            Behavior on opacity { NumberAnimation { duration: Theme.animationFastSpeed } }
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control
            clip: true
            clipRadius: Theme.componentRadius

            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: control.colorRipple
        }
    }

    ////////////////

    contentItem: Item {
        RowLayout {
            id: contentRow
            anchors.centerIn: parent

            spacing: control.spacing
            layoutDirection: control.layoutDirection

            IconSvg {
                Layout.maximumWidth: control.sourceSize
                Layout.maximumHeight: control.sourceSize
                Layout.alignment: Qt.AlignVCenter

                visible: control.source.toString().length
                color: control.colorText
                opacity: control.enabled ? 1 : 0.66
                rotation: control.sourceRotation

                source: control.source
            }

            Text {
                Layout.alignment: Qt.AlignVCenter

                color: control.colorText
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
