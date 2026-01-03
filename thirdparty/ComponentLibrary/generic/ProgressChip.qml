import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: (implicitBackgroundWidth + leftInset + rightInset)
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
    property color colorBackground: Theme.colorComponentBackground // Theme.colorGrey

    // progress
    property int progress: 0

    // icons
    property string leftIcon
    property int leftIconSize: UtilsNumber.alignTo(height * 0.66, 2)
    property int leftIconRotation: 0
    property bool leftIconBackground: true

    property string rightIcon
    property int rightIconSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int rightIconRotation: 0
    property bool rightIconBackground: true

    ////////////////

    background: Item {
        implicitWidth: 128
        implicitHeight: Theme.componentHeight

        Rectangle {
            anchors.fill: parent
            radius: (height / 2)
            color: control.colorBackground
            opacity: 1
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: control.width * (control.progress / 100)
            radius: (height / 2)
            color: control.color
            opacity: 0.12
        }

        RippleThemed {
            anchors.fill: parent
            anchor: control

            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: Qt.rgba(control.color.r, control.color.g, control.color.b, 0.16)
        }

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

    ////////////////

    contentItem: Item {
        Item {
            width: control.height
            height: control.height
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            visible: control.leftIcon.length

            Rectangle {
                anchors.centerIn: parent
                width: control.height - 4
                height: width
                radius: width

                visible: control.leftIconBackground
                color: control.color
                opacity: 0.20
            }

            IconSvg {
                anchors.centerIn: parent
                width: control.leftIconSize
                height: control.leftIconSize
                rotation: control.leftIconRotation

                color: control.color
                source: control.leftIcon
            }
        }

    }

    ////////////////
}
