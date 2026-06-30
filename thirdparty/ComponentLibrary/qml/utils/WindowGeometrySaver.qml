import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Controls

Item {
    id: control

    // The ApplicationWindow instance that will be manipulated. MUST be set by the calling application.
    property ApplicationWindow windowInstance: null

    // Name of the setting section. Can be changed by the calling application.
    property string windowName: "ApplicationWindow"

    // QSettings file (will use organisation and project name) /////////////////

    Settings {
        id: windowSettings
        category: control.windowName

        property int x
        property int y
        property int width
        property int height
        property int visibility // https://doc.qt.io/qt-6/qwindow.html#Visibility-enum
    }

    // Restore settings ////////////////////////////////////////////////////////

    Component.onCompleted: {
        restoreSettings()
    }

    function restoreSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        //console.log("WindowsGeometrySaver::restoreSettings()")

        // Read persisted geometry into locals, so the sanitization below never
        // writes (bad) values back to the settings file.
        var x = windowSettings.x;
        var y = windowSettings.y;
        var width = windowSettings.width;
        var height = windowSettings.height;
        var visibility = windowSettings.visibility;

        // Nothing saved yet: leave the window with its default geometry
        if (width <= 0 || height <= 0) {
            if (windowInstance.visibility < Window.AutomaticVisibility)
                windowInstance.visibility = Window.AutomaticVisibility;
            return;
        }

        // Startup verifications to ensure the window fits inside the available
        // screen area. desktopAvailable* spans the whole virtual desktop, while
        // virtualX/virtualY give the current screen's origin within it, which
        // can be non-zero or negative on multi-monitor setups.
        var minX = Screen.virtualX;
        var minY = Screen.virtualY;
        var maxX = Screen.virtualX + Screen.desktopAvailableWidth;
        var maxY = Screen.virtualY + Screen.desktopAvailableHeight;

        if (width > Screen.desktopAvailableWidth) width = Screen.desktopAvailableWidth;
        if (height > Screen.desktopAvailableHeight) height = Screen.desktopAvailableHeight;

        // Clamp the window inside the available area, keeping it as close as
        // possible to its saved position instead of jumping to a fixed corner.
        if (x < minX || x + width > maxX) x = Math.max(minX, Math.min(x, maxX - width));
        if (y < minY || y + height > maxY) y = Math.max(minY, Math.min(y, maxY - height));

        // Now apply the (sanitized) saved settings
        windowInstance.x = x;
        windowInstance.y = y;
        windowInstance.width = width;
        windowInstance.height = height;
        windowInstance.visibility = visibility;

        if (windowInstance.visibility < Window.AutomaticVisibility) {
            windowInstance.visibility = Window.AutomaticVisibility;
        }
    }

    // Save settings ///////////////////////////////////////////////////////////

    Connections {
        target: control.windowInstance
        function onXChanged() { saveSettingsTimer.restart(); }
        function onYChanged() { saveSettingsTimer.restart(); }
        function onWidthChanged() { saveSettingsTimer.restart(); }
        function onHeightChanged() { saveSettingsTimer.restart(); }
        function onVisibilityChanged() { saveSettingsTimer.restart(); }
        function onClosing() { control.saveSettings(); }
    }

    Timer {
        id: saveSettingsTimer
        interval: 2000 // 2s is probably good enough...
        repeat: false // started when ApplicationWindow geometry changes
        onTriggered: control.saveSettings()
    }

    function saveSettings() {
        if (Qt.platform.os === "android" || Qt.platform.os === "ios") return;

        //console.log("WindowsGeometrySaver::saveSettings()")

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
