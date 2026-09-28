import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

Rectangle {
    id: control

    required property string title
    required property url icon
    property string subtitle: ""
    property color accentColor: Theme.colorPrimary

    signal clicked()

    height: 64
    radius: Theme.componentRadius

    color: rowArea.containsMouse ? Qt.darker(control.accentColor, 1.03) : control.accentColor
    Behavior on color { ColorAnimation { duration: 133 } }

    Rectangle { // round icon badge
        id: iconBadge
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter

        width: 40
        height: 40
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.25)

        IconSvg {
            anchors.centerIn: parent
            width: 24
            height: 24
            color: "white"
            source: control.icon
        }
    }

    Column {
        anchors.left: iconBadge.right
        anchors.leftMargin: Theme.componentMargin
        anchors.right: chevron.left
        anchors.rightMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            width: parent.width
            text: control.title
            textFormat: Text.PlainText
            color: "white"
            font.pixelSize: Theme.fontSizeContentBig
            font.bold: true
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            visible: (control.subtitle.length > 0)
            text: control.subtitle
            textFormat: Text.PlainText
            color: Qt.rgba(1, 1, 1, 0.75)
            font.pixelSize: Theme.fontSizeContentSmall
            elide: Text.ElideRight
        }
    }

    IconSvg {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter

        width: 24
        height: 24
        color: "white"
        source: "qrc:/IconLibrary/material-symbols/chevron_right.svg"
    }

    MouseArea {
        id: rowArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }
}
