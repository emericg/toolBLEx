import QtQuick 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0

Rectangle {
    id: actionMenuItem
    height: 34

    anchors.left: parent.left
    anchors.leftMargin: Theme.componentBorderWidth
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentBorderWidth

    radius: 0
    color: "transparent"

    // actions
    signal clicked()
    signal pressAndHold()

    // settings
    property int index
    property string text
    property url source
    property int sourceSize: 20
    property int layoutDirection: Qt.RightToLeft

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: (isDesktop && enabled)

        onClicked: actionMenuItem.clicked()
        onPressAndHold: actionMenuItem.pressAndHold()

        onEntered: actionMenuItem.state = "hovered"
        onExited: actionMenuItem.state = "normal"
        onCanceled: actionMenuItem.state = "normal"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        spacing: 6
        layoutDirection: actionMenuItem.layoutDirection

        IconSvg {
            id: iButton
            width: actionMenuItem.sourceSize
            height: actionMenuItem.sourceSize
            Layout.maximumWidth: actionMenuItem.sourceSize
            Layout.maximumHeight: actionMenuItem.sourceSize

            source: actionMenuItem.source
            color: Theme.colorIcon
        }

        Text {
            id: tButton

            Layout.fillWidth: true

            text: actionMenuItem.text
            font.bold: false
            font.pixelSize: Theme.fontSizeComponent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: Theme.colorText
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    states: [
        State {
            name: "normal";
            PropertyChanges { target: actionMenuItem; color: "transparent"; }
        },
        State {
            name: "hovered";
            PropertyChanges { target: actionMenuItem; color: Theme.colorForeground; }
        }
    ]

    ////////////////////////////////////////////////////////////////////////////
}
