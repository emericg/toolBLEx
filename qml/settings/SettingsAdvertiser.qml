import QtQuick

import ComponentLibrary

Column { // BLE ADVERTISER

    width: 512
    spacing: 2

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorActionbar

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Advertiser")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVeryBig
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        IconSvg {
            width: 28
            height: 28
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            source: "qrc:/IconLibrary/material-icons/duotone/wifi_tethering.svg"
            color: Theme.colorIcon
        }
    }

    ////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorForeground

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.right: parent.right
            anchors.rightMargin: 64
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Start advertising automatically")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SwitchThemed {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            enabled: false
            //checked: SettingsManager.advAuto
            //onClicked: {
            //    SettingsManager.advAuto = checked
            //    if (!advManager.advertising) {
            //        advManager.advertising_start()
            //    }
            //}
        }
    }

    ////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorForeground

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.right: parent.right
            anchors.rightMargin: 64
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Pause advertising while in the background")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SwitchThemed {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            enabled: false
            //checked: SettingsManager.advPause
            //onClicked: SettingsManager.advPause = checked
        }
    }

    ///////
}
