import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQuick.Dialogs

import ComponentLibrary
import DeviceUtils
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

    ////////

    Flow {
        id: inflow
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12

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
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 64

                Component.onCompleted: {
                    legendWidth = 64
                    legendWidth = Math.max(legendWidth, legendName.contentWidth)
                    legendWidth = Math.max(legendWidth, legendBluetooth.contentWidth)
                    if (Qt.platform.os === "osx") {
                        legendWidth = Math.max(legendWidth, legendAddressUUID.contentWidth)
                    } else {
                        legendWidth = Math.max(legendWidth, legendAddressMAC.contentWidth)
                        legendWidth = Math.max(legendWidth, legendManufacturer.contentWidth)
                    }
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
                        text: nameAvailable ? selectedDevice.deviceName_display : qsTr("Unavailable")
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
                        font.pixelSize: Theme.fontSizeContentSmall
                        wrapMode: Text.WrapAnywhere
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    visible: (selectedDevice && selectedDevice.deviceAddressMAC.length)

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

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        id: legendBluetooth
                        Layout.preferredWidth: box1.legendWidth
                        Layout.alignment: Qt.AlignCenter

                        text: qsTr("Bluetooth")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        TagDesktop {
                            visible: (selectedDevice && selectedDevice.isClassic)
                            text: qsTr("Classic")
                            colorBackground: Theme.colorComponent
                            colorBorder: Theme.colorComponent
                        }
                        TagDesktop {
                            visible: (selectedDevice && selectedDevice.isLowEnergy)
                            text: qsTr("Low Energy")
                            colorBackground: Theme.colorComponent
                            colorBorder: Theme.colorComponent
                        }
                        TagDesktop {
                            visible: (selectedDevice && !selectedDevice.isClassic && !selectedDevice.isLowEnergy)
                            text: qsTr("Unknown")
                            colorBackground: Theme.colorComponent
                            colorBorder: Theme.colorComponent
                        }

                        //TextSelectable {
                        //    text: UtilsBluetooth.getBluetoothCoreConfigurationText(selectedDevice.bluetoothConfiguration)
                        //}
                    }
                }
            }

            Column {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                visible: (detailView.ww > 400)

                Rectangle {
                    width: 96; height: 96; radius: 96;
                    color: Theme.colorBackground

                    visible: (selectedDevice && selectedDevice.isClassic && deviceIcon.source.toString().length)

                    IconSvg {
                        id: deviceIcon
                        anchors.centerIn: parent
                        width: 64; height: 64;

                        color: Theme.colorSubText
                        source: {
                            if (selectedDevice) {
                                if (selectedDevice.isBeacon) return "qrc:/IconLibrary/bootstrap/tags.svg"
                                if (selectedDevice.majorClass) return UtilsBluetooth.getBluetoothMinorClassIcon(selectedDevice.majorClass, selectedDevice.minorClass)
                            }
                            return ""
                        }
                    }
                }

                TagDesktop {
                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: (selectedDevice && selectedDevice.pairingStatus > 0)

                    text: UtilsBluetooth.getBluetoothPairingText(selectedDevice.pairingStatus)
                    colorBackground: Theme.colorComponent
                    colorBorder: Theme.colorComponent
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
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 64

                Component.onCompleted: {
                    legendWidth = 64
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

                        text: qsTr("Service(s)", "", selectedDevice.servicesCount)
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
            height: boxA.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder
            visible: (selectedDevice && selectedDevice.isLowEnergy)

            Column {
                id: boxA
                width: parent.width - 32
                anchors.centerIn: parent
                spacing: 12

                Flow { // buttons row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    property int www: (width > 400) ? ((width - spacing) / 2) : width

                    ButtonScanMenu {
                        width: parent.www
                    }

                    ButtonFlat {
                        id: exportButton
                        width: parent.www

                        color: Theme.colorComponent
                        colorText: Theme.colorComponentContent

                        enabled: (selectedDevice &&
                                  (selectedDevice.advCount > 0 || selectedDevice.servicesCount > 0 || selectedDevice.hasServiceCache))

                        text: qsTr("export available data")
                        source: "qrc:/IconLibrary/material-symbols/save-fill.svg"

                        onClicked: {
                            popupLoader_export.active = true
                            popupLoader_export.item.open()
                        }
                    }
                }
/*
                Flow { // status row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    Text {
                        text: qsTr("%n adv packet(s)", "", selectedDevice.advCount)
                        color: Theme.colorSubText
                    }
                    Text {
                        text: qsTr("%n service(s)", "", selectedDevice.servicesCount)
                        color: Theme.colorSubText
                    }
                }
*/
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: boxB.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            Column {
                id: boxB
                width: parent.width - 32
                anchors.centerIn: parent
                spacing: 12

                Flow { // buttons row
                    width: parent.width
                    spacing: 12

                    ButtonSolid {
                        color: (selectedDevice && selectedDevice.isStarred) ? Theme.colorPrimary : Theme.colorGrey

                        text: (selectedDevice && selectedDevice.isStarred) ? qsTr("starred") : qsTr("star")
                        source: (selectedDevice && selectedDevice.isStarred) ?
                                    "qrc:/IconLibrary/material-symbols/stars-fill.svg" :
                                    "qrc:/IconLibrary/material-symbols/stars.svg"
                        onClicked: selectedDevice.isStarred = !selectedDevice.isStarred
                    }

                    ButtonSolid {
                        color: Theme.colorGrey

                        visible: (selectedDevice && !selectedDevice.isBeacon)

                        text: (selectedDevice && selectedDevice.isCached) ? qsTr("forget") : qsTr("cache")
                        source: (selectedDevice && selectedDevice.isCached) ?
                                    "qrc:/IconLibrary/material-symbols/loupe_minus.svg" :
                                    "qrc:/IconLibrary/material-symbols/loupe_plus.svg"
                        onClicked: selectedDevice.cache(!selectedDevice.isCached)
                    }

                    ButtonSolid {
                        color: Theme.colorGrey

                        text: (selectedDevice && selectedDevice.isBlacklisted) ? qsTr("show") : qsTr("hide")
                        source: (selectedDevice && selectedDevice.isBlacklisted) ?
                                    "qrc:/IconLibrary/material-symbols/add_circle.svg" :
                                    "qrc:/IconLibrary/material-symbols/cancel_circle.svg"
                        onClicked: selectedDevice.blacklist(!selectedDevice.isBlacklisted)
                    }

                    ButtonSolid {
                        color: (selectedDevice && selectedDevice.userColor)
                        //fulltextColor: (selectedDevice && utilsApp.isQColorLight(selectedDevice.userColor)) ? "#333" : "#f4f4f4"
                        font.bold: true

                        text: qsTr("color")
                        onClicked: colorDialog.open()
                        colorText: utilsApp.isQColorLight(colorBackground) ? "dark" : "white"

                        ColorDialog {
                            id: colorDialog
                            selectedColor: selectedDevice ? selectedDevice.userColor : Theme.colorIcon
                            onAccepted: selectedDevice.userColor = colorDialog.selectedColor
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
                            selectedColor: selectedDevice.userColor
                            onAccepted: selectedDevice.userColor = colorDialog.selectedColor
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

            clip: true
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.rssi !== 0)

            Column {
                id: box3
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                property int legendWidth: 64

                Component.onCompleted: {
                    legendWidth = 64
                    legendWidth = Math.max(legendWidth, legendMTU.contentWidth)
                    legendWidth = Math.max(legendWidth, legendRSSI.contentWidth)
                    legendWidth = Math.max(legendWidth, legendAdvertising.contentWidth)
                }

                ////

                Row {
                    height: 32
                    spacing: 12

                    visible: (selectedDevice && selectedDevice.mtu > 0)

                    Text {
                        id: legendMTU
                        width: box3.legendWidth
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("MTU")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: selectedDevice.mtu
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                    }
                }

                ////

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
                                            "qrc:/IconLibrary/material-symbols/signal_cellular_4_bar.svg" :
                                            "qrc:/IconLibrary/material-symbols/signal_cellular_off-fill.svg"
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

                            source: "qrc:/IconLibrary/material-symbols/arrow_range.svg"
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
                        width: ((detailView.ww - 59*2 - 2*2) / 60)
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
            height: box_adv_services.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.servicesAdvertisedCount !== 0)

            Column {
                id: box_adv_services
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 16
                spacing: 8

                Text {
                    text: qsTr("Service(s) advertised", "", selectedDevice.servicesCount)
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                }

                Column {
                    anchors.left: parent.left
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

        Rectangle {
            width: detailView.ww
            height: box_adv_nodata.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.rssi !== 0 && !selectedDevice.hasAdvertisement)

            Text {
                id: box_adv_nodata
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("No advertisement data...")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box_adv_servicedata.height + 32
            radius: 4

            clip: true
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.rssi !== 0 && selectedDevice.svd.length)

            Column {
                id: box_adv_servicedata
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    spacing: 12

                    Rectangle {
                        width: 18; height: 18; radius: 4;
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
        }

        ////////

        Rectangle {
            width: detailView.ww
            height: box_adv_manufdata.height + 32
            radius: 4

            clip: true
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.rssi !== 0 && selectedDevice.mfd.length)

            Column {
                id: box_adv_manufdata
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                ////

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    spacing: 12

                    Rectangle {
                        width: 18; height: 18; radius: 4;
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

        ////////
    }
}
