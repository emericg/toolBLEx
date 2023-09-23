import QtQuick 2.15

import ThemeEngine 1.0

Item { // action menu separator
    anchors.left: parent.left
    anchors.leftMargin: Theme.componentMargin - 4
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentMargin - 4
    height: Theme.componentMargin - 4 + 1

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: Theme.colorSeparator
    }
}
