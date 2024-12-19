import QtQuick
import QtQuick.Controls

import QtCore
import QtQuick.Dialogs

import ComponentLibrary
import DeviceUtils
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Item {
    id: panelDeviceService

    ////////

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        spacing: 20
        visible: (selectedDevice && selectedDevice.servicesCount === 0)

        Rectangle {
            width: detailView.ww
            height: columnServiceScan.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            Column {
                id: columnServiceScan
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                ////

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Services have not been scanned yet...")
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                }

                ////

                Flow { // buttons row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    property int www: (width > 400) ? ((width - spacing) / 2) : width

                    ButtonScanMenu {
                        width: parent.www
                    }

                    ButtonFlat {
                        width: parent.www

                        color: Theme.colorComponent
                        colorText: Theme.colorComponentContent

                        text: qsTr("load from cache")
                        source: "qrc:/IconLibrary/material-symbols/save.svg"

                        visible: (selectedDevice && selectedDevice.hasServiceCache)
                        enabled: (selectedDevice && selectedDevice.hasServiceCache &&
                                  selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)

                        onClicked: selectedDevice.restoreServiceCache()
                    }
                }

                ////
            }
        }
    }

    ////////

    ListView {
        id: servicesView
        anchors.fill: parent
        anchors.margins: -16

        clip: false
        visible: (selectedDevice && selectedDevice.servicesCount > 0)

        header: Rectangle {
            width: servicesView.width
            height: visible ? 40 : 0
            color: Theme.colorForeground

            visible: (selectedDevice && (selectedDevice.servicesCached || !selectedDevice.connected))

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"
                color: Theme.colorSubText
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                visible: (selectedDevice && selectedDevice.servicesCached)
                text: qsTr("Services info loaded from cache")
                color: Theme.colorText
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                visible: (selectedDevice && !selectedDevice.servicesCached && !selectedDevice.connected)
                text: qsTr("Device is disconnected")
                color: Theme.colorText
            }
        }

        model: (selectedDevice && selectedDevice.servicesList)
        delegate: BleServiceWidget {
            width: servicesView.width
        }
    }

    ////////

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -4
        spacing: 8

        ButtonSolid {
            id: cacheButton

            color: Theme.colorGrey

            visible: (selectedDevice &&
                      selectedDevice.hasServices &&
                      selectedDevice.servicesScanned)

            text: qsTr("Cache")
            source: "qrc:/IconLibrary/material-symbols/save.svg"

            onClicked: {
                selectedDevice.saveServiceCache()
            }
        }
    }

    ////////
}
