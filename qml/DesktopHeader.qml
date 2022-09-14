import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: desktopHeader
    width: parent.width
    height: headerHeight
    z: 10

    color: Theme.colorHeader
    property int headerHeight: isHdpi ? 48 : 56

    ////////////////////////////////////////////////////////////////////////////

    signal scannerButtonClicked()
    signal advertiserButtonClicked()
    signal ubertoothButtonClicked()
    signal settingsButtonClicked()

    ////////////////////////////////////////////////////////////////////////////

    DragHandler {
        // make that surface draggable
        // also, prevent clicks below this area
        onActiveChanged: if (active) appWindow.startSystemMove()
        target: null
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.centerIn: rowleft
        width: rowleft.width
        height: 32
        radius: Theme.componentRadius

        visible: rowleft.visible
        color: Theme.colorHeader
        border.width: 2
        border.color: Theme.colorHeaderHighlight
    }

    Row { // left
        id: rowleft
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        spacing: 0

        visible: (appContent.state === "Scanner" ||
                  appContent.state === "Advertiser" ||
                  appContent.state === "Ubertooth")

        RoundButtonIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 32
            sourceSize: 28

            background: true
            backgroundColor: Theme.colorHeaderHighlight
            opacity: 1
            highlightMode: "off"
            iconColor: Theme.colorIcon
            source: {
                if (appContent.state === "Advertiser") return "qrc:/assets/icons_material/duotone-wifi_tethering-24px.svg"
                if (appContent.state === "Ubertooth") return "qrc:/assets/icons_material/duotone-microwave-48px.svg"
                return "qrc:/assets/icons_material/duotone-devices-24px.svg"
            }
        }

        RoundButtonIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            sourceSize: 32

            enabled: deviceManager.bluetooth
            highlightMode: "color"
            iconColor: Theme.colorHeaderContent
            source: "qrc:/assets/icons_material/baseline-play_arrow-24px.svg"

            opacity: {
                if (appContent.state === "Scanner" && deviceManager.scanning) return 1
                if (appContent.state === "Advertiser" && deviceManager.advertising) return 1
                if (appContent.state === "Ubertooth" && ubertooth.running) return 1
                return 0.4
            }
            onClicked: {
                if (appContent.state === "Scanner") deviceManager.scanDevices_start()
                //if (appContent.state === "Advertiser") deviceManager.advertise_start()
                if (appContent.state === "Ubertooth") ubertooth.startWork()
            }
        }

        RoundButtonIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            sourceSize: 32

            enabled: deviceManager.bluetooth
            highlightMode: "color"
            iconColor: Theme.colorHeaderContent
            source: "qrc:/assets/icons_material/baseline-stop-24px.svg"

            opacity: {
                if (appContent.state === "Scanner" && !deviceManager.scanning) return 1
                if (appContent.state === "Advertiser" && !deviceManager.advertising) return 1
                if (appContent.state === "Ubertooth" && !ubertooth.running) return 1
                return 0.4
            }

            onClicked: {
                if (appContent.state === "Scanner") deviceManager.scanDevices_stop()
                //if (appContent.state === "Advertiser") deviceManager.advertise_stop()
                if (appContent.state === "Ubertooth") ubertooth.stopWork()
            }
        }
    }

    ////////////

    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.5
        height: 32
        radius: 8

        color: Theme.colorHeaderHighlight
        border.width: 1
        border.color: Theme.colorHeaderHighlight

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

                source: (deviceManager.scanning)
                            ? "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                            : "qrc:/assets/icons_material/baseline-pause-24px.svg"
                color: Theme.colorText

                NumberAnimation on rotation {
                    running: deviceManager.scanning
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
                text: deviceManager.scanning ? qsTr("Scanning for Bluetooth devices nearby") : qsTr("Not scanning")
                color: Theme.colorText
            }

            ////

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: deviceManager.advertising
                text: "  |  "
                color: Theme.colorText
            }

            ////

            IconSvg {
                height: 20; width: 20;
                anchors.verticalCenter: parent.verticalCenter

                visible: deviceManager.advertising
                source: "qrc:/assets/icons_material/duotone-wifi_tethering-24px.svg"
                color: Theme.colorText

                SequentialAnimation on opacity {
                    running: deviceManager.advertising
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    PropertyAnimation { to: 0.5; duration: 666; }
                    PropertyAnimation { to: 1; duration: 666; }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: deviceManager.advertising ? qsTr("Virtual device is running") : ""
                color: Theme.colorText
            }

            ////

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: ubertooth.running
                text: "  |  "
                color: Theme.colorText
            }

            ////

            IconSvg {
                height: 20; width: 20;
                anchors.verticalCenter: parent.verticalCenter

                visible: ubertooth.running
                source: "qrc:/assets/icons_material/duotone-microwave-48px.svg"
                color: Theme.colorText

                SequentialAnimation on opacity {
                    running: ubertooth.running
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    PropertyAnimation { to: 0.5; duration: 666; }
                    PropertyAnimation { to: 1; duration: 666; }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ubertooth.running ? qsTr("Ubertooth is running") : ""
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

            Text {
                anchors.verticalCenter: parent.verticalCenter

                visible: deviceManager.scanning
                text: qsTr("%1 device(s) found").arg(deviceManager.deviceCount)
                color: Theme.colorText
            }
        }
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

                source: "qrc:/assets/icons_material/duotone-devices-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                selected: (appContent.state === "Scanner")
                onClicked: scannerButtonClicked()
            }
            DesktopHeaderItem {
                id: menuAdvertiser
                width: headerHeight
                height: headerHeight

                source: "qrc:/assets/icons_material/duotone-wifi_tethering-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                selected: (appContent.state === "Advertiser")
                onClicked: advertiserButtonClicked()
            }
            DesktopHeaderItem {
                id: menuUbertooth
                width: headerHeight
                height: headerHeight

                source: "qrc:/assets/icons_material/duotone-microwave-48px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                visible: ubertooth.toolsAvailable
                selected: (appContent.state === "Ubertooth")
                onClicked: ubertoothButtonClicked()
            }
            DesktopHeaderItem {
                id: menuSettings
                width: headerHeight
                height: headerHeight

                source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                selected: (appContent.state === "Settings")
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
        opacity: 0.8
        color: Theme.colorHeaderHighlight
    }

    ////////////
}
