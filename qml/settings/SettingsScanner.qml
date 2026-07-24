import QtQuick

import ComponentLibrary

Column { // BLE SCANNER

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

            text: qsTr("Scanner")
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

            source: "qrc:/IconLibrary/material-icons/duotone/devices.svg"
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
            anchors.right: selector_bluetoothmethods.left
            anchors.rightMargin: Theme.componentMarginL
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Bluetooth scanning method")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SelectorMenuColorful {
            id: selector_bluetoothmethods
            height: 32
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            model: ListModel {
                ListElement { idx: 2; txt: qsTr("BLE"); src: ""; sz: 16; }
                ListElement { idx: 1; txt: qsTr("Classic"); src: ""; sz: 16; }
                ListElement { idx: 3; txt: qsTr("Both"); src: ""; sz: 16; }
            }

            currentSelection: SettingsManager.scanMethods
            onMenuSelected: (index) => {
                SettingsManager.scanMethods = index
                deviceManager.scanDevices_restart(true)
            }
        }
    }

    ////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: txtScanLegend.height + 16
        color: Theme.colorForeground

        Text {
            id: txtScanLegend
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Scanning for both Classic and Low Energy at the same time usually means that your adapter will switch between scanning modes every couple of seconds, instead of scanning for both simultaneously.")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorSubText
            wrapMode: Text.WordWrap
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

            text: qsTr("Start scanning automatically")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SwitchThemed {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXS
            anchors.verticalCenter: parent.verticalCenter

            checked: SettingsManager.scanAuto
            onClicked: {
                SettingsManager.scanAuto = checked
                if (!deviceManager.scanning) {
                    deviceManager.scanDevices_start()
                }
            }
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

            text: qsTr("Pause scanning while in the background")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SwitchThemed {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXS
            anchors.verticalCenter: parent.verticalCenter

            checked: SettingsManager.scanPause
            onClicked: SettingsManager.scanPause = checked
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

            text: qsTr("Automatically save devices seen nearby")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SwitchThemed {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXS
            anchors.verticalCenter: parent.verticalCenter

            checked: SettingsManager.scanCacheAuto
            onClicked: SettingsManager.scanCacheAuto = checked
        }
    }

    ////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorForeground

        visible: (deviceManager.deviceSeenCached > 0)

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.right: parent.right
            anchors.rightMargin: 64
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMarginXL

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Device seen cache")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("%n device(s)", "", deviceManager.deviceSeenCached)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorText

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    z: -1
                    radius: Theme.componentRadius
                    color: Theme.colorSeparator
                }
            }
        }

        ButtonFlat {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Clear cache")
            onClicked: {
                popupLoader_cacheseen.active = true
                popupLoader_cacheseen.item.open()
            }
        }
    }

    ////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: Theme.colorForeground

        visible: (deviceManager.deviceStructureCached > 0)

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            anchors.right: parent.right
            anchors.rightMargin: 64
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMarginXL

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Device structure cache")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("%n device(s)", "", deviceManager.deviceStructureCached)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorText

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    z: -1
                    radius: Theme.componentRadius
                    color: Theme.colorSeparator
                }
            }
        }

        ButtonFlat {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Clear cache")
            onClicked: {
                popupLoader_cachestructure.active = true
                popupLoader_cachestructure.item.open()
            }
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
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Scanning timeout")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SpinBoxThemedDesktop {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            editable: false
            legend: "m"
            from: 0
            to: 10

            value: SettingsManager.scanTimeout
            onValueModified: {
                SettingsManager.scanTimeout = value
                restartScannerTimer.restart()
            }
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
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("RSSI graph interval")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: false
            color: Theme.colorText
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
        }

        SpinBoxThemedDesktop {
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMargin
            anchors.verticalCenter: parent.verticalCenter

            editable: false
            legend: "ms"
            from: 100
            to: 1000
            stepSize: 100

            value: SettingsManager.scanRssiInterval
            onValueModified: SettingsManager.scanRssiInterval = value
        }
    }

    ////////
}
