import QtQuick
import QtQuick.Controls

import ComponentLibrary
import AppUtils

Loader {
    id: screenSettings
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        screenSettings.active = true
        appContent.state = "Settings"
    }

    function backAction() {
        if (screenSettings.status === Loader.Ready)
            screenSettings.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    // Restart timers
    // If a sensible setting is modified many times in a short amount of time (we use
    // a 1 secon window) then applying that setting will be delayed until no more
    // modifications are registered

    Timer {
        id: restartScannerTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (deviceManager.scanning) {
                deviceManager.scanDevices_restart()
            }
        }
    }
    Timer {
        id: restartUbertoothTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (ubertooth.running) {
                ubertooth.restartWork()
            }
        }
    }
    Timer {
        id: restartRtlSdrTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (rtlsdr.running) {
                rtlsdr.restartWork()
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////

    Loader {
        id: popupLoader_cacheseen

        active: false
        asynchronous: false
        sourceComponent: PopupClearDeviceSeenCache {
            id: popupClearSeenCache
            parent: appContent
        }
    }

    Loader {
        id: popupLoader_cachestructure

        active: false
        asynchronous: false
        sourceComponent: PopupClearDeviceStructureCache {
            id: popupClearStructureCache
            parent: appContent
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    opacity: active ? 1 : 0
    Behavior on opacity { OpacityAnimator { duration: 233 } }

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        function backAction() {
            if (exportDirectory.focus) {
                exportDirectory.focus = false
                return
            }
            if (ubertoothPath.focus) {
                ubertoothPath.focus = false
                return
            }

            screenScanner.loadScreen()
        }

        ////////////////////////////////////////////////////////////////////////

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: settingsColumn.height

            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBarThemed { policy: ScrollBar.AsNeeded; }

            Column {
                id: settingsColumn
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: 0
                bottomPadding: Theme.componentMarginL
                spacing: Theme.componentMarginL

                property int flowElementWidth: (width >= 1080) ? (width - (spacing*4)) / 3
                                                               : (width - (spacing*3)) / 2

                // HEADER //////////////////////////////////////////////////////

                Rectangle {
                    id: settingsHeader
                    anchors.left: parent.left
                    anchors.right: parent.right

                    z: 5
                    clip: true
                    height: isHdpi ? 200 : 230
                    color: (Theme.currentTheme === Theme.THEME_DESKTOP_LIGHT) ? "#69b7ff" : "#b184f6"

                    Image {
                        anchors.fill: parent
                        source: "qrc:/assets/gfx/pattern_ble.png"
                        fillMode: Image.Tile
                        opacity: 0.20
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        spacing: 64

                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 160
                            height: 160

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 160
                                height: 160
                                radius: 160
                                color: "#f9f8f7" // Theme.colorBackground
                                border.width: 2
                                border.color: "#e8e8e8" // Theme.colorSeparator
                                opacity: 0.8
                            }

                            IconSvg {
                                anchors.centerIn: parent
                                width: 140
                                height: 140
                                source: "qrc:/IconLibrary/material-icons/duotone/bluetooth_connected.svg"
                                color: "#5483EF" // Theme.colorBlue
                            }

                            Rectangle {
                                id: circlePulseAnimation
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: 160
                                height: 160
                                radius: 160

                                z: -1
                                opacity: 1
                                color: "#f9f8f7" // Theme.colorBackground

                                ParallelAnimation {
                                    running: (deviceManager.scanning && !deviceManager.scanningPaused && appContent.state === "Settings")
                                    alwaysRunToEnd: true
                                    loops: Animation.Infinite

                                    NumberAnimation { target: circlePulseAnimation; property: "width"; from: 160; to: 400; duration: 2000; }
                                    NumberAnimation { target: circlePulseAnimation; property: "height"; from: 160; to: 400; duration: 2000; }
                                    OpacityAnimator { target: circlePulseAnimation; from: 0.33; to: 0; duration: 2000; }
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Row {
                                spacing: 32

                                Text {
                                    id: title
                                    anchors.bottom: parent.bottom

                                    text: "toolBLEx"
                                    textFormat: Text.PlainText
                                    font.pixelSize: 40
                                    color: "white" // Theme.colorText
                                }

                                Text {
                                    anchors.baseline: title.baseline

                                    text: qsTr("version %1 %2").arg(UtilsApp.appVersion()).arg(UtilsApp.appBuildMode())
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentBig
                                    color: "white" // Theme.colorSubText
                                }

                                Text {
                                    anchors.baseline: title.baseline

                                    visible: UtilsApp.isDebugBuild()
                                    text: qsTr("built on %1").arg(UtilsApp.appBuildDateTime())
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentBig
                                    color: "white" // Theme.colorSubText
                                }
                            }

                            Text {
                                text: qsTr("A Bluetooth Low Energy device scanner and analyzer")
                                font.pixelSize: Theme.fontSizeContentVeryVeryBig
                                color: "white" // Theme.colorSubText
                            }

                            Item { width: 8; height: 8; }

                            Row {
                                spacing: Theme.componentMarginL

                                ButtonSolid {
                                    width: 160
                                    height: 40
                                    color: "#5483EF"
                                    font.bold: true

                                    text: qsTr("WEBSITE")
                                    //sourceSize: 28
                                    //source: "qrc:/IconLibrary/material-symbols/link.svg"
                                    //onClicked: Qt.openUrlExternally("https://emeric.io/toolBLEx")
                                    sourceSize: 20
                                    source: "qrc:/assets/gfx/logos/github.svg"
                                    onClicked: Qt.openUrlExternally("https://github.com/emericg/toolBLEx")
                                }

                                ButtonSolid {
                                    width: 160
                                    height: 40
                                    sourceSize: 22
                                    color: "#5483EF"
                                    font.bold: true

                                    text: qsTr("SUPPORT")
                                    source: "qrc:/IconLibrary/material-symbols/support.svg"
                                    onClicked: Qt.openUrlExternally("https://github.com/emericg/toolBLEx/issues")
                                }

                                ButtonSolid {
                                    height: 40
                                    sourceSize: 22
                                    color: "#5483EF"
                                    font.bold: true

                                    text: qsTr("DONATE")
                                    source: "qrc:/IconLibrary/material-symbols/favorite.svg"
                                    onClicked: Qt.openUrlExternally("https://www.paypal.com/paypalme/EmericGrange")
                                }

                                ButtonSolid {
                                    height: 40
                                    sourceSize: 22
                                    color: "#5483EF"
                                    font.bold: true

                                    text: qsTr("RELEASE NOTES")
                                    source: "qrc:/IconLibrary/material-symbols/new_releases.svg"
                                    onClicked: Qt.openUrlExternally("https://github.com/emericg/toolBLEx/releases")
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

                // SETTINGS ////////////////////////////////////////////////////

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.componentMarginL

                    flow: Flow.LeftToRight // Flow.TopToBottom
                    spacing: Theme.componentMarginL

                    ////////////////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: Theme.componentMarginL

                        SettingsApp {
                            width: settingsColumn.flowElementWidth
                        }

                        Loader { // DEBUG PANEL
                            active: true // UtilsApp.isDebugBuild()
                            asynchronous: true
                            sourceComponent:  SettingsInfo {
                                width: settingsColumn.flowElementWidth
                            }
                        }

                        SettingsCredits {
                            width: settingsColumn.flowElementWidth
                        }
                    }

                    ////////////////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: Theme.componentMarginL

                        SettingsScanner {
                            width: settingsColumn.flowElementWidth
                        }

                        SettingsAdvertiser {
                            width: settingsColumn.flowElementWidth
                        }
                    }

                    ////////////////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: Theme.componentMarginL

                        SettingsSpectrum {
                            width: settingsColumn.flowElementWidth
                        }
                    }

                    ////////////////
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
