import QtQuick

import ComponentLibrary
import AppUtils

Rectangle {
    id: desktopHeader

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    height: headerHeight
    z: 10

    color: Theme.colorHeader
    property int headerHeight: isHdpi ? 52 : 56

    ////////////////

    signal scannerButtonClicked()
    signal simulatorButtonClicked()
    signal ubertoothButtonClicked()
    signal rtlsdrButtonClicked()
    signal settingsButtonClicked()

    ////////////////

    DragHandler {
        // make that surface draggable
        // also, prevent clicks below this area
        onActiveChanged: if (active) appWindow.startSystemMove()
        target: null
    }

    ////////////////

    Rectangle { // left menus
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        width: rowleft.width
        height: 32
        radius: Theme.componentRadius

        clip: true
        color: Theme.colorHeader
        border.width: 2
        border.color: Theme.colorHeaderHighlight

        visible: (appContent.state === "Scanner" ||
                  appContent.state === "Simulator" ||
                  appContent.state === "Ubertooth" ||
                  appContent.state === "RtlSdr")

        Row {
            id: rowleft
            height: 32
            spacing: 0

            SquareButtonSunken {
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48

                sourceSize: 30
                source: {
                    if (appContent.state === "Simulator") return "qrc:/IconLibrary/material-icons/duotone/wifi_tethering.svg"
                    if (appContent.state === "Ubertooth") return "qrc:/IconLibrary/material-icons/duotone/microwave.svg"
                    if (appContent.state === "RtlSdr") return "qrc:/IconLibrary/material-icons/duotone/cell_tower.svg"
                    return "qrc:/IconLibrary/material-icons/duotone/devices.svg"
                }

                colorBackground: Theme.colorHeaderHighlight
            }

            RoundButtonSunken { // start
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                sourceSize: 32
                source: (DeviceManager.scanningPaused) ?
                            "qrc:/IconLibrary/material-symbols/media/pause-fill.svg" :
                            "qrc:/IconLibrary/material-symbols/media/play_arrow-fill.svg"

                colorBackground: "transparent"
                colorHighlight: (opacity === 1) ? Theme.colorHeaderHighlight : Theme.colorHeaderContent
                colorIcon: Theme.colorHeaderContent

                opacity: {
                    if (appContent.state === "Scanner" && DeviceManager.scanning) return 1
                    //if (appContent.state === "Simulator" && BleSimulator.running) return 1
                    if (appContent.state === "Ubertooth" && Ubertooth.running) return 1
                    if (appContent.state === "RtlSdr" && RtlSdr.running) return 1
                    return 0.4
                }

                enabled: {
                    if (appContent.state === "Scanner") return AdapterManager.bluetooth_scan
                    if (appContent.state === "Simulator") return AdapterManager.bluetooth_sim
                    return true
                }

                onClicked: {
                    if (appContent.state === "Scanner") DeviceManager.scanDevices_start()
                    //if (appContent.state === "Simulator") BleSimulator.start()
                    if (appContent.state === "Ubertooth") Ubertooth.startWork()
                    if (appContent.state === "RtlSdr") RtlSdr.startWork()
                }
            }

            RoundButtonSunken { // stop
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                sourceSize: 32
                source: "qrc:/IconLibrary/material-symbols/media/stop-fill.svg"

                colorBackground: "transparent"
                colorHighlight: (opacity === 1) ? Theme.colorHeaderHighlight : Theme.colorHeaderContent
                colorIcon: Theme.colorHeaderContent

                opacity: {
                    if (appContent.state === "Scanner" && !DeviceManager.scanning) return 1
                    //if (appContent.state === "Simulator" && !BleSimulator.running) return 1
                    if (appContent.state === "Ubertooth" && !Ubertooth.running) return 1
                    if (appContent.state === "RtlSdr" && !RtlSdr.running) return 1
                    return 0.4
                }

                enabled: {
                    if (appContent.state === "Scanner") return (AdapterManager.bluetooth_scan || DeviceManager.scanning)
                    if (appContent.state === "Simulator") return (AdapterManager.bluetooth_sim || BleSimulator.running)
                    return true
                }

                onClicked: {
                    if (appContent.state === "Scanner") DeviceManager.scanDevices_stop()
                    //if (appContent.state === "Simulator") BleSimulator.stop()
                    if (appContent.state === "Ubertooth") Ubertooth.stopWork()
                    if (appContent.state === "RtlSdr") RtlSdr.stopWork()
                }
            }
        }
    }

    ////////////

    Rectangle { // center indicator
        anchors.centerIn: parent
        width: parent.width * 0.5
        height: 32
        radius: 8

        clip: true
        color: Theme.colorHeaderHighlight
        border.width: 2
        border.color: Qt.darker(Theme.colorHeaderHighlight, 1.01)

        ////////

        Row {
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            spacing: 8

            IconSvg {
                height: 20; width: 20;
                anchors.verticalCenter: parent.verticalCenter

                source: {
                    if (DeviceManager.scanningPaused) return "qrc:/IconLibrary/material-symbols/pause-fill.svg"
                    if (DeviceManager.scanning) return "qrc:/IconLibrary/material-symbols/autorenew.svg"
                    return "qrc:/IconLibrary/material-symbols/media/stop-fill.svg"
                }
                color: Theme.colorText

                NumberAnimation on rotation {
                    running: (DeviceManager.scanning && !DeviceManager.scanningPaused)
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    duration: 2000
                    from: 0
                    to: 360
                    easing.type: Easing.Linear
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: {
                    if (DeviceManager.scanningPaused) return qsTr("Scanning paused")
                    if (DeviceManager.scanning) return qsTr("Scanning for Bluetooth devices nearby")
                    return qsTr("Not scanning")
                }
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }

            ////

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: false // BleSimulator.running

                text: "  |  "
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }

            ////

            IconSvg {
                height: 20; width: 20;
                anchors.verticalCenter: parent.verticalCenter

                visible: false // BleSimulator.running
                source: "qrc:/IconLibrary/material-icons/duotone/wifi_tethering.svg"
                color: Theme.colorText

                SequentialAnimation on opacity {
                    running: false // BleSimulator.running
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    PropertyAnimation { to: 0.5; duration: 666; }
                    PropertyAnimation { to: 1; duration: 666; }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter

                //text: BleSimulator.running ? qsTr("Virtual device is running") : ""
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }

            ////

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: Ubertooth.running

                text: "  |  "
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }

            ////

            IconSvg {
                height: 20; width: 20;
                anchors.verticalCenter: parent.verticalCenter

                visible: Ubertooth.running
                source: "qrc:/IconLibrary/material-icons/duotone/microwave.svg"
                color: Theme.colorText

                SequentialAnimation on opacity {
                    running: Ubertooth.running
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    PropertyAnimation { to: 0.5; duration: 666; }
                    PropertyAnimation { to: 1; duration: 666; }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: Ubertooth.running

                text: qsTr("Ubertooth is running")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        ////////

        Row {
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            spacing: 8

            //FpsMonitor { anchors.verticalCenter: parent.verticalCenter }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: DeviceManager.scanning

                text: qsTr("%n device(s) found", "", DeviceManager.deviceCountFound)
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }

        ////////
    }

    ////////////

    Row { // right
        id: rowright
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        spacing: isHdpi ? 4 : 12
        visible: true

        // MAIN MENU

        Row {
            id: menuMain

            spacing: 0

            DesktopHeaderItem {
                id: menuScanner
                width: headerHeight
                height: headerHeight

                source: "qrc:/IconLibrary/material-icons/duotone/devices.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                highlighted: (appContent.state === "Scanner")
                onClicked: scannerButtonClicked()

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 6

                    width: 12
                    height: 12
                    radius: 12
                    color: Theme.colorGreen

                    opacity: DeviceManager.scanning ? 0.8 : 0
                    Behavior on opacity { OpacityAnimator { duration: 333 } }
                }
            }
            DesktopHeaderItem {
                id: menuSimulator
                width: headerHeight
                height: headerHeight

                source: "qrc:/IconLibrary/material-icons/duotone/wifi_tethering.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                visible: UtilsApp.isDebugBuild()
                highlighted: (appContent.state === "Simulator")
                onClicked: simulatorButtonClicked()

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 6

                    width: 12
                    height: 12
                    radius: 12
                    color: Theme.colorGreen

                    opacity: 0 // BleSimulator.running ? 0.8 : 0
                    Behavior on opacity { OpacityAnimator { duration: 333 } }
                }
            }
            DesktopHeaderItem {
                id: menuUbertooth
                width: headerHeight
                height: headerHeight

                source: "qrc:/IconLibrary/material-icons/duotone/microwave.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                visible: Ubertooth.toolsAvailable
                highlighted: (appContent.state === "Ubertooth")
                onClicked: ubertoothButtonClicked()

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 6

                    width: 12
                    height: 12
                    radius: 12
                    color: Theme.colorGreen

                    opacity: Ubertooth.running ? 0.8 : 0
                    Behavior on opacity { OpacityAnimator { duration: 333 } }
                }
            }
            DesktopHeaderItem {
                id: menuRtlSdr
                width: headerHeight
                height: headerHeight

                source: "qrc:/IconLibrary/material-icons/duotone/cell_tower.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                visible: RtlSdr.toolsAvailable
                highlighted: (appContent.state === "RtlSdr")
                onClicked: rtlsdrButtonClicked()

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 6

                    width: 12
                    height: 12
                    radius: 12
                    color: Theme.colorGreen

                    opacity: RtlSdr.running ? 0.8 : 0
                    Behavior on opacity { OpacityAnimator { duration: 333 } }
                }
            }
            DesktopHeaderItem {
                id: menuSettings
                width: headerHeight
                height: headerHeight

                source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                highlighted: (appContent.state === "Settings")
                onClicked: settingsButtonClicked()
            }
        }
    }

    ////////////

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 2
        opacity: 1
        color: Theme.colorHeaderHighlight
    }

    ////////////
}
