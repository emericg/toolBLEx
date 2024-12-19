import QtQuick
import QtQuick.Controls

import ComponentLibrary
import DeviceUtils

import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Item {
    id: panelDevice
    anchors.fill: parent

    function resetState() {
        if (selectedDevice) {
            // Make sure we switch back to the first tab
            if (!selectedDevice.isLowEnergy) {
                deviceMenu.currentSelection = 1
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

        Item {
            id: deviceMenu
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1

            width: contentRow.width + Theme.componentBorderWidth
            height: 32
            opacity: enabled ? 1 : 0.4
            enabled: (selectedDevice && selectedDevice.isLowEnergy)

            property int currentSelection: 1
            signal menuSelected(var index)
            onMenuSelected: (index) => { currentSelection = index }

            Rectangle {
                id: background
                anchors.fill: parent
                radius: Theme.componentRadius
                color: Theme.colorComponentBackground
            }

            Connections {
                target: selectedDevice
                function onConnected() { menuInfo.blink() }
                function onAdvertisementChanged() { menuAdv.blink() }
                function onServicesChanged() { menuSrv.blink() }
                function onLogUpdated() { menuLog.blink() }
            }

            Row {
                id: contentRow
                height: parent.height
                anchors.centerIn: parent
                spacing: Theme.componentBorderWidth

                SelectorMenuThemedItemBadge {
                    id: menuInfo
                    index: 1
                    highlighted: (deviceMenu.currentSelection === index)

                    text: qsTr("device info")
                    badgeText: (selectedDevice && selectedDevice.connected) ? " " : ""
                    badgeColor: (selectedDevice && selectedDevice.status === 2) ? Theme.colorYellow : Theme.colorGreen
                    badgeFade: (selectedDevice && selectedDevice.status === 2)
                    onClicked: deviceMenu.menuSelected(index)
                    sourceSize: 0
                }
                SelectorMenuThemedItemBadge {
                    id: menuAdv
                    index: 2
                    highlighted: (deviceMenu.currentSelection === index)

                    text: qsTr("advertisement")
                    badgeText: (selectedDevice && selectedDevice.advCount)
                    onClicked: deviceMenu.menuSelected(index)
                    sourceSize: 0
                }
                SelectorMenuThemedItemBadge {
                    id: menuSrv
                    index: 3
                    highlighted: (deviceMenu.currentSelection === index)

                    text: qsTr("services")
                    badgeText: (selectedDevice && selectedDevice.servicesCount) ? selectedDevice.servicesCount : "?"
                    onClicked: deviceMenu.menuSelected(index)
                    sourceSize: 0
                }
                SelectorMenuThemedItemBadge {
                    id: menuLog
                    index: 4
                    highlighted: (deviceMenu.currentSelection === index)

                    text: qsTr("log")
                    badgeText: (selectedDevice && selectedDevice.deviceLogCount) ? selectedDevice.deviceLogCount : "?"
                    onClicked: deviceMenu.menuSelected(index)
                    sourceSize: 0
                }
            }

            Rectangle {
                id: foreground
                anchors.fill: parent

                radius: Theme.componentRadius
                color: "transparent"

                border.width: Theme.componentBorderWidth
                border.color: Theme.colorComponentBorder
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

    ////////////////

    PanelDeviceInfos {
        id: panelDeviceInfos
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 1)
    }

    ////////////////

    PanelDeviceAdvertisement {
        id: panelDeviceAdvertisement
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 2)
    }

    ////////////////

    PanelDeviceServices {
        id: panelDeviceServices
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 3)
    }

    ////////////////

    PanelDeviceLog {
        id: panelDeviceLog
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 4)
    }

    ////////////////
}
