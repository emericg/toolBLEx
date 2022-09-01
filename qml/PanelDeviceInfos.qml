import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Item {
    id: panelDeviceInfos
    anchors.top: (selectedDevice && selectedDevice.isLowEnergy) ? actionBar.bottom : parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 20

    visible: (deviceMenu.currentSelection === 1)

    Flow {
        anchors.fill: parent
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

                property int legendWidth: 160

                Row {
                    height: 32
                    spacing: 12

                    Text {
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
                        text: selectedDevice.deviceName
                    }
                }
                Row {
                    height: 32
                    spacing: 12

                    Text {
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
                        anchors.verticalCenter: parent.verticalCenter
                        width: box1.legendWidth
                        text: qsTr("Manufacturer")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    TextSelectable {
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
/*
        Rectangle {
            id: connectionBar0
            width: detailView.ww
            height: 36
            radius: 8
            color: Theme.colorBox // Theme.colorActionbar

            Row {
                anchors.fill: parent
                spacing: 24

                ButtonWireframeIcon {
                    height: parent.height

                    fullColor: true
                    text: {
                        if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                            qsTr("connect")
                        //else if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                        //    qsTr("connecting...")
                        else //if (selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                            qsTr("disconnect")
                    }
                    source: "qrc:/assets/icons_material/duotone-bluetooth_connected-24px.svg"
                    onClicked: {
                        if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                            selectedDevice.actionScan()
                        else
                            selectedDevice.deviceDisconnect()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: {
                        return UtilsDeviceSensors.getDeviceStatusText(selectedDevice.status)
                    }
                    color: Theme.colorText
                }
            }
        }
*/
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

                property int legendWidth: 160
/*
                Row {
                    height: 32
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: box2.legendWidth
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
                        anchors.verticalCenter: parent.verticalCenter
                        width: box2.legendWidth
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
                        anchors.verticalCenter: parent.verticalCenter
                        width: box2.legendWidth
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
                        anchors.verticalCenter: parent.verticalCenter
                        width: box2.legendWidth
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
            color: Theme.colorBox
            clip: true

            Column {
                id: box3
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                property int legendWidth: 200

                Row {
                    height: 32
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: box3.legendWidth
                        text: qsTr("RSSI")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        horizontalAlignment: Text.AlignRight
                        color: Theme.colorSubText
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
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
                }

                ////

                Row {
                    height: 32
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: box3.legendWidth
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

                            height: (Math.abs(modelData.rssi) / 100) * parent.height
                            radius: 2

                            color: {
                                if (modelData.hasMFD && modelData.hasSVD) return Theme.colorOrange // "orange"
                                if (modelData.hasMFD) return Theme.colorBlue // "blue"
                                if (modelData.hasSVD) return Theme.colorGreen // "green"
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
            color: Theme.colorBox
            clip: true

            Column {
                id: box4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                property int legendWidth: 200

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

        ////
    }}
