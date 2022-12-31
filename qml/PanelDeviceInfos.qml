import QtQuick
import QtQuick.Controls

import Qt.labs.platform

import ThemeEngine 1.0
import DeviceUtils 1.0

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Flickable {
    id: panelDeviceInfos
    anchors.top: (selectedDevice && selectedDevice.isLowEnergy) ? actionBar.bottom : parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 20

    contentWidth: -1
    contentHeight: inflow.height

    boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
    ScrollBar.vertical: ScrollBar { visible: false }

    Flow {
        id: inflow
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 20

        ////////

        Rectangle {
            width: detailView.ww
            height: box1.height + 24
            radius: 4
            color: Theme.colorBox
            clip: true

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                width: 8
                radius: 2
                color: Theme.colorPrimary
            }

            IconSvg {
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                height: 64
                color: Theme.colorIcon

                source: {
                    if (selectedDevice) {
                        if (selectedDevice.isBeacon) return "qrc:/assets/icons_bootstrap/tags.svg"
                        return UtilsBluetooth.getBluetoothMinorClassIcon(selectedDevice.majorClass, selectedDevice.minorClass)
                    }
                    return ""
                }
/*
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -12
                    radius: 64
                    z: -1
                    visible: parent.source.length
                    color: Theme.colorForeground
                }
*/
            }

            Column {
                id: box1
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 140

                Component.onCompleted: {
                    legendWidth = 64
                    legendWidth = Math.max(legendWidth, legendName.contentWidth)
                    legendWidth = Math.max(legendWidth, legendAddress.contentWidth)
                    legendWidth = Math.max(legendWidth, legendManufacturer.contentWidth)
                    legendWidth = Math.max(legendWidth, legendBluetooth.contentWidth)
                    legendWidth += 20
                }

                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendName
                        anchors.verticalCenter: parent.verticalCenter
                        width: box1.legendWidth
                        text: qsTr("Name")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    TextSelectable {
                        anchors.verticalCenter: parent.verticalCenter

                        property bool nameAvailable: (selectedDevice.deviceName.length > 0)

                        selectByMouse: nameAvailable
                        color: nameAvailable ? Theme.colorText : Theme.colorSubText
                        text: nameAvailable ? selectedDevice.deviceName : qsTr("Unavailable")
                    }
                }
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendAddress
                        anchors.verticalCenter: parent.verticalCenter
                        width: box1.legendWidth
                        text: qsTr("MAC address")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    TextSelectable {
                        anchors.verticalCenter: parent.verticalCenter
                        text: selectedDevice.deviceAddress
                    }
                }
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendManufacturer
                        anchors.verticalCenter: parent.verticalCenter
                        width: box1.legendWidth
                        text: qsTr("Manufacturer")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    TextSelectable {
                        id: deviceManufacturer
                        anchors.verticalCenter: parent.verticalCenter

                        property bool manufAvailable: (selectedDevice.deviceManufacturer.length > 0)

                        selectByMouse: manufAvailable
                        color: manufAvailable ? Theme.colorText : Theme.colorSubText
                        text: manufAvailable ? selectedDevice.deviceManufacturer : qsTr("Unknown")
                    }
                }
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendBluetooth
                        anchors.verticalCenter: parent.verticalCenter
                        width: box1.legendWidth
                        text: qsTr("Bluetooth")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    ItemTag {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: selectedDevice.isClassic
                        text: qsTr("Classic")
                        color: Theme.colorComponent
                    }

                    ItemTag {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: selectedDevice.isLowEnergy
                        text: qsTr("Low Energy")
                        color: Theme.colorComponent
                    }

                    //TextSelectable {
                    //    anchors.verticalCenter: parent.verticalCenter
                    //    text: UtilsBluetooth.getBluetoothCoreConfigurationText(selectedDevice.bluetoothConfiguration)
                    //}
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box1b.height + 24
            radius: 4
            color: Theme.colorBox
            clip: true

            Column {
                id: box1b
                width: parent.width - 16
                anchors.centerIn: parent
                spacing: 16

                Flow { // buttons row 1
                    width: parent.width
                    spacing: 12

                    ButtonWireframeIcon {
                        fullColor: true
                        visible: (deviceManager.bluetooth && selectedDevice.isLowEnergy)
                        text: {
                            if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                                return qsTr("scan services")
                            else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                                return qsTr("connecting...")
                            else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
                                return qsTr("scanning...")
                            else if (selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED)
                                return qsTr("disconnect")
                        }
                        source: {
                            if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                                return "qrc:/assets/icons_material/baseline-bluetooth-24px.svg"
                            else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                                return "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                            else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
                                return "qrc:/assets/icons_material/duotone-bluetooth_searching-24px.svg"
                            else
                                return "qrc:/assets/icons_material/duotone-settings_bluetooth-24px.svg"
                        }
                        onClicked: {
                            if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                                selectedDevice.actionScan()
                            else
                                selectedDevice.deviceDisconnect()
                        }
                    }
                }

                Flow { // buttons row 2
                    width: parent.width
                    spacing: 12

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: selectedDevice.isStarred ?Theme.colorSecondary : Theme.colorGrey

                        text: selectedDevice.isStarred ? qsTr("starred") : qsTr("star")
                        source: selectedDevice.isStarred ?
                                    "qrc:/assets/icons_material/baseline-stars-24px.svg" :
                                    "qrc:/assets/icons_material/outline-add_circle-24px.svg"
                        onClicked: selectedDevice.isStarred = !selectedDevice.isStarred
                    }

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: Theme.colorGrey

                        visible: (!settingsManager.scanCacheAuto && !selectedDevice.isBeacon)

                        text: selectedDevice.hasCache ? qsTr("forget") : qsTr("cache")
                        source: selectedDevice.hasCache ?
                                    "qrc:/assets/icons_material/baseline-loupe_minus-24px.svg" :
                                    "qrc:/assets/icons_material/baseline-loupe-24px.svg"
                        onClicked: selectedDevice.cache(!selectedDevice.isCached)
                    }

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: Theme.colorGrey

                        text: selectedDevice.isBlacklisted ? qsTr("whitelist") : qsTr("blacklist")
                        source: selectedDevice.isBlacklisted ?
                                    "qrc:/assets/icons_material/outline-add_circle-24px.svg" :
                                    "qrc:/assets/icons_material/baseline-cancel-24px.svg"
                        onClicked: selectedDevice.blacklist(!selectedDevice.isBlacklisted)
                    }

                    ButtonWireframe {
                        fullColor: true
                        primaryColor: selectedDevice.userColor
                        fulltextColor: utilsApp.isQColorLight(selectedDevice.userColor) ? "#333" : "#f4f4f4"

                        text: qsTr("color")
                        onClicked: colorDialog.open()

                        ColorDialog {
                            id: colorDialog
                            currentColor: selectedDevice.userColor
                            onAccepted: selectedDevice.userColor = colorDialog.color
                        }
                    }
    /*
                    Rectangle { // user color
                        width: Theme.componentHeight
                        height: Theme.componentHeight
                        radius: Theme.componentRadius

                        color: selectedDevice.userColor
                        border.width: 2
                        border.color: Qt.darker(selectedDevice.userColor, 1.1)

                        ColorDialog {
                            id: colorDialog
                            currentColor: selectedDevice.userColor
                            onAccepted: selectedDevice.userColor = colorDialog.color
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: colorDialog.open()
                        }
                    }
    */
                }

                TextFieldThemed { // user comment
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 36

                    colorBackground: Theme.colorBox
                    placeholderText: qsTr("Comment")
                    text: selectedDevice.userComment
                    onTextEdited: selectedDevice.userComment = text
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box2.height + 24
            radius: 4
            color: Theme.colorBox
            clip: true

            visible: (selectedDevice.majorClass !== 0)

            Column {
                id: box2
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 140

                Component.onCompleted: {
                    legendWidth = 64
                    legendWidth = Math.max(legendWidth, legendCategory.contentWidth)
                    legendWidth = Math.max(legendWidth, legendDeviceType.contentWidth)
                    legendWidth = Math.max(legendWidth, legendService.contentWidth)
                    legendWidth += 20
                }
/*
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        width: box2.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("classes - debug")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("%1 - %2 - %3").arg(selectedDevice.majorClass).arg(selectedDevice.minorClass).arg(selectedDevice.serviceClass)
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }
*/
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendCategory
                        width: box2.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("category")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        anchors.verticalCenter: parent.verticalCenter
                        text: UtilsBluetooth.getBluetoothMajorClassText(selectedDevice.majorClass)
                    }
                }
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendDeviceType
                        width: box2.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("device type")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        anchors.verticalCenter: parent.verticalCenter
                        text: UtilsBluetooth.getBluetoothMinorClassText(selectedDevice.majorClass, selectedDevice.minorClass)
                    }
                }
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendService
                        width: box2.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("service(s)")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        anchors.verticalCenter: parent.verticalCenter
                        text: UtilsBluetooth.getBluetoothServiceClassText(selectedDevice.serviceClass)
                    }
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box3.height + 24
            radius: 4

            visible: (selectedDevice.rssi !== 0)
            color: Theme.colorBox
            clip: true

            Column {
                id: box3
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 200

                Component.onCompleted: {
                    legendWidth = 64
                    legendWidth = Math.max(legendWidth, legendRSSI.contentWidth)
                    legendWidth = Math.max(legendWidth, legendAdvertising.contentWidth)
                    legendWidth += 20
                }

                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendRSSI
                        width: box3.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("RSSI")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: (selectedDevice.rssi !== 0)
                        spacing: 4

                        Item {
                            width: 20; height: 20;
                            anchors.verticalCenter: parent.verticalCenter

                            IconSvg {
                                width: 16; height: 16;
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -1
                                source: (selectedDevice.rssi < 0) ? "qrc:/assets/icons_material/baseline-signal_cellular_full-24px.svg"
                                                                  : "qrc:/assets/icons_material/baseline-signal_cellular_off-24px.svg"
                                color: Theme.colorIcon
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "-" + Math.abs(selectedDevice.rssi)
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("dBm")
                            color: Theme.colorSubText
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: (selectedDevice.rssi === 0)

                        text: qsTr("Unknown")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }

                ////

                Row {
                    height: 32
                    spacing: 12

                    Text {
                        id: legendAdvertising
                        width: box3.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Advertising interval")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: (selectedDevice.advInterval !== 0)
                        spacing: 4

                        IconSvg {
                            width: 20; height: 20;

                            source: "qrc:/assets/icons_material/baseline-arrow_left_right-24px.svg"
                            color: Theme.colorIcon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: selectedDevice.advInterval
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("ms")
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: (selectedDevice.advInterval === 0)

                        text: qsTr("Unknown")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }

                ////

                Item {
                    width: 24
                    height: 24
                }
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 2

                Repeater {
                    model: selectedDevice.rssiHistory

                    Rectangle {
                        width: ((detailView.ww - 59*2) / 60); height: 28;
                        radius: 2
                        color: Theme.colorForeground

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom

                            height: ((100 - Math.abs(modelData.rssi)) / 100) * parent.height
                            radius: 2

                            color: {
                                if (modelData.hasMFD) return Theme.colorBlue
                                if (modelData.hasSVD) return Theme.colorGreen
                                if (modelData.hasMFD && modelData.hasSVD) Theme.colorOrange
                                return Theme.colorPrimary
                            }
                        }
                    }
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box4.height + 24
            radius: 4

            visible: (selectedDevice.rssi !== 0)
            color: Theme.colorBox
            clip: true

            Column {
                id: box4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                ////

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    height: 32

                    visible: !selectedDevice.hasAdvertisement

                    text: qsTr("No advertisement data...")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.colorText
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: selectedDevice.svd.length

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        height: 32
                        spacing: 12

                        Rectangle {
                            width: 16; height: 16; radius: 4;
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -1
                            color: Theme.colorGreen
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Service data")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }

                    Repeater {
                        model: selectedDevice.last_svd

                        AdvertisementDataWidget {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            packet: modelData
                        }
                    }
                }

                ////

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: selectedDevice.mfd.length

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        height: 32
                        spacing: 12

                        Rectangle {
                            width: 16; height: 16; radius: 4;
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -1
                            color: Theme.colorBlue
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Manufacturer data")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }

                    Repeater {
                        model: selectedDevice.last_mfd

                        AdvertisementDataWidget {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            packet: modelData
                        }
                    }
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box5.height + 24
            radius: 4

            visible: (selectedDevice.servicesAdvertisedCount !== 0)
            color: Theme.colorBox
            clip: true

            Column {
                id: box5
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 16
                spacing: 8

                ////

                Text {
                    text: qsTr("Service(s) advertised")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.right: parent.right

                    Repeater {
                        model: selectedDevice.servicesAdvertised

                        TextSelectable {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: modelData
                            color: Theme.colorSubText
                            font.family: "Monospace"
                        }
                    }
                }
            }
        }

        ////////
    }
}
