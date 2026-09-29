import QtQuick
import QtQuick.Controls

import ComponentLibrary
import DeviceUtils

Item {
    id: panelDevice
    anchors.fill: parent

    function resetState() {
        if (selectedDevice) {
            // Make sure we switch back to the first tab
            if (!selectedDevice.isLowEnergy) {
                deviceMenu.currentIndex = 0
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////

    Loader {
        id: popupLoader_export

        active: false
        asynchronous: false
        sourceComponent: PopupExportDeviceData {
            id: popupExportDeviceData
            parent: appContent
        }
    }

    ////////////////

    Rectangle {
        id: menuBar
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: 44
        color: Theme.colorActionbar

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        // only make sense for BLE device?
        //visible: (selectedDevice && selectedDevice.isLowEnergy)

        TabBarThemed {
            id: deviceMenu
            anchors.fill: parent

            contentHeight: parent.height - separatorHeight
            separatorHeight: 0
            colorBackground: Theme.colorActionbar

            enabled: (selectedDevice && selectedDevice.isLowEnergy)
            currentIndex: 0

            Connections {
                target: selectedDevice
                function onConnected() { menuInfo.blink() }
                function onAdvertisementChanged() { menuAdv.blink() }
                function onServicesChanged() { menuSrv.blink() }
                function onCharacteristicsChanged() { menuSrv.blink() }
                function onLogUpdated() { menuLog.blink() }
            }

            TabButtonThemed {
                id: menuInfo
                text: qsTr("device info")
                colorBackground: Theme.colorActionbar
                badgeText: (selectedDevice && selectedDevice.connected) ? " " : ""
                badgeColor: (selectedDevice && selectedDevice.status === 2) ? Theme.colorYellow : Theme.colorGreen
                badgeFade: (selectedDevice && selectedDevice.status === 2)
            }
            TabButtonThemed {
                id: menuAdv
                text: qsTr("advertisement")
                colorBackground: Theme.colorActionbar
                badgeText: selectedDevice ? selectedDevice.advCount : ""
            }
            TabButtonThemed {
                id: menuSrv
                text: qsTr("services")
                colorBackground: Theme.colorActionbar
                badgeText: (selectedDevice && selectedDevice.servicesCount) ? selectedDevice.servicesCount : "?"
            }
            TabButtonThemed {
                id: menuLog
                text: qsTr("log")
                colorBackground: Theme.colorActionbar
                badgeText: (selectedDevice && selectedDevice.deviceLogCount) ? selectedDevice.deviceLogCount : "?"
            }
        }
    }

    ////////////////

    Rectangle {
        id: actionBar
        anchors.top: menuBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: 56
        color: Theme.colorBox
        //color: Qt.lighter(Theme.colorActionbar, 1.05)

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: Theme.colorBoxBorder
        }

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        // only make sense for BLE device?
        visible: (selectedDevice && selectedDevice.isLowEnergy)

        Row { // Layout { // buttons row
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXS
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXS
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMarginXS

            ////

            ButtonScanMenu { // action button
                width: 256
                height: 34
            }

            ButtonDesktop {
                height: 34

                source: "qrc:/IconLibrary/material-symbols/bluetooth_disabled.svg"

                visible: (selectedDevice && selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED)
                onClicked: {
                    if (selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED) {
                        selectedDevice.actionDisconnect()
                    }
                }
            }

            ButtonDesktop {
                height: 34

                text: qsTr("Load from cache")
                source: "qrc:/IconLibrary/material-symbols/save.svg"

                visible: (selectedDevice && selectedDevice.hasServiceCache)
                //enabled: selectedDevice.status === DeviceUtils.DEVICE_OFFLINE
                onClicked: selectedDevice.restoreServiceCache()
            }

            ////

            ButtonDesktop {
                height: 34

                text: qsTr("Export available data")
                source: "qrc:/IconLibrary/material-symbols/save-fill.svg"

                enabled: (selectedDevice && (selectedDevice.advCount > 0 ||
                                             selectedDevice.servicesCount > 0 ||
                                             selectedDevice.hasServiceCache))

                onClicked: {
                    popupLoader_export.active = true
                    popupLoader_export.item.open()
                }
            }

            ////
        }
    }

    ////////////////

    PanelDeviceInfos {
        id: panelDeviceInfos

        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.componentMargin

        visible: (deviceMenu.currentIndex === 0)
    }

    ////////////////

    PanelDeviceAdvertisement {
        id: panelDeviceAdvertisement

        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0

        visible: (deviceMenu.currentIndex === 1)
    }

    ////////////////

    PanelDeviceServices {
        id: panelDeviceServices

        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0

        visible: (deviceMenu.currentIndex === 2)
    }

    ////////////////

    PanelDeviceLog {
        id: panelDeviceLog

        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0

        visible: (deviceMenu.currentIndex === 3)
    }

    ////////////////
}
