import QtQuick 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0

Item {
    id: actionMenuItem
    anchors.left: parent.left
    anchors.leftMargin: Theme.componentBorderWidth
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentBorderWidth
    height: 36

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

        onClicked: {
            background.opacity = 1
            actionMenuItem.clicked()
        }
        onPressAndHold: {
            background.opacity = 1
            actionMenuItem.pressAndHold()
        }

        onEntered: background.opacity = 1
        onExited: background.opacity = 0
        onCanceled: background.opacity = 0
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.leftMargin: Theme.componentMargin/2
        anchors.rightMargin: Theme.componentMargin/2

        radius: Theme.componentMargin/2
        opacity: 0
        color: Theme.colorForeground
        Behavior on opacity { OpacityAnimator { duration: 333 } }
        //Behavior on color { ColorAnimation { duration: 133 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.componentMargin
        anchors.rightMargin: Theme.componentMargin

        spacing: Theme.componentMargin/2
        layoutDirection: actionMenuItem.layoutDirection

        IconSvg {
            id: iButton
            Layout.preferredWidth: actionMenuItem.sourceSize
            Layout.preferredHeight: actionMenuItem.sourceSize

            source: actionMenuItem.source
            color: Theme.colorIcon
        }

        Text {
            id: tButton
            Layout.fillWidth: true
            Layout.preferredHeight: actionMenuItem.sourceSize

            text: actionMenuItem.text
            textFormat: Text.PlainText
            font.bold: false
            font.pixelSize: Theme.componentFontSize
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: Theme.colorText
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
