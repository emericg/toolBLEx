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

    Row { // left
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        spacing: 0
        visible: true

        RoundButtonIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48

            opacity: (deviceManager.bluetooth && !deviceManager.scanning) ? 0.4 : 1
            highlightMode: "color"
            source: "qrc:/assets/icons_material/baseline-play_arrow-24px.svg"

            enabled: deviceManager.bluetooth
            onClicked: deviceManager.listenDevices_start()
        }

        RoundButtonIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48

            opacity: (deviceManager.bluetooth && deviceManager.scanning) ? 0.4 : 1
            highlightMode: "color"
            source: "qrc:/assets/icons_material/baseline-stop-24px.svg"

            enabled: deviceManager.bluetooth
            onClicked: deviceManager.listenDevices_stop()
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

                source: deviceManager.scanning ? "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
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
        }

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

                source: "qrc:/assets/icons_material/baseline-wifi_tethering-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                selected: (appContent.state === "Advertiser")
                onClicked: advertiserButtonClicked()
            }
            DesktopHeaderItem {
                id: menuUbertooth
                width: headerHeight
                height: headerHeight

                source: "qrc:/assets/icons_material/baseline-microwave-48px.svg"
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
        opacity: 1
        color: Theme.colorHeaderHighlight
    }

    ////////////
}
