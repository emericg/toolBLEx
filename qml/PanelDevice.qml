import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0

Item {
    id: panelDevice
    anchors.fill: parent

    function checkMenuSelection() {
        if (selectedDevice) {
            // Make sure we switch back to the first tab
            if (!selectedDevice.isLowEnergy) {
                deviceMenu.currentSelection = 1
            }
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

                border.width: Theme.componentBorderWidth
                border.color: Theme.colorComponentBorder

                layer.enabled: false
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }

                Row {
                    id: contentRow
                    height: parent.height
                    anchors.centerIn: parent
                    spacing: 0

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
                        textBadge: selectedDevice.advCount
                        onClicked: deviceMenu.menuSelected(index)
                        sourceSize: 0
                    }
                    SelectorMenuThemedItemBadge {
                        index: 3
                        selected: (deviceMenu.currentSelection === index)

                        text: qsTr("services")
                        textBadge: selectedDevice.servicesCount
                        onClicked: deviceMenu.menuSelected(index)
                        sourceSize: 0
                    }
                }
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
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        visible: (deviceMenu.currentSelection === 1)
    }

    ////////////////////////////////////////////////////////////////////////////

    PanelDeviceAdvertisement {
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        visible: (deviceMenu.currentSelection === 2)
    }

    ////////////////////////////////////////////////////////////////////////////

    PanelDeviceServices {
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        visible: (deviceMenu.currentSelection === 3)
    }

    ////////////////////////////////////////////////////////////////////////////
}
