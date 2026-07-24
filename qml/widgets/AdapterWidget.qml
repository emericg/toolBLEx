import QtQuick
import QtQuick.Layouts

import ComponentLibrary

Rectangle {
    id: adapterWidget
    height: box.height + 28
    radius: 4

    clip: false
    color: Theme.colorBox
    border.width: 2
    border.color: Theme.colorBoxBorder

    ////////////////

    Rectangle { // yellow bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 8
        radius: 2
        color: Theme.colorPrimary
        visible: modelData.isInUse
    }

    ////////////////

    Column {
        id: box
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMarginL
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginS
        anchors.verticalCenter: parent.verticalCenter

        ////////

        property int legendWidth: 64
        property int legendHeight: 24

        Component.onCompleted: {
            legendWidth = 64
            legendWidth = Math.max(legendWidth, legendHostname.contentWidth)
            legendWidth = Math.max(legendWidth, legendChipset.contentWidth)
            legendWidth = Math.max(legendWidth, legendChipsetFirmware.contentWidth)
            legendWidth = Math.max(legendWidth, legendVendor.contentWidth)
            legendWidth = Math.max(legendWidth, legendAddress.contentWidth)
            legendWidth = Math.max(legendWidth, legendAddressVendor.contentWidth)
            legendWidth = Math.max(legendWidth, legendBluetooth.contentWidth)
            legendWidth = Math.max(legendWidth, legendFeatures.contentWidth)
            legendWidth = Math.max(legendWidth, legendHostMode.contentWidth)
        }

        ////////

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginL
            height: 32

            text: qsTr("Bluetooth adapter #%1").arg(index+1)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.colorText
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            Text {
                id: legendHostname
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("Hostname")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: box.legendHeight

                text: modelData.hostname
                wrapMode: Text.WrapAnywhere
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: modelData.chipset.length

            Text {
                id: legendChipset
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("Chipset")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: box.legendHeight

                text: modelData.chipset
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: modelData.chipsetFirmware.length

            Text {
                id: legendChipsetFirmware
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("Firmware")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: box.legendHeight

                text: modelData.chipsetFirmware
                wrapMode: Text.WrapAnywhere
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: modelData.manufacturer.length

            Text {
                id: legendVendor
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("Manufacturer")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: box.legendHeight

                text: modelData.manufacturer
                wrapMode: Text.WrapAnywhere
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            Text {
                id: legendAddress
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("MAC address")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: box.legendHeight

                text: modelData.address
                wrapMode: Text.WrapAnywhere
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: modelData.manufacturerMac.length

            Text {
                id: legendAddressVendor
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("MAC vendor")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: box.legendHeight

                text: modelData.manufacturerMac
                wrapMode: Text.WrapAnywhere
            }
        }

        ////////

        Row {
            height: 32
            spacing: Theme.componentMarginS

            visible: modelData.bluetoothVersion.length

            Text {
                id: legendBluetooth
                anchors.verticalCenter: parent.verticalCenter
                width: box.legendWidth

                text: qsTr("Bluetooth")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TagDesktop {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.bluetoothVersion
                colorBackground: Theme.colorComponent
                colorBorder: Theme.colorComponent
            }
        }

        ////////

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: modelData.bluetoothFeatures.length

            Text {
                id: legendFeatures
                Layout.preferredWidth: box.legendWidth
                Layout.preferredHeight: 32

                text: qsTr("Features")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: Theme.colorSubText
            }

            Flow {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: modelData.bluetoothFeatures
                    TagDesktop {
                        text: modelData
                        colorBackground: Theme.colorComponent
                        colorBorder: Theme.colorComponent
                    }
                }
            }
        }

        ////////

        Row {
            height: 32
            spacing: Theme.componentMarginS

            Text {
                id: legendHostMode
                anchors.verticalCenter: parent.verticalCenter
                width: box.legendWidth

                text: qsTr("Host mode")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TagDesktop {
                anchors.verticalCenter: parent.verticalCenter
                text: UtilsBluetooth.getBluetoothAdapterModeText(modelData.hostMode)
                colorBackground: Theme.colorComponent
                colorBorder: Theme.colorComponent
            }
        }

        ////////
    }

    ////////////////

    Rectangle { // bluetooth icon
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginL
        anchors.verticalCenter: parent.verticalCenter

        width: 96
        height: 96
        radius: 96

        color: Theme.colorBackground
        visible: (adapterWidget.width > 400)
/*
        Rectangle { // scanning indicator
            id: circlePulseAnimation
            anchors.centerIn: parent

            width: 96
            height: 96
            radius: 96
            z: -1

            color: Theme.colorPrimary
            visible: (modelData.isInUse &&
                      deviceManager.scanning && !deviceManager.scanningPaused &&
                      appContent.state === "Scanner" && hostMenu.currentSelection === 1)

            ParallelAnimation {
                running: visible
                alwaysRunToEnd: true
                loops: Animation.Infinite

                NumberAnimation { target: circlePulseAnimation; property: "width"; from: 96; to: 128; duration: 1500; }
                NumberAnimation { target: circlePulseAnimation; property: "height"; from: 96; to: 128; duration: 1500; }
                OpacityAnimator { target: circlePulseAnimation; from: 0.33; to: 0; duration: 1000; }
            }
        }
*/
        IconSvg {
            anchors.centerIn: parent
            width: 64
            height: 64

            source: "qrc:/IconLibrary/bootstrap/bluetooth.svg"
            color: Theme.colorSubText
        }
    }

    ////////////////

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.componentMarginS
        spacing: Theme.componentMarginS

        visible: (deviceManager.adaptersCount > 1)

        SquareButtonClear { // scanning
            property bool selected: (SettingsManager.preferredAdapter_scan === modelData.address)

            tooltipText: qsTr("Default for scanning")
            color: selected ? Theme.colorPrimary : Theme.colorGrey
            source: selected ? "qrc:/IconLibrary/material-symbols/check_circle-fill.svg"
                             : "qrc:/IconLibrary/material-symbols/check_circle.svg"

            onClicked: {
                if (selected) {
                    SettingsManager.preferredAdapter_scan = ""
                } else {
                    SettingsManager.preferredAdapter_scan = modelData.address
                    //deviceManager.disableBluetooth()
                }
            }
        }

        SquareButtonClear { // advertising
            property bool selected: (SettingsManager.preferredAdapter_adv === modelData.address)

            tooltipText: qsTr("Default for advertising")
            color: selected ? Theme.colorPrimary : Theme.colorGrey
            source: selected ? "qrc:/IconLibrary/material-symbols/check_circle-fill.svg"
                             : "qrc:/IconLibrary/material-symbols/check_circle.svg"

            onClicked: {
                if (selected) {
                    SettingsManager.preferredAdapter_adv = ""
                } else {
                    SettingsManager.preferredAdapter_adv = modelData.address
                    //deviceManager.disableBluetooth()
                }
            }
        }
    }

    ////////////////
}
