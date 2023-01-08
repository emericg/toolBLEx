import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt.labs.platform

import ThemeEngine 1.0
import DeviceUtils 1.0

import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Flickable {
    id: panelDeviceInfos
    anchors.top: (selectedDevice && selectedDevice.isLowEnergy) ? actionBar.bottom : parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 16

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

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                width: 8
                radius: 2
                color: Theme.colorPrimary
            }

            Column {
                id: box1
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 80

                Component.onCompleted: {
                    legendWidth = 80
                    legendWidth = Math.max(legendWidth, legendName.contentWidth)
                    legendWidth = Math.max(legendWidth, legendAddressMAC.contentWidth)
                    legendWidth = Math.max(legendWidth, legendAddressUUID.contentWidth)
                    legendWidth = Math.max(legendWidth, legendManufacturer.contentWidth)
                    legendWidth = Math.max(legendWidth, legendBluetooth.contentWidth)
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        id: legendName
                        Layout.preferredWidth: box1.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("Name")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        property bool nameAvailable: (selectedDevice && selectedDevice.deviceName.length > 0)
                        selectByMouse: nameAvailable
                        color: nameAvailable ? Theme.colorText : Theme.colorSubText
                        text: nameAvailable ? selectedDevice.deviceName : qsTr("Unavailable")
                        wrapMode: Text.WrapAnywhere
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    visible: (selectedDevice && selectedDevice.deviceAddressMAC.length)

                    Text {
                        id: legendAddressMAC
                        Layout.preferredWidth: box1.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("MAC address")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        text: (selectedDevice && selectedDevice.deviceAddressMAC)
                        wrapMode: Text.WrapAnywhere
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    visible: (selectedDevice && !selectedDevice.deviceAddressMAC.length)

                    Text {
                        id: legendAddressUUID
                        Layout.preferredWidth: box1.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("UUID")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        text: (selectedDevice && selectedDevice.deviceAddress)
                        wrapMode: Text.WrapAnywhere
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        id: legendManufacturer
                        Layout.preferredWidth: box1.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("Manufacturer")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        property bool manufAvailable: (selectedDevice && selectedDevice.deviceManufacturer.length > 0)
                        selectByMouse: manufAvailable
                        color: manufAvailable ? Theme.colorText : Theme.colorSubText
                        text: manufAvailable ? selectedDevice.deviceManufacturer : qsTr("Unknown")
                        wrapMode: Text.WrapAnywhere
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
                        visible: (selectedDevice && selectedDevice.isClassic)
                        text: qsTr("Classic")
                        color: Theme.colorForeground
                    }
                    ItemTag {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: (selectedDevice && selectedDevice.isLowEnergy)
                        text: qsTr("Low Energy")
                        color: Theme.colorForeground
                    }
                    //TextSelectable {
                    //    anchors.verticalCenter: parent.verticalCenter
                    //    text: UtilsBluetooth.getBluetoothCoreConfigurationText(selectedDevice.bluetoothConfiguration)
                    //}
                }
            }

            Column {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 92; height: 92; radius: 92;
                    color: Theme.colorForeground
                    visible: (selectedDevice && selectedDevice.isClassic && deviceIcon.source.toString().length)

                    IconSvg {
                        id: deviceIcon
                        anchors.centerIn: parent
                        width: 64; height: 64;

                        color: Theme.colorSubText
                        source: {
                            if (selectedDevice) {
                                if (selectedDevice.isBeacon) return "qrc:/assets/icons_bootstrap/tags.svg"
                                if (selectedDevice.majorClass) return UtilsBluetooth.getBluetoothMinorClassIcon(selectedDevice.majorClass, selectedDevice.minorClass)
                            }
                            return ""
                        }
                    }
                }

                ItemTag {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: UtilsBluetooth.getBluetoothPairingText(selectedDevice.pairingStatus)
                    color: Theme.colorForeground
                    visible: (selectedDevice && selectedDevice.pairingStatus > 0)
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box2.height + 24
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.majorClass !== 0)

            Column {
                id: box2
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 80

                Component.onCompleted: {
                    legendWidth = 80
                    legendWidth = Math.max(legendWidth, legendCategory.contentWidth)
                    legendWidth = Math.max(legendWidth, legendDeviceType.contentWidth)
                    legendWidth = Math.max(legendWidth, legendService.contentWidth)
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
                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        id: legendCategory
                        Layout.preferredWidth: box2.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("Category")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        text: UtilsBluetooth.getBluetoothMajorClassText(selectedDevice.majorClass)
                        wrapMode: Text.WrapAnywhere
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        id: legendDeviceType
                        Layout.preferredWidth: box2.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("Device type")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        text: UtilsBluetooth.getBluetoothMinorClassText(selectedDevice.majorClass, selectedDevice.minorClass)
                        wrapMode: Text.WrapAnywhere
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        id: legendService
                        Layout.preferredWidth: box2.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("Service(s)")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }
                    TextSelectable {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32

                        text: UtilsBluetooth.getBluetoothServiceClassText(selectedDevice.serviceClass)
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box1b.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            Column {
                id: box1b
                width: parent.width - 32
                anchors.centerIn: parent
                spacing: 12

                Flow { // buttons row
                    width: parent.width
                    spacing: 12

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: (selectedDevice && selectedDevice.isStarred) ? Theme.colorPrimary : Theme.colorLightGrey

                        text: (selectedDevice && selectedDevice.isStarred) ? qsTr("starred") : qsTr("star")
                        source: (selectedDevice && selectedDevice.isStarred) ?
                                    "qrc:/assets/icons_material/baseline-stars-24px.svg" :
                                    "qrc:/assets/icons_material/outline-add_circle-24px.svg"
                        onClicked: selectedDevice.isStarred = !selectedDevice.isStarred
                    }

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: Theme.colorLightGrey

                        visible: (selectedDevice && !selectedDevice.isBeacon)

                        text: (selectedDevice && selectedDevice.hasCache) ? qsTr("forget") : qsTr("cache")
                        source: (selectedDevice && selectedDevice.hasCache) ?
                                    "qrc:/assets/icons_material/baseline-loupe_minus-24px.svg" :
                                    "qrc:/assets/icons_material/baseline-loupe-24px.svg"
                        onClicked: selectedDevice.cache(!selectedDevice.isCached)
                    }

                    ButtonWireframeIcon {
                        fullColor: true
                        primaryColor: Theme.colorLightGrey

                        text: (selectedDevice && selectedDevice.isBlacklisted) ? qsTr("whitelist") : qsTr("blacklist")
                        source: (selectedDevice && selectedDevice.isBlacklisted) ?
                                    "qrc:/assets/icons_material/outline-add_circle-24px.svg" :
                                    "qrc:/assets/icons_material/baseline-cancel-24px.svg"
                        onClicked: selectedDevice.blacklist(!selectedDevice.isBlacklisted)
                    }

                    ButtonWireframe {
                        fullColor: true
                        primaryColor: (selectedDevice && selectedDevice.userColor)
                        fulltextColor: (selectedDevice && utilsApp.isQColorLight(selectedDevice.userColor)) ? "#333" : "#f4f4f4"

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
                    text: (selectedDevice && selectedDevice.userComment)
                    onTextEdited: selectedDevice.userComment = text
                }
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box3.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.rssi !== 0)

            Column {
                id: box3
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 8

                property int legendWidth: 80

                Component.onCompleted: {
                    legendWidth = 80
                    legendWidth = Math.max(legendWidth, legendRSSI.contentWidth)
                    legendWidth = Math.max(legendWidth, legendAdvertising.contentWidth)
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
                        visible: (selectedDevice && selectedDevice.rssi !== 0)
                        spacing: 4

                        Item {
                            width: 20; height: 20;
                            anchors.verticalCenter: parent.verticalCenter

                            IconSvg {
                                width: 16; height: 16;
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -1
                                source: (selectedDevice && selectedDevice.rssi < 0) ?
                                            "qrc:/assets/icons_material/baseline-signal_cellular_full-24px.svg" :
                                            "qrc:/assets/icons_material/baseline-signal_cellular_off-24px.svg"
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
                        visible: (selectedDevice && selectedDevice.rssi === 0)

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
                        visible: (selectedDevice && selectedDevice.advInterval !== 0)
                        spacing: 4

                        IconSvg {
                            width: 20; height: 20;

                            source: "qrc:/assets/icons_material/baseline-arrow_left_right-24px.svg"
                            color: Theme.colorIcon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: (selectedDevice && selectedDevice.advInterval)
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
                        visible: (selectedDevice && selectedDevice.advInterval === 0)

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
                anchors.margins: 2
                spacing: 2

                Repeater {
                    model: (selectedDevice && selectedDevice.rssiHistory)

                    Rectangle {
                        width: ((detailView.ww - 59*2) / 60)
                        height: 40
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

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.rssi !== 0)

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

                    visible: (selectedDevice && !selectedDevice.hasAdvertisement)

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

                    visible: (selectedDevice && selectedDevice.svd.length)

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

                            text: qsTr("Latest service data")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }

                    Repeater {
                        model: (selectedDevice && selectedDevice.last_svd)
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

                    visible: (selectedDevice && selectedDevice.mfd.length)

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

                            text: qsTr("Latest manufacturer data")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorText
                        }
                    }

                    Repeater {
                        model: (selectedDevice && selectedDevice.last_mfd)
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

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.servicesAdvertisedCount !== 0)

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
                        model: (selectedDevice && selectedDevice.servicesAdvertised)
                        TextSelectable {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: modelData
                            color: Theme.colorSubText
                            font.family: fontMonospace
                            wrapMode: Text.WrapAnywhere
                        }
                    }
                }
            }
        }

        ////////
    }
}
