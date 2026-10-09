import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ComponentLibrary
import AppUtils
import DeviceUtils

ApplicationWindow {
    id: appWindow

    flags: Qt.Window
    color: Theme.colorBackground

    // Helpers
    property bool isHdpi: (UtilsScreen.screenDpi >= 128 || UtilsScreen.screenPar >= 2.0)
    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false

    // Setup ThemeEngine
    Binding { target: Theme; property: "appTheme";               value: SettingsManager.appTheme }
    Binding { target: Theme; property: "appThemeAuto";           value: SettingsManager.appThemeAuto }
    Binding { target: Theme; property: "appThemeAutoMethod";     value: SettingsManager.appThemeAutoMethod }
    Binding { target: Theme; property: "appWidth";               value: appWindow.width }
    Binding { target: Theme; property: "appHeight";              value: appWindow.height }
    Binding { target: Theme; property: "screenDpi";              value: UtilsScreen.screenDpiPhysical }
    Binding { target: Theme; property: "screenDpiLogical";       value: UtilsScreen.screenDpiLogical }
    Binding { target: Theme; property: "screenPar";              value: UtilsScreen.screenPar }
    Binding { target: Theme; property: "screenSize";             value: UtilsScreen.screenSize }

    // Desktop stuff ///////////////////////////////////////////////////////////

    minimumWidth: 960
    minimumHeight: 640

    width: {
        if (SettingsManager.initialSize.width > 0)
            return SettingsManager.initialSize.width
        else
            return isHdpi ? 960 : 1280
    }
    height: {
        if (SettingsManager.initialSize.height > 0)
            return SettingsManager.initialSize.height
        else
            return isHdpi ? 640 : 720
    }
    x: SettingsManager.initialPosition.width
    y: SettingsManager.initialPosition.height
    visibility: SettingsManager.initialVisibility
    visible: true

    WindowGeometrySaver {
        windowInstance: appWindow
    }

    // Mobile stuff ////////////////////////////////////////////////////////////

    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNotch: 0
    property int screenPaddingTop: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0
    property int screenPaddingNavbar: 0

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        // Load preferred screen
        if (SettingsManager.preferredScreen === 0) {
            screenScanner.loadScreen()
        } else if (SettingsManager.preferredScreen === 1) {
            screenSimulator.loadScreen()
        } else if (SettingsManager.preferredScreen === 2 && Ubertooth.toolsAvailable) {
            screenUbertooth.loadScreen()
        } else if (SettingsManager.preferredScreen === 2 && RtlSdr.toolsAvailable) {
            screenRtlSdr.loadScreen()
        } else {
            screenScanner.loadScreen() // default to scanner
        }
    }

    Connections {
        target: appHeader
        function onScannerButtonClicked() { screenScanner.loadScreen() }
        function onSimulatorButtonClicked() { screenSimulator.loadScreen() }
        function onUbertoothButtonClicked() { screenUbertooth.loadScreen() }
        function onRtlsdrButtonClicked() { screenRtlSdr.loadScreen() }
        function onSettingsButtonClicked() { screenSettings.loadScreen() }
    }

    Connections {
        target: MenubarManager
        function onScannerClicked() { screenScanner.loadScreen() }
        function onSimulatorClicked() { screenSimulator.loadScreen() }
        function onSettingsClicked() { screenSettings.loadScreen() }
        function onAboutClicked() { screenSettings.loadScreen() }
        function onExportClicked() { screenScanner.openExport() }
        function onViewClicked(screen) {
            if (screen === 0) screenScanner.loadScreen()
            else if (screen === 1) screenSimulator.loadScreen()
            else if (screen === 2) screenUbertooth.loadScreen()
            else if (screen === 3) screenRtlSdr.loadScreen()
        }
    }

    onVisibilityChanged: (visibility) => {
        //console.log("onVisibilityChanged(" + visibility + ")")

        if (visibility === Window.AutomaticVisibility ||
            visibility === Window.Minimized || visibility === Window.Maximized ||
            visibility === Window.Windowed || visibility === Window.FullScreen) {
            //
        }

        if (visibility === Window.Hidden) {
            //DeviceManager.disconnectDevices()
        }
    }

    // User generated events handling //////////////////////////////////////////

    function backAction() {
        if (appContent.state === "Scanner") {
            screenScanner.backAction()
        } else if (appContent.state === "Simulator") {
            screenSimulator.backAction()
        } else if (appContent.state === "Ubertooth") {
            screenUbertooth.backAction()
        } else if (appContent.state === "RtlSdr") {
            screenRtlSdr.backAction()
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
        onActivated: DeviceManager.scanDevices_start()
    }
    Shortcut {
        sequence: "Ctrl+F5"
        onActivated: DeviceManager.scanDevices_start()
    }
    Shortcut {
        sequence: "Ctrl+."
        onActivated: DeviceManager.scanDevices_stop()
    }
    Shortcut {
        sequences: [StandardKey.Preferences]
        onActivated: screenSettings.loadScreen()
    }
    Shortcut {
        sequences: [StandardKey.Close]
        onActivated: appWindow.close()
    }
    Shortcut {
        sequences: [StandardKey.Quit]
        onActivated: UtilsApp.appExit()
    }

    // Fonts ///////////////////////////////////////////////////////////////////

    property string fontMonospace: "Courier New" // "Monospace" // "Consolas"

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
            id: screenScanner
            anchors.fill: parent
        }
        ScreenSimulator {
            id: screenSimulator
            anchors.fill: parent
        }

        ScreenUbertooth {
            id: screenUbertooth
            anchors.fill: parent
        }
        ScreenRtlSdr {
            id: screenRtlSdr
            anchors.fill: parent
        }

        ScreenSettings {
            id: screenSettings
            anchors.fill: parent
        }

        // Initial state
        state: ""

        property var previousStates: []

        onStateChanged: {
            // backward / forward actions
            if (previousStates[previousStates.length-1] !== state) previousStates.push(state)
            if (previousStates.length > 4) previousStates.splice(0, 1)
            //console.log("states > " + appContent.previousStates)

            // Reflect the active screen as a checkmark in the macOS View menu
            if (state === "Scanner") MenubarManager.setCurrentView(0)
            else if (state === "Simulator") MenubarManager.setCurrentView(1)
            else if (state === "Ubertooth") MenubarManager.setCurrentView(2)
            else if (state === "RtlSdr") MenubarManager.setCurrentView(3)
            else MenubarManager.setCurrentView(-1)
        }

        states: [
            State {
                name: "Scanner"
                PropertyChanges { target: screenScanner; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenSimulator; visible: false; enabled: false; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenRtlSdr; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "Simulator"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenSimulator; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenRtlSdr; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "Ubertooth"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenSimulator; visible: false; enabled: false; }
                PropertyChanges { target: screenUbertooth; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenRtlSdr; visible: false; enabled: false; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "RtlSdr"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenSimulator; visible: false; enabled: false; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenRtlSdr; visible: true; enabled: true; focus: true; }
                PropertyChanges { target: screenSettings; visible: false; enabled: false; }
            },
            State {
                name: "Settings"
                PropertyChanges { target: screenScanner; visible: false; enabled: false; }
                PropertyChanges { target: screenSimulator; visible: false; enabled: false; }
                PropertyChanges { target: screenUbertooth; visible: false; enabled: false; }
                PropertyChanges { target: screenRtlSdr; visible: false; enabled: false; }
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
            appSplashLoader.active = SettingsManager.appSplashScreen
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

    BannerButton {
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginXL
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.componentMarginXL*2

        visible: disconnectTimer.running
        opacity: disconnectTimer.running ? 1 : 0

        animation: "fade"
        animationRunning: visible

        text: qsTr("Disconnecting devices... Please Wait...")
        textButton: qsTr("Exit now")

        source: "qrc:/IconLibrary/material-icons/duotone/bluetooth_connected.svg"

        onClicked: {
            UtilsApp.appExit()
        }
    }

    Timer {
       id: disconnectTimer
       running: false
       repeat: true
       interval: 100
       onTriggered: {
           if (!DeviceManager.areDevicesConnected() && !Ubertooth.running && !RtlSdr.running) {
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
        if (DeviceManager.areDevicesConnected()) {
            DeviceManager.disconnectDevices()
        }
        if (Ubertooth.running) {
            Ubertooth.stopWork()
        }
        if (RtlSdr.running) {
            RtlSdr.stopWork()
        }

        if (DeviceManager.areDevicesConnected() || Ubertooth.running || RtlSdr.running) {
            disconnectTimer.start()
            close.accepted = false
            return
        }
    }

    /////////////////////////////////////////////////////////////////////
}
