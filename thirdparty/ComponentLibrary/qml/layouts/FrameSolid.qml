import QtQuick
import QtQuick.Templates as T

import ComponentLibrary

T.Frame {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 12
    topPadding: control.headerHeight + padding

    // header
    property string title
    property url source
    property int headerHeight: Theme.componentHeight + 8

    // colors
    property color colorHeader: Theme.colorPrimary
    property color colorHeaderContent: UtilsColor.contrastColor(control.colorHeader)
    property color colorBackground: Theme.colorForeground
    property color colorBorder: Theme.colorSeparator

    ////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        color: control.colorBackground
        border.width: 2
        border.color: control.colorBorder

        Rectangle { // header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: control.headerHeight

            topLeftRadius: Theme.componentRadius
            topRightRadius: Theme.componentRadius
            color: control.colorHeader

            Row {
                id: header
                anchors.fill: parent
                anchors.leftMargin: control.padding + 4
                anchors.rightMargin: control.padding
                spacing: 12

                IconSvg {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24

                    visible: (control.source.toString().length > 0)
                    source: control.source
                    color: control.colorHeaderContent
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: header.width - x

                    text: control.title
                    textFormat: Text.PlainText
                    color: control.colorHeaderContent
                    font.pixelSize: Theme.fontSizeContentBig
                    font.bold: true
                    elide: Text.ElideRight
                }
            }
        }
    }

    ////////////////
}
