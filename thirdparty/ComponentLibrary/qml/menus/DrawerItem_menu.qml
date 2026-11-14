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

    property int headerPosition: 64

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
        }
    }

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.screenPaddingLeft
        anchors.right: parent.right
        anchors.rightMargin: Theme.screenPaddingRight + Theme.componentMargin / 2

        opacity: control.enabled ? 1 : 0.66
        spacing: 0

        Item {
            Layout.preferredWidth: control.headerPosition
            Layout.preferredHeight: Theme.componentHeightL
            Layout.alignment: Qt.AlignTop

            IconSvg {
                anchors.horizontalCenter: parent.horizontalCenter
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
