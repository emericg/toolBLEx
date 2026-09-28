import QtQuick

import ComponentLibrary

TagImpl {
    id: control

    leftPadding: (control.source.toString().length > 0) ? 6 : 8

    property color color: Theme.colorPrimary

    property url source: "qrc:/ComponentLibraryAssets/icons/label.svg"
    property color colorIcon: control.color
    property int iconSize: Math.round(control.font.pixelSize * 1.2)

    colorBackground: Qt.rgba(color.r, color.g, color.b, 0.2)
    colorBorder: colorBackground
    colorText: color

    ////////////////

    contentItem: Row {
        spacing: 4

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter
            width: control.iconSize
            height: control.iconSize

            visible: (control.source.toString().length > 0)
            source: control.source
            color: control.colorIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            textFormat: Text.PlainText

            color: control.colorText
            font: control.font
        }
    }

    ////////////////
}
