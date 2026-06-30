import QtQuick

import ComponentLibrary

Item { // padded separator
    anchors.left: parent.left
    anchors.right: parent.right
    height: Theme.componentMargin + 1

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: Theme.colorSeparator
    }
}
