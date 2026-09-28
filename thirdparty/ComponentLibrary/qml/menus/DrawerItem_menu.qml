import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import ComponentLibrary

T.ItemDelegate {
    id: control

    implicitWidth: parent.width
    implicitHeight: Theme.componentHeightL

    padding: Theme.componentMargin
    spacing: Theme.componentMargin
    verticalPadding: 0

    property url source
    property int sourceSize: 24
    property int sourceRotation: 0
    property color sourceColor: Theme.colorIcon

    property int textSize: Theme.fontSizeContentSmall
    property bool textBold: true
    property color textColor: Theme.colorText

    ////////////////

    background: Rectangle {
        implicitHeight: Theme.componentHeightL

        color: control.highlighted ? Theme.colorForeground : Theme.colorBackground

        RippleThemed {
            anchors.fill: parent
            anchor: control

            clip: visible
            pressed: control.pressed
            active: control.enabled && (control.down || control.visualFocus || control.hovered)
            color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.5)
        }
    }

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.screenPaddingLeft + Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.screenPaddingRight + Theme.componentMargin / 2

        opacity: control.enabled ? 1 : 0.66
        spacing: Theme.componentMargin

        Item {
            Layout.preferredWidth: Theme.componentHeightL - Theme.componentMargin
            Layout.preferredHeight: Theme.componentHeightL
            Layout.alignment: Qt.AlignTop

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: (32 - control.sourceSize) / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: (control.height !== Theme.componentHeightL) ? -(Theme.componentMargin / 2) : 0

                width: control.sourceSize
                height: control.sourceSize
                rotation: control.sourceRotation

                source: control.source
                color: control.sourceColor
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: control.text
            color: control.textColor
            font.bold: control.textBold
            font.pixelSize: control.textSize
            wrapMode: Text.WordWrap
        }
    }

    ////////////////
}
