import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Rectangle {
    id: logWidget

    height: Math.max(24, logTxt.contentHeight) + 12
    color: Theme.colorBox
    clip: false

    ////////

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 12

        color: {
            if (model.event === 1) return Theme.colorError
            if (model.event === 2) return Theme.colorMaterialGreen
            if (model.event === 3) return Theme.colorMaterialLime
            if (model.event === 4) return Theme.colorMaterialBlue
            if (model.event === 5) return Theme.colorMaterialLightBlue
            if (model.event === 6) return Theme.colorPrimary
            return Theme.colorBox
        }
    }

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Text {
            text: model.timestamp.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentSmall
            color: Theme.colorSubText
        }

        TextSelectable {
            id: logTxt
            Layout.fillWidth: true

            text: log
            font.pixelSize: Theme.fontSizeContentSmall
            wrapMode: Text.WrapAnywhere
            color: Theme.colorText
        }
    }

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 2
        color: Theme.colorBoxBorder
    }

    ////////
}
