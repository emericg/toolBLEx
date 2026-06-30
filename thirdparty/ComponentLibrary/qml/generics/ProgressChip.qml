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

    leftPadding: leftIcon.toString().length ? 2 : 12
    rightPadding: 16
    spacing: 6

    // settings
    focusPolicy: Qt.NoFocus
    font.pixelSize: Theme.componentFontSize
    font.bold: false

    // layout
    property int alignment: Qt.AlignCenter // Qt.AlignLeft // Qt.AlignRight

    // colors
    property color color: Theme.colorPrimary
    property color colorProgress: Qt.darker(Theme.colorPrimary, 1.04)

    // icon
    property url leftIcon
    property int leftIconSize: UtilsNumber.alignTo(height * 0.66, 2)
    property int leftIconRotation: 0
    property bool leftIconBackground: true

    // progress
    property int progress: 0

    ////////////////

    background: Item {
        implicitWidth: 128
        implicitHeight: Theme.componentHeight

        Rectangle { // background
            anchors.fill: parent
            radius: (height / 2)
            color: control.color
            opacity: 0.1
        }
        Rectangle { // progress
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: control.width * (Math.max(0, Math.min(control.progress, 100)) / 100)
            radius: (height / 2)
            color: control.colorProgress
            opacity: 0.2
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
        }
    }

    ////////////////
}
