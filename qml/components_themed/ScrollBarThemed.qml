import QtQuick 2.12
import QtQuick.Controls 2.12

import ThemeEngine 1.0

ScrollBar {
    id: control

    size: 0.3
    position: 0.2
    active: true
    orientation: Qt.Vertical

    contentItem: Rectangle {
        implicitWidth: 6
        implicitHeight: 100
        height: control.height
        anchors.margins: 0

        radius: 0
        color: control.pressed ? Theme.colorPrimary : Theme.colorSecondary
    }

    background: Rectangle {
        implicitWidth: 6
        implicitHeight: 100
        height: control.height

        color: Theme.colorForeground
    }
}
