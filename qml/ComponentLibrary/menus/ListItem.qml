import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl

import ThemeEngine

T.ItemDelegate {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: Theme.componentMargin
    spacing: Theme.componentMargin
    verticalPadding: 0

    property string source
    property string sourceColor: Theme.colorIcon
    property int sourceSize: 32

    //property string text
    property color textColor: Theme.colorText
    property int textSize: Theme.fontSizeContent

    ////////////////

    background: Rectangle {
        implicitHeight: Theme.componentHeightXL

        color: Theme.colorBackground
    }

    ////////////////

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: screenPaddingRight + Theme.componentMargin

        opacity: control.enabled ? 1 : 0.4
        spacing: 0

        Item {
            Layout.preferredWidth: appHeader.headerPosition - parent.anchors.leftMargin
            Layout.preferredHeight: Theme.componentHeightXL
            Layout.alignment: Qt.AlignTop

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: (32 - control.sourceSize) / 2
                anchors.verticalCenter: parent.verticalCenter
                //anchors.verticalCenterOffset: (control.height !== Theme.componentHeightXL) ? -(Theme.componentMargin / 2) : 0

                width: control.sourceSize
                height: control.sourceSize
                color: control.sourceColor
                source: control.source
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: control.text
            color: control.textColor
            wrapMode: Text.WordWrap
            font.pixelSize: control.textSize
            horizontalAlignment: Text.AlignJustify
        }
    }

    ////////////////
}
