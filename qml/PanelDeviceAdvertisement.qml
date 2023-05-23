import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Flickable {
    id: panelDeviceAdvertisement

    contentWidth: -1
    contentHeight: columnDeviceAdvertisement.height

    boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
    ScrollBar.vertical: ScrollBar { visible: false }

    Column {
        id: columnDeviceAdvertisement
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12

        ////////

        Rectangle {
            width: detailView.ww
            height: adv_nodata.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && !selectedDevice.hasAdvertisement)

            Text {
                id: adv_nodata
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
            anchors.left: parent.left
            anchors.right: parent.right
            height: 32 + 32 + 24
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            visible: (selectedDevice && selectedDevice.hasAdvertisement)

            Row {
                anchors.top: parent.top
                anchors.topMargin: 12
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

            ////

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                height: 28
                spacing: 12

                Repeater {
                    model: (selectedDevice && selectedDevice.svd_uuid)

                    ButtonWireframe {
                        height: 28
                        fullColor: true
                        fulltextColor: Theme.colorText
                        primaryColor: Theme.colorComponent
                        opacity: modelData.selected ? 1 : 0.5

                        text: "0x" + modelData.uuid.toUpperCase()
                        font.bold: false
                        onClicked: {
                            modelData.selected = !modelData.selected
                            //selectedDevice.svdFilterUpdate()
                            selectedDevice.advertisementFilterUpdate()
                        }
                    }
                }
            }

            ////////

            Row {
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 16
                height: 32
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Manufacturer data")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                }

                Rectangle {
                    width: 16; height: 16; radius: 4;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1
                    color: Theme.colorBlue
                }
            }

            ////

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                height: 28
                spacing: 12

                Repeater {
                    model: (selectedDevice && selectedDevice.mfd_uuid)

                    ButtonWireframe {
                        height: 28
                        fullColor: true
                        fulltextColor: Theme.colorText
                        primaryColor: Theme.colorComponent
                        opacity: modelData.selected ? 1 : 0.5

                        text: "0x" + modelData.uuid.toUpperCase()
                        font.bold: false
                        onClicked: {
                            modelData.selected = !modelData.selected
                            //selectedDevice.mfdFilterUpdate()
                            selectedDevice.advertisementFilterUpdate()
                        }
                    }
                }
            }
        }

        ////////

        Repeater { // advertisement packets
            model: (selectedDevice && selectedDevice.adv)

            AdvertisementDataWidgetAdvanced {
                anchors.left: parent.left
                anchors.right: parent.right
                packet: modelData
            }
        }
    }
}
