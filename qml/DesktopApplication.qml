import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ComponentLibrary
import DeviceUtils

ApplicationWindow {
    id: appWindow
    flags: Qt.Window
    color: Theme.colorBackground

    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false
    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)

    // Desktop stuff ///////////////////////////////////////////////////////////

    minimumWidth: 960
    minimumHeight: 640

    width: {
        if (settingsManager.initialSize.width > 0)
            return settingsManager.initialSize.width
        else
            return isHdpi ? 960 : 1280
    }
    height: {
        if (settingsManager.initialSize.height > 0)
            return settingsManager.initialSize.height
        else
            return isHdpi ? 640 : 720
    }
    x: settingsManager.initialPosition.width
    y: settingsManager.initialPosition.height
    visibility: settingsManager.initialVisibility
    visible: true

    WindowGeometrySaver {
        windowInstance: appWindow
    }

    // Mobile stuff ////////////////////////////////////////////////////////////

    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNotch: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        // Load preferred screen
        if (settingsManager.preferredScreen === 0) {
            screenScanner.loadScreen()
        } else if (settingsManager.preferredScreen === 1) {
            screenAdvertiser.loadScreen()
        } else if (settingsManager.preferredScreen === 2 && ubertooth.toolsAvailable) {
            screenUbertooth.loadScreen()
        } else {
            screenScanner.loadScreen() // default to scanner
        }
    }

    Connections {
        target: appHeader
        function onScannerButtonClicked() { screenScanner.loadScreen() }
        function onAdvertiserButtonClicked() { screenAdvertiser.loadScreen() }
        function onUbertoothButtonClicked() { screenUbertooth.loadScreen() }
        function onSettingsButtonClicked() { screenSettings.loadScreen() }
    }

    Connections {
        target: menubarManager
        function onSensorsClicked() { screenScanner.loadScreen() }
        function onAboutClicked() { screenSettings.loadScreen() }
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {

                case Qt.ApplicationInactive: {
                    //console.log("Qt.ApplicationInactive")

                    // Pause scanning (if needed)
                    pauseTimer.start()

                    break
                }

                case Qt.ApplicationActive: {
                    //console.log("Qt.ApplicationActive")

                    // Check Bluetooth anyway (on macOS)
                    //if (Qt.platform.os === "osx") deviceManager.checkBluetooth()

                    // Resume scanning (if needed)
                    pauseTimer.stop()
                    deviceManager.scanDevices_resume();

                    break
                }

            }
        }
    }

    onVisibilityChanged: (visibility) => {
        //console.log("onVisibilityChanged(" + visibility + ")")

        if (visibility === Window.Hidden) {
            if (Qt.platform.os === "osx") {
                utilsDock.toggleDockIconVisibility(false)
            }
        }
        if (visibility === Window.AutomaticVisibility ||
            visibility === Window.Minimized || visibility === Window.Maximized ||
            visibility === Window.Windowed || visibility === Window.FullScreen) {
            //
        }

        if (visibility === Window.Hidden) {
            //deviceManager.disconnectDevices()
        }
    }

    Timer {
        id: pauseTimer
        running: false
        repeat: false
        interval: 3333
        onTriggered: deviceManager.scanDevices_pause()
    }

    // User generated events handling //////////////////////////////////////////

    function backAction() {
        if (appContent.state === "Scanner") {
            screenScanner.backAction()
        } else if (appContent.state === "Advertiser") {
            screenAdvertiser.backAction()
        } else if (appContent.state === "Ubertooth") {
            screenUbertooth.backAction()
        } else if (appContent.state === "Settings") {
            screenSettings.backAction()
        } else { // default
            if (appContent.previousStates.length) {
                appContent.previousStates.pop()
                appContent.state = appContent.previousStates[appContent.previousStates.length-1]
            } else {
                screenScanner.loadScreen()
            }
        }
    }
    function forwardAction() {
        //
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.BackButton) {
                backAction()
            } else if (mouse.button === Qt.ForwardButton) {
                forwardAction()
            }
        }
    }

    Shortcut {
        sequences: [StandardKey.Back, StandardKey.Backspace]
        onActivated: backAction()
    }
    Shortcut {
        sequences: [StandardKey.Forward]
        onActivated: forwardAction()
    }
    Shortcut {
        sequences: [StandardKey.Refresh]
        onActivated: deviceManager.scanDevices_start()
    }
    Shortcut {
        sequence: "Ctrl+F5"
        onActivated: deviceManager.scanDevices_start()
    }
    Shortcut {
        sequence: StandardKey.Preferences
        onActivated: screenSettings.loadScreen()
    }
    Shortcut {
        sequences: [StandardKey.Close]
        onActivated: appWindow.close()
    }
    Shortcut {
        sequence: StandardKey.Quit
        onActivated: utilsApp.appExit()
    }

    // UI sizes ////////////////////////////////////////////////////////////////

    property bool headerUnicolor: (Theme.colorHeader === Theme.colorBackground)

    property bool singleColumn: {
        if (isMobile) {
            if (screenOrientation === Qt.PortraitOrientation ||
                (isTablet && width < 480)) { // can be a 2/3 split screen on tablet
                return true
            } else {
                return false
            }
        } else {
            return (appWindow.width < appWindow.height)
        }
    }

    property bool wideMode: (isDesktop && width >= 560) || (isTablet && width >= 480)
    property bool wideWideMode: (width >= 640)

    // Fonts ///////////////////////////////////////////////////////////////////

    Text { id: defdefdef; }
    property string fontDefault: defdefdef.font.family
    property string fontMonospace: "Courier New" // "Monospace" // "Consolas"

    // Bluetooth ///////////////////////////////////////////////////////////////

    property bool bluetooth: deviceManager.bluetooth
    property bool bluetoothAdapter: deviceManager.bluetoothAdapter
    property bool bluetoothEnabled: deviceManager.bluetoothEnabled
    property bool bluetoothPermissions: deviceManager.bluetoothPermissions

    onBluetoothChanged: checkBleStatus()
    onBluetoothAdapterChanged: checkBleStatus()
    onBluetoothEnabledChanged: checkBleStatus()
    onBluetoothPermissionsChanged: checkBleStatus()

    function checkBleStatus() {
        if (!bluetooth || !bluetoothAdapter || !bluetoothEnabled || !bluetoothPermissions) {
            screenBluetooth.loadScreen()
        } else {
            screenBluetooth.unloadScreen()
        }
    }

    // QML /////////////////////////////////////////////////////////////////////

    DesktopHeader {
        id: appHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item {
        id: appContent
        anchors.top: appHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        ScreenScanner {
            anchors.fill: parent
            id: screenScanner
        }
        ScreenAdvertiser {
            anchors.fill: parent
            id: screenAdvertiser
        }
        ScreenBluetooth { // is on top of the scanner and advertiser tabs
            anchors.fill: parent
            id: screenBluetooth
        }

        ScreenUbertooth {
            anchors.fill: parent
            id: screenUbertooth
        }

        ScreenSettings {
            anchors.fill: parent
            id: screenSettings
        }

        // Initial state
        state: ""

        property var previousStates: []

        onStateChanged: {
            //screenScanner.exitSelectionMode()
            //appHeader.setActiveMenu()

            if (previousStates[previousStates.length-1] !== state) previousStates.push(state)
            if (previousStates.length > 4) previousStates.splice(0, 1)
            //console.log("states > " + appContent.previousStates)
        }

        states: [
            State {
                name: "Scanner"
                PropertyChanges { target: screenScanner; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenAdvertiser; visible: false; enabled: false; }
                PropertyChanges { target: screenBluetooth; visible: true; enabled: true; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "Advertiser"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenAdvertiser; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenBluetooth; visible: true; enabled: true; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "Ubertooth"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenAdvertiser; visible: false; enabled: false; }
                PropertyChanges { target: screenBluetooth; visible: false; enabled: false; }
                PropertyChanges { target: screenUbertooth; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenAdvertiser; visible: false; enabled: false; }
                PropertyChanges { target: screenBluetooth; visible: false; enabled: false; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: true; enabled: true; focus: true; }
            }
        ]
    }

    // Loading screen //////////////////////////////////////////////////////////

    Loader {
        id: appSplashLoader
        anchors.centerIn: parent

        z: 20
        active: false
        asynchronous: false

        Component.onCompleted: {
            // Load splash screen?
            appSplashLoader.active = settingsManager.appSplashScreen
        }

        sourceComponent: Item {
            Rectangle {
                id: appSplash
                anchors.centerIn: parent
                color: Theme.colorBackground

                Timer {
                    id: splashTimer_fadeout
                    running: true
                    repeat: false
                    interval: 333
                    onTriggered: {
                        appSplash.width = 0
                        appSplashImage.opacity = 0
                        splashTimer_unload.start()
                    }
                }
                Timer {
                    id: splashTimer_unload
                    running: false
                    repeat: false
                    interval: 1000
                    onTriggered: {
                        appSplashLoader.sourceComponent = undefined
                    }
                }

                clip: true
                width: appWindow.width*2
                height: width
                radius: width
                Behavior on width { NumberAnimation { duration: 500; } }

                Image {
                    id: appSplashImage
                    anchors.centerIn: parent
                    width: 320
                    height: 320
                    source: "qrc:/assets/gfx/logos/splash.svg"
                    sourceSize: Qt.size(width, height)

                    Behavior on opacity { OpacityAnimator { duration: 666; } }
                }
            }
        }
    }

    // Exit ////////////////////////////////////////////////////////////////////

    Timer {
        id: disconnectTimer
        running: false
        repeat: false
        interval: 333
        onTriggered: {
            if (!deviceManager.areDevicesConnected()) {
                appWindow.close()
            }
        }
    }

    onClosing: (close) => {
        //console.log("onClosing(" + close + ")")

        // macOS minimize to dock
        if (Qt.platform.os === "osx") {
            appWindow.hide()

            close.accepted = false
            return
        }

        // If devices are still connected, disconnect them first
        if (deviceManager.areDevicesConnected()) {
            deviceManager.disconnectDevices()
            disconnectTimer.start()

            close.accepted = false
            return
        }
    }

    /////////////////////////////////////////////////////////////////////
}
