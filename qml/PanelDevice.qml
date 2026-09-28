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
        id: actionBar
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
            separatorHeight: 2
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
