import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
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
    flat: true
    checkable: false
    hoverEnabled: isDesktop
    focusPolicy: Qt.NoFocus

    // layout
    property int layoutAlignment: Qt.AlignCenter // Qt.AlignLeft // Qt.AlignRight
    property bool layoutFillWidth: false

    // icon
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // colors
    property color colorBackground: Theme.colorPrimary
    property color colorHighlight: Theme.colorComponentBorder
    property color colorRipple: Qt.rgba(colorHighlight.r, colorHighlight.g, colorHighlight.b, 0.16)
    property color colorText: "white"

    ////////////////

    background: Item {
        implicitWidth: text ? 80 : Theme.componentHeight
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            color: control.colorBackground
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control

            pressed: control.pressed
            active: control.enabled && (control.down || control.hovered || control.visualFocus)
            color: control.colorRipple
            clip: true

            layer.enabled: false
            layer.effect: MultiEffect {
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: Theme.componentRadius
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: Item {

        RowLayout {
            id: rowrowrow
            anchors.left: (control.layoutFillWidth && control.layoutAlignment !== Qt.AlignCenter) ? parent.left : undefined
            anchors.right: (control.layoutFillWidth || control.layoutAlignment === Qt.AlignRight) ? parent.right : undefined
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            spacing: control.spacing

            Item {
                Layout.preferredWidth: control.sourceSize
                Layout.preferredHeight: control.sourceSize
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: (control.layoutFillWidth)

                visible: control.source.toString().length

                IconSvg {
                    width: control.sourceSize
                    height: control.sourceSize

                    source: control.source
                    color: control.colorText
                    opacity: control.enabled ? 1 : 0.66
                    rotation: control.sourceRotation
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: control.sourceSize

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
