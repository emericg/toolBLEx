// UtilsDeviceSensors.js
// Version 5

.import DeviceUtils as DeviceUtils
.import ComponentLibrary as ThemeEngine

/* ************************************************************************** */

function getDeviceStatusText(deviceStatus) {
    var txt = ""

    if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_OFFLINE) {
        txt = qsTr("Offline")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_QUEUED) {
        txt = qsTr("Queued")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_DISCONNECTING) {
        txt = qsTr("Disconnecting...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTING) {
        txt = qsTr("Connecting...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTED) {
        txt = qsTr("Connected")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_WORKING) {
        txt = qsTr("Working...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING) {
        txt = qsTr("Updating...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_HISTORY) {
        txt = qsTr("Syncing...")
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_REALTIME) {
        txt = qsTr("Realtime data")
    }

    return txt + " "
}

function getDeviceStatusColor(deviceStatus) {
    var clr = ""

    if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_OFFLINE) {
        clr = ThemeEngine.Theme.colorRed
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_QUEUED ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_DISCONNECTING ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTING) {
        clr = ThemeEngine.Theme.colorYellow
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTED) {
        clr = ThemeEngine.Theme.colorGreen
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_WORKING) {
        clr = ThemeEngine.Theme.colorYellow
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_HISTORY ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_REALTIME) {
        clr = ThemeEngine.Theme.colorYellow
    }

    return clr
}

function getDeviceStatusIcon(deviceStatus) {
    var src = "qrc:/IconLibrary/material-icons/outlined/bluetooth.svg"

    if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_OFFLINE) {
        src = "qrc:/IconLibrary/material-icons/outlined/bluetooth_disabled.svg"
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_QUEUED ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_DISCONNECTING ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTING) {
        src = "qrc:/IconLibrary/material-icons/duotone/settings_bluetooth.svg"
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_CONNECTED) {
        src = "qrc:/IconLibrary/material-icons/duotone/bluetooth_connected.svg"
    } else if (deviceStatus === DeviceUtils.DeviceUtils.DEVICE_WORKING ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_HISTORY ||
               deviceStatus === DeviceUtils.DeviceUtils.DEVICE_UPDATING_REALTIME) {
        src = "qrc:/IconLibrary/material-icons/duotone/bluetooth_searching.svg"
    }

    return src
}

/* ************************************************************************** */

function getDeviceBatteryIcon(batteryLevel) {
    var src = ""

    if (batteryLevel > 95) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_full.svg";
    } else if (batteryLevel > 85) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_90.svg";
    } else if (batteryLevel > 75) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_80.svg";
    } else if (batteryLevel > 65) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_70.svg";
    } else if (batteryLevel > 55) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_60.svg";
    } else if (batteryLevel > 45) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_50.svg";
    } else if (batteryLevel > 35) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_40.svg";
    } else if (batteryLevel > 25) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_30.svg";
    } else if (batteryLevel > 15) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_20.svg";
    } else if (batteryLevel >  1) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_10.svg";
    } else if (batteryLevel >= 0) {
        src = "qrc:/IconLibrary/material-icons/duotone/battery_unknown.svg";
    }

    return src
}

function getDeviceBatteryColor(batteryLevel) {
    var clr = ""

    if (batteryLevel <= 0) {
        clr = ThemeEngine.Theme.colorRed
    } else if (batteryLevel <= 10) {
        clr = ThemeEngine.Theme.colorYellow
    } else {
        clr = ThemeEngine.Theme.colorIcon
    }

    return clr
}

/* ************************************************************************** */
