import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Rectangle {
    id: logWidget
    height: Math.max(24, logTxt.contentHeight) + 12
    clip: false
    color: Theme.colorBox

    ////////

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 12

        color: {
            if (modelData.event === 1) return Theme.colorError
            if (modelData.event === 2) return Theme.colorMaterialGreen
            if (modelData.event === 3) return Theme.colorMaterialLime
            if (modelData.event === 4) return Theme.colorMaterialBlue
            if (modelData.event === 5) return Theme.colorMaterialLightBlue
            if (modelData.event === 6) return Theme.colorPrimary
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
            text: modelData.timestamp.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz")
            color: Theme.colorSubText
            font.pixelSize: Theme.fontSizeContentSmall
        }

        Text {
            id: logTxt
            Layout.fillWidth: true

            text: modelData.log
            color: Theme.colorText
            font.pixelSize: Theme.fontSizeContentSmall
            wrapMode: Text.WrapAnywhere
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
