import QtQuick
import QtQuick.Controls

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

        SelectorMenuThemed {
            id: deviceMenu
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            height: 32

            enabled: (selectedDevice && selectedDevice.isLowEnergy)
            currentSelection: 1

            model: ListModel {
                id: m1
                ListElement { idx: 1; txt: qsTr("device info"); src: ""; sz: 0; }
                ListElement { idx: 2; txt: qsTr("advertisement"); src: ""; sz: 0; }
                ListElement { idx: 3; txt: qsTr("services"); src: ""; sz: 0; }
            }

            onMenuSelected: (index) => {
                //console.log("SelectorMenu clicked #" + index)
                currentSelection = index
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
