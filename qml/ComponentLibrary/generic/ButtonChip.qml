import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ThemeEngine
import "qrc:/utils/UtilsNumber.js" as UtilsNumber

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            rowrowrow.width + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: leftIcon.length ? 2 : 12
    rightPadding: rightIcon.length ? 2 : 12
    spacing: 6

    // settings
    focusPolicy: Qt.NoFocus
    font.pixelSize: Theme.componentFontSize
    font.bold: false

    // layout
    property int alignment: Qt.AlignCenter // Qt.AlignLeft // Qt.AlignRight

    // colors
    property color color: Theme.colorPrimary

    // icons
    property string leftIcon
    property int leftIconSize: UtilsNumber.alignTo(height * 1.0, 2)
    property int leftIconRotation: 0
    property string rightIcon
    property int rightIconSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int rightIconRotation: 0

    ////////////////

    background: Item {
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        //radius: (height / 2)
        //color: "transparent"
        //border.width: Theme.componentBorderWidth
        //border.color: control.color

        Rectangle {
            anchors.fill: parent
            radius: (height / 2)
            color: control.color
            opacity: 0.1
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control

            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: Qt.rgba(control.color.r, control.color.g, control.color.b, 0.16)

            layer.enabled: true
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
                        radius: (background.height / 2)
                    }
                }
            }
        }
    }

    ////////////////

    contentItem: Item {
        RowLayout {
            id: rowrowrow
            anchors.centerIn: parent

            opacity: control.enabled ? 1 : 0.66
            spacing: control.spacing

            Item {
                Layout.preferredWidth: control.height
                Layout.preferredHeight: control.height
                Layout.alignment: Qt.AlignVCenter
                visible: control.leftIcon.length

                IconSvg {
                    anchors.centerIn: parent
                    width: control.leftIconSize
                    height: control.leftIconSize
                    rotation: control.leftIconRotation

                    color: control.color
                    source: control.leftIcon
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter

                visible: control.text
                text: control.text
                textFormat: Text.PlainText

                color: control.color
                font: control.font
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                Layout.preferredWidth: control.height
                Layout.preferredHeight: control.height
                Layout.alignment: Qt.AlignVCenter
                visible: control.rightIcon.length

                IconSvg {
                    anchors.centerIn: parent
                    width: control.rightIconSize
                    height: control.rightIconSize
                    rotation: control.rightIconRotation

                    color: control.color
                    source: control.rightIcon
                }
            }
        }
    }

    ////////////////
}
