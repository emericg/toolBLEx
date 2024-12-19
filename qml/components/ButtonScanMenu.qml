import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Templates as T

import ComponentLibrary
import DeviceUtils
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors

Rectangle {
    id: control

    height: Theme.componentHeight
    radius: Theme.componentRadius
    color: Theme.colorPrimary
    clip: true

    ////////////////

    ButtonFlat {
        width: control.width - control.height
        height: control.height

        layoutAlignment: Qt.AlignLeft
        colorBackground: Theme.colorPrimary
        colorText: "white"

        ////////////////

        text: {
            if (!selectedDevice) return ""
            if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) return qsTr("scan device")
            if (selectedDevice.status === DeviceUtils.DEVICE_DISCONNECTING) return qsTr("disconnecting...")
            if (selectedDevice.status === DeviceUtils.DEVICE_CONNECTING) return qsTr("connecting...")
            if (selectedDevice.status === DeviceUtils.DEVICE_WORKING) return qsTr("scanning...")
            if (selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED) return qsTr("connected")
        }

        source: {
            if (!selectedDevice || selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                return "qrc:/IconLibrary/material-icons/outlined/bluetooth.svg"

            return UtilsDeviceSensors.getDeviceStatusIcon(selectedDevice.status)
        }

        ////////////////

        onClicked: {
            if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                selectedDevice.actionScanWithValues()
            }
        }

        Connections {
            target: screenScanner.item
            function onSelectedDeviceChanged() { actionMenu.close() }
        }
    }

    ////////////////

    ButtonFlat { // menu toggle
        anchors.right: parent.right
        width: parent.height //+ Theme.componentRadius
        height: parent.height

        color: Qt.darker(control.color, 1.03)
        colorHighlight: "grey"
        source: "qrc:/IconLibrary/material-symbols/more_vert.svg"
        sourceSize: 24

        onClicked: actionMenu.open()
    }

    ////////////////

    Popup { // menu
        id: actionMenu
        x: 0
        y: 0
        width: control.width

        padding: 0
        margins: 0

        modal: true
        dim: false
        clip: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        //enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
        //exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

        ////////

        background: Rectangle {
            radius: Theme.componentRadius
            color: Qt.darker(control.color, 1.03)

            ButtonFlat {
                anchors.right: parent.right
                width: control.height
                height: parent.height

                color: Qt.darker(control.color, 1.03)
                colorHighlight: "grey"

                Item {
                    anchors.right: parent.right
                    width: control.height
                    height: control.height

                    IconSvg {
                        anchors.centerIn: parent
                        width: 24
                        height: 24

                        opacity: enabled ? 1.0 : 0.66
                        color: "white"
                        source: "qrc:/IconLibrary/material-symbols/more_vert.svg"
                    }
                }

                onClicked: (mouse) => {
                    actionMenu.close()
                    //mouse.accepted = true
                }
            }
        }

        ////////

        contentItem: Column {
            topPadding: 0
            bottomPadding: 0
            spacing: -Theme.componentBorderWidth

            ////

            ButtonFlat {
                width: control.width - control.height
                height: control.height

                visible: (selectedDevice && selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                layoutAlignment: Qt.AlignLeft

                color: control.color
                text: qsTr("scan services & data")
                source: "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"
                sourceSize: 20

                onClicked: {
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.actionScanWithValues()
                        actionMenu.close()
                    }
                }
            }

            ////

            ButtonFlat {
                width: control.width - control.height
                height: control.height

                visible: (selectedDevice && selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                layoutAlignment: Qt.AlignLeft

                color: control.color
                text: qsTr("scan services only")
                source: "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"
                sourceSize: 20

                onClicked: {
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.actionScanWithoutValues()
                        actionMenu.close()
                    }
                }
            }

            ////

            ButtonFlat {
                width: control.width - control.height
                height: control.height

                visible: (selectedDevice && selectedDevice.hasServiceCache &&
                          selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                layoutAlignment: Qt.AlignLeft

                color: control.color
                text: qsTr("load from cache")
                source: "qrc:/IconLibrary/material-symbols/save.svg"
                sourceSize: 20

                onClicked: {
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.restoreServiceCache()
                        actionMenu.close()
                    }
                }
            }

            ////

            ButtonFlat { // status
                width: control.width - control.height
                height: control.height

                visible: (selectedDevice && selectedDevice.status !== DeviceUtils.DEVICE_OFFLINE)
                layoutAlignment: Qt.AlignLeft

                color: control.color
                text: {
                    if (!selectedDevice) return ""
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE) return qsTr("scan device")
                    if (selectedDevice.status === DeviceUtils.DEVICE_WORKING) return qsTr("scanning...")
                    if (selectedDevice.status === DeviceUtils.DEVICE_DISCONNECTING) return qsTr("disconnecting...")
                    if (selectedDevice.status === DeviceUtils.DEVICE_CONNECTING) return qsTr("connecting...")
                    if (selectedDevice.status >= DeviceUtils.DEVICE_CONNECTED) return qsTr("connected")
                }
                source: {
                    if (!selectedDevice) return ""
                    if (selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)
                        return "qrc:/IconLibrary/material-icons/outlined/bluetooth.svg"
                    else if (selectedDevice.status <= DeviceUtils.DEVICE_DISCONNECTING ||
                             selectedDevice.status <= DeviceUtils.DEVICE_CONNECTING)
                        return "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"
                    else if (selectedDevice.status === DeviceUtils.DEVICE_WORKING)
                        return "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"
                    else
                        return "qrc:/IconLibrary/material-icons/duotone/bluetooth_connected.svg"
                }

                onClicked: {
                    //
                }
            }

            ////

            ButtonFlat {
                width: control.width - control.height
                height: control.height

                visible: (selectedDevice && selectedDevice.status !== DeviceUtils.DEVICE_OFFLINE)
                layoutAlignment: Qt.AlignLeft

                color: control.color
                text: (selectedDevice && selectedDevice.connected) ? qsTr("disconnect") : qsTr("abort")
                source: "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"

                onClicked: {
                    if (selectedDevice.status !== DeviceUtils.DEVICE_OFFLINE) {
                        selectedDevice.deviceDisconnect()
                        actionMenu.close()
                    }
                }
            }

            ////
        }

        ////////
    }

    ////////////////
}
