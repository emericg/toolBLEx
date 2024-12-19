import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ComponentLibrary
import DeviceUtils

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

            ////

            RowLayout {
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16

                height: 32
                spacing: 12

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 16; height: 16; radius: 4;
                    color: Theme.colorGreen
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    text: qsTr("Service data")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    color: Theme.colorText
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    text: qsTr("Manufacturer data")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentBig
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    color: Theme.colorText
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 16; height: 16; radius: 4;
                    color: Theme.colorBlue
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

                    ButtonToggle {
                        height: 28

                        text: "0x" + modelData.uuid.toUpperCase()
                        font.bold: false
                        colorBackground: Theme.colorComponent
                        colorText: Theme.colorText

                        checked: modelData.selected
                        onClicked: {
                            modelData.selected = !modelData.selected
                            //selectedDevice.svdFilterUpdate()
                            selectedDevice.advertisementFilterUpdate()
                        }
                    }
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

                    ButtonToggle {
                        height: 28

                        text: "0x" + modelData.uuid.toUpperCase()
                        font.bold: false
                        colorBackground: Theme.colorComponent
                        colorText: Theme.colorText

                        checked: modelData.selected
                        onClicked: {
                            modelData.selected = !modelData.selected
                            //selectedDevice.mfdFilterUpdate()
                            selectedDevice.advertisementFilterUpdate()
                        }
                    }
                }
            }

            ////
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

        ////////
    }
}
