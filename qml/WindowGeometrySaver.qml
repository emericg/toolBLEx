import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import Qt.labs.settings 1.0

Item {
    // This code should only run for desktop windowed applications.
    enabled: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")

    // The ApplicationWindow instance that will be manipulated. MUST be set by the calling application.
    property ApplicationWindow windowInstance: null

    // Name of the setting section. Can be changed by the calling application.
    property string windowName: "ApplicationWindow"

    // QSettings file. Will use organisation and project name.
    Settings {
        id: windowSettings
        category: windowName

        property int x
        property int y
        property int width
        property int height
        property int visibility // https://doc.qt.io/qt-5/qwindow.html#Visibility-enum
    }

    // Restore settings ////////////////////////////////////////////////////////

    Component.onCompleted: restoreSettings()

    function restoreSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        // Startup verifications to ensure that app fits inside current screen
        if (windowSettings.x < 0 || windowSettings.x >= Screen.desktopAvailableWidth)
            windowSettings.x = 100;
        if (windowSettings.y < 0 || windowSettings.y >= Screen.desktopAvailableHeight)
            windowSettings.y = 100;
        if (windowSettings.width > Screen.desktopAvailableWidth) {
            windowSettings.x = 100;
            windowSettings.width = Screen.desktopAvailableWidth - windowSettings.x;
        }
        if (windowSettings.height > Screen.desktopAvailableHeight) {
            windowSettings.y = 100;
            windowSettings.height = Screen.desktopAvailableHeight - windowSettings.y;
        }

        // Now apply saved settings
        if (windowSettings.width && windowSettings.height) {
            windowInstance.x = windowSettings.x;
            windowInstance.y = windowSettings.y;
            windowInstance.width = windowSettings.width;
            windowInstance.height = windowSettings.height;
            windowInstance.visibility = windowSettings.visibility;
        }
        if (windowInstance.visibility < Window.AutomaticVisibility) {
            windowInstance.visibility = Window.AutomaticVisibility;
        }
    }

    // Save settings ///////////////////////////////////////////////////////////

    Timer {
        id: saveSettingsTimer
        interval: 2000 // 2s is probably good enough...
        repeat: false // started by application geometry changes
        onTriggered: saveSettings()
    }

    Connections {
        target: windowInstance
        function onXChanged() { saveSettingsTimer.restart() }
        function onYChanged() { saveSettingsTimer.restart() }
        function onWidthChanged() { saveSettingsTimer.restart() }
        function onHeightChanged() { saveSettingsTimer.restart() }
        function onVisibilityChanged() { saveSettingsTimer.restart() }
    }

    function saveSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        switch (windowInstance.visibility) {
            case ApplicationWindow.Windowed:
                windowSettings.x = windowInstance.x;
                windowSettings.y = windowInstance.y;
                windowSettings.width = windowInstance.width;
                windowSettings.height = windowInstance.height;
                windowSettings.visibility = windowInstance.visibility;
                break;
            case ApplicationWindow.Maximized:
                windowSettings.visibility = windowInstance.visibility;
                break;
            case ApplicationWindow.FullScreen:
                windowSettings.visibility = windowInstance.visibility;
                break;
        }
    }
}
