import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0
import DeviceUtils 1.0

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

            // Reset buttons
            panelDeviceInfos.resetButtons()
            panelDeviceServices.resetButtons()
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

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 32

            opacity: (selectedDevice && selectedDevice.status >= DeviceUtils.DEVICE_CONNECTING)
            Behavior on opacity { OpacityAnimator { duration: 233 } }

            color: Theme.colorComponentBackground
            border.width: Theme.componentBorderWidth
            border.color: Theme.colorComponentBorder

            IconSvg {
                anchors.centerIn: parent
                width: 24
                height: 24

                source: UtilsDeviceSensors.getDeviceStatusIcon(selectedDevice.status)
                color: Theme.colorIcon
            }
        }

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

            Row {
                id: contentRow
                height: parent.height
                anchors.centerIn: parent
                spacing: Theme.componentBorderWidth

                SelectorMenuThemedItemBadge {
                    index: 1
                    selected: (deviceMenu.currentSelection === index)

                    text: qsTr("device info")
                    textBadge: ""
                    onClicked: deviceMenu.menuSelected(index)
                    sourceSize: 0
                }
                SelectorMenuThemedItemBadge {
                    index: 2
                    selected: (deviceMenu.currentSelection === index)

                    text: qsTr("advertisement")
                    textBadge: (selectedDevice && selectedDevice.advCount)
                    onClicked: deviceMenu.menuSelected(index)
                    sourceSize: 0
                }
                SelectorMenuThemedItemBadge {
                    index: 3
                    selected: (deviceMenu.currentSelection === index)

                    text: qsTr("services")
                    textBadge: (selectedDevice && selectedDevice.servicesScanned) ? selectedDevice.servicesCount : "?"
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

    ////////////////////////////////////////////////////////////////////////////

    PanelDeviceInfos {
        id: panelDeviceInfos
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 1)
    }

    ////////////////////////////////////////////////////////////////////////////

    PanelDeviceAdvertisement {
        id: panelDeviceAdvertisement
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 2)
    }

    ////////////////////////////////////////////////////////////////////////////

    PanelDeviceServices {
        id: panelDeviceServices
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (deviceMenu.currentSelection === 3)
    }

    ////////////////////////////////////////////////////////////////////////////
}
