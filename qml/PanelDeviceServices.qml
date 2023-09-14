import QtQuick
import QtQuick.Controls

import QtCore
import QtQuick.Dialogs

import ThemeEngine
import DeviceUtils
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth
import "qrc:/js/UtilsPath.js" as UtilsPath

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

                Text { // status row
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

                    ButtonScanMenu {
                        width: ((parent.width - parent.spacing) / 2)
                    }

                    ButtonWireframeIcon {
                        width: ((parent.width - parent.spacing) / 2)

                        fullColor: true
                        primaryColor: Theme.colorLightGrey

                        enabled: (selectedDevice && selectedDevice.hasServiceCache())
                        text: qsTr("load from cache")
                        source: "qrc:/assets/icons_material/baseline-save-24px.svg"

                        onClicked: {
                            selectedDevice.restoreServiceCache()
                        }
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
            height: (selectedDevice && selectedDevice.servicesScanMode === 1) ? 40 : 0
            color: Theme.colorForeground

            visible: (selectedDevice && selectedDevice.servicesScanMode === 1)

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                color: Theme.colorIcon
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 52
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Services info loaded from cache")
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

        ButtonWireframeIcon {
            id: cacheButton

            fullColor: true
            primaryColor: Theme.colorLightGrey

            visible: (selectedDevice &&
                      selectedDevice.servicesCount > 1 &&
                      selectedDevice.servicesScanMode > 1)

            text: qsTr("Cache")
            source: "qrc:/assets/icons_material/baseline-save-24px.svg"

            onClicked: {
                selectedDevice.saveServiceCache()
            }
        }
    }

    ////////
}
