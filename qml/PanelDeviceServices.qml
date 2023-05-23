import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
import DeviceUtils 1.0

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Item {
    id: panelDeviceService
/*
    Rectangle {
        id: connectionBar
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: 36
        color: Theme.colorLVheader

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        Row {
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: UtilsDeviceSensors.getDeviceStatusText(selectedDevice.status)
                color: Theme.colorText
            }

            Item { // separator
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 24
                Rectangle {
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: Theme.colorLVseparator
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: (selectedDevice.servicesCount === 0)

                text: qsTr("Not scanned")
                color: Theme.colorText
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: (selectedDevice.servicesCount > 0)

                text: qsTr("%1 service(s) found").arg(selectedDevice.servicesCount)
                color: Theme.colorText
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 2
            opacity: 1
            color: Theme.colorSeparator
        }
    }
*/
    ////////

    function resetButtons() {
        exportButton.text = qsTr("Export")
        exportButton.primaryColor = Theme.colorGrey
    }

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

                Text { // status row
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Services have not been scanned yet...")
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                }

                Flow { // buttons row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    ButtonScanMenu {
                        text: {
                            if (!selectedDevice) return ""
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
                            if (!selectedDevice) return ""
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
                            if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                                if (scanmode === "full") {
                                    selectedDevice.actionScanWithValues()
                                } else {
                                    selectedDevice.actionScanWithoutValues()
                                }
                            } else {
                                selectedDevice.deviceDisconnect()
                            }
                        }
                    }

                    ButtonWireframeIcon {
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

            visible: (selectedDevice && selectedDevice.servicesCount > 1)
            enabled: (selectedDevice && selectedDevice.servicesScanMode > 1)

            text: qsTr("Cache")
            source: "qrc:/assets/icons_material/baseline-save-24px.svg"

            onClicked: {
                selectedDevice.saveServiceCache()
            }
        }

        ButtonWireframeIcon {
            id: exportButton
            fullColor: true
            primaryColor: Theme.colorGrey

            visible: (selectedDevice && selectedDevice.servicesCount > 0)
            enabled: (selectedDevice && selectedDevice.servicesScanMode > 1)

            text: qsTr("Export")
            source: "qrc:/assets/icons_material/baseline-save-24px.svg"

            onClicked: {
                if (exportButton.text === qsTr("Exported")) {
                    utilsApp.openWith(selectedDevice.getExportPath())
                    return
                }

                if (selectedDevice.exportDeviceInfo()) {
                    exportButton.text = qsTr("Exported")
                    exportButton.primaryColor = Theme.colorSuccess
                } else {
                    exportButton.text = qsTr("Export error")
                    exportButton.primaryColor = Theme.colorWarning
                }
            }
        }
    }

    ////////
}
