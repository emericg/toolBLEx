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

    leftPadding: (leftIcon.toString().length) ? 2 : 12
    rightPadding: (rightIcon.toString().length) ? 2 : 16
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
    property url leftIcon
    property int leftIconSize: UtilsNumber.alignTo(height * 0.66, 2)
    property int leftIconRotation: 0
    property bool leftIconBackground: true

    property url rightIcon
    property int rightIconSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int rightIconRotation: 0
    property bool rightIconBackground: true

    ////////////////

    background: Item {
        implicitWidth: Theme.componentHeight
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
            clip: true
            clipRadius: (control.background.height / 2)

            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus)
            color: Qt.rgba(control.color.r, control.color.g, control.color.b, 0.16)
        }
    }

    ////////////////

    contentItem: Item {
        RowLayout {
            id: contentRow
            anchors.centerIn: parent

            opacity: control.enabled ? 1 : 0.66
            spacing: control.spacing

            Item {
                Layout.preferredWidth: control.height
                Layout.preferredHeight: control.height
                Layout.alignment: Qt.AlignVCenter
                visible: control.leftIcon.toString().length

                Rectangle {
                    anchors.centerIn: parent
                    width: control.height - 6
                    height: width
                    radius: width

                    visible: control.leftIconBackground
                    color: control.color
                    opacity: 0.1
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
                visible: control.rightIcon.toString().length

                Rectangle {
                    anchors.centerIn: parent
                    width: control.height - 6
                    height: width
                    radius: width

                    visible: control.rightIconBackground
                    color: control.color
                    opacity: 0.1
                }

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
