pragma Singleton

import QtQuick
import QtQuick.Controls.Material

Item {
    enum ThemeNames {

        // toolBLEx
        THEME_DESKTOP_LIGHT = 0,
        THEME_DESKTOP_DARK = 1,

        THEME_LAST
    }
    property int currentTheme: -1

    ////////////////

    property int themeStatusbar
    property color colorStatusbar

    // Header
    property color colorHeader
    property color colorHeaderContent
    property color colorHeaderHighlight

    // Sidebar
    property color colorSidebar
    property color colorSidebarContent
    property color colorSidebarHighlight

    // Action bar
    property color colorActionbar
    property color colorActionbarContent
    property color colorActionbarHighlight

    // Tablet bar
    property color colorTabletmenu
    property color colorTabletmenuContent
    property color colorTabletmenuHighlight

    // Content
    property color colorBackground
    property color colorForeground

    property color colorPrimary
    property color colorSecondary
    property color colorSuccess
    property color colorWarning
    property color colorError

    property color colorText
    property color colorSubText
    property color colorIcon
    property color colorSeparator

    property color colorLowContrast
    property color colorHighContrast

    // App specific
    property color colorBox
    property color colorBoxBorder
    property color colorGrid
    property color colorLVheader
    property color colorLVpair
    property color colorLVimpair
    property color colorLVselected
    property color colorLVseparator

    // Qt Quick controls & theming
    property color colorComponent
    property color colorComponentText
    property color colorComponentContent
    property color colorComponentBorder
    property color colorComponentDown
    property color colorComponentBackground

    property int componentHeight: 40
    property int componentRadius: 4
    property int componentBorderWidth: 1

    ////////////////

    // Palette colors
    property color colorLightGreen: "#09debc"
    property color colorGreen
    property color colorDarkGreen: "#1ea892"
    property color colorBlue
    property color colorYellow
    property color colorOrange
    property color colorRed
    property color colorGrey: "#5c5c5c"
    property color colorLightGrey: "#7f7f7f"

    // Fixed colors
    readonly property color colorMaterialBlue: "#2196f3"
    readonly property color colorMaterialThisblue: "#448aff"
    readonly property color colorMaterialIndigo: "#3f51b5"
    readonly property color colorMaterialPurple: "#9c27b0"
    readonly property color colorMaterialDeepPurple: "#673ab7"
    readonly property color colorMaterialRed: "#f44336"
    readonly property color colorMaterialOrange: "#ff9800"
    readonly property color colorMaterialLightGreen: "#8bc34a"

    readonly property color colorMaterialLightGrey: "#f8f8f8"
    readonly property color colorMaterialGrey: "#eeeeee"
    readonly property color colorMaterialDarkGrey: "#ececec"
    readonly property color colorNeutralDay: "#e4e4e4"
    readonly property color colorNeutralNight: "#ffb300"

    ////////////////

    // Fonts (sizes in pixel) (WIP)
    readonly property int fontSizeHeader: (Qt.platform.os === "ios" || Qt.platform.os === "android") ? 22 : 26
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeContentVeryVerySmall: 10
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeContentVeryVeryBig: 22
    readonly property int fontSizeComponent: (Qt.platform.os === "ios" || Qt.platform.os === "android") ? 14 : 15

    ////////////////////////////////////////////////////////////////////////////

    function getThemeIndex(name) {
        if (name === "THEME_DESKTOP_LIGHT") return ThemeEngine.THEME_DESKTOP_LIGHT
        if (name === "THEME_DESKTOP_DARK") return ThemeEngine.THEME_DESKTOP_DARK

        return -1
    }
    function getThemeName(index) {
        if (index === ThemeEngine.THEME_DESKTOP_LIGHT) return "THEME_DESKTOP_LIGHT"
        if (index === ThemeEngine.THEME_DESKTOP_DARK) return "THEME_DESKTOP_DARK"

        return ""
    }

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(settingsManager.appTheme)
    Connections {
        target: settingsManager
        function onAppThemeChanged() { loadTheme(settingsManager.appTheme) }
    }

    function loadTheme(newIndex) {
        //console.log("ThemeEngine.loadTheme(" + newIndex + ")")
        var themeIndex = -1

        // Get the theme index
        if ((typeof newIndex === 'string' || newIndex instanceof String)) {
            themeIndex = getThemeIndex(newIndex)
        } else {
            themeIndex = newIndex
        }

        // Validate the result
        if (themeIndex < 0 || themeIndex >= ThemeEngine.THEME_LAST) {
            themeIndex = ThemeEngine.THEME_DESKTOP_LIGHT // default theme
        }

        // Handle day/night themes
        if (settingsManager.appThemeAuto) {
            var rightnow = new Date()
            var hour = Qt.formatDateTime(rightnow, "hh")
            if (hour >= 21 || hour <= 8) {
                themeIndex = ThemeEngine.THEME_DESKTOP_DARK
            }
        }

        // Do not reload the same theme
        if (themeIndex === currentTheme) return

        if (themeIndex === ThemeEngine.THEME_DESKTOP_LIGHT) {

            colorGreen = "#85c700"
            colorBlue = "#4cafe9"
            colorYellow = "#facb00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            themeStatusbar = Material.Light
            colorStatusbar = "white"

            colorHeader = "#f1f0ef"
            colorHeaderContent = "#444"
            colorHeaderHighlight = "#e2e1df"

            colorSidebar = "white"
            colorSidebarContent = "#444"
            colorSidebarHighlight = colorMaterialDarkGrey

            colorActionbar = "#eaeae8"
            colorActionbarContent = "#444"
            colorActionbarHighlight = "#bab5b6"

            colorTabletmenu = "#ffffff"
            colorTabletmenuContent = "#9d9d9d"
            colorTabletmenuHighlight = "#cfcbcb"

            colorBackground = "#f9f8f7"
            colorForeground = "#f3f2f1"

            colorPrimary = colorYellow
            colorSecondary = "#ffe800"
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#373737"
            colorSubText = "#666666"
            colorIcon = "#373737"
            colorSeparator = "#e8e8e8"
            colorLowContrast = "white"
            colorHighContrast = "#303030"

            colorBox = "white"
            colorBoxBorder = "#f4f4f4"
            colorGrid = "#ebebeb"
            colorLVheader = "#fafafa"
            colorLVpair = "white"
            colorLVimpair = "#f5f5f5"
            colorLVselected = "#0080e0"
            colorLVseparator = "#e2e2e2"

            componentHeight = 32
            componentRadius = 8
            componentBorderWidth = 2

            colorComponent = "#eaeaea"
            colorComponentText = "black"
            colorComponentContent = "black"
            colorComponentBorder = "#ddd"
            colorComponentDown = "#dadada"
            colorComponentBackground = "#fcfcfc"

        } else if (themeIndex === ThemeEngine.THEME_DESKTOP_DARK) {

            colorGreen = "#58cf77"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorOrange = "#ff8f35"
            colorRed = "#e8635a"

            themeStatusbar = Material.Dark
            colorStatusbar = "#725595"

            colorHeader = "#b16bee"
            colorHeaderContent = "white"
            colorHeaderHighlight = "#725595"

            colorSidebar = "#b16bee"
            colorSidebarContent = "white"
            colorSidebarHighlight = "#725595"

            colorActionbar = "#252024"
            colorActionbarContent = "white"
            colorActionbarHighlight = "#b16bee" // "#725595"

            colorTabletmenu = "#292929"
            colorTabletmenuContent = "#808080"
            colorTabletmenuHighlight = "#bb86fc"

            colorBackground = "#2e2a2e"
            colorForeground = "#353030"

            colorPrimary = "#bb86fc"
            colorSecondary = "#b16bee"
            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorText = "#eee"
            colorSubText = "#999"
            colorIcon = "#eee"
            colorSeparator = "#333"
            colorLowContrast = "#111"
            colorHighContrast = "white"

            colorBox = "#252024"
            colorBoxBorder = "#333"
            colorGrid = "#333"
            colorLVheader = "#252024"
            colorLVpair = "#302b2e"
            colorLVimpair = "#252024"
            colorLVseparator = "#333"
            colorLVselected = "#e90c76"

            componentHeight = 32
            componentRadius = 8
            componentBorderWidth = 2

            colorComponent = "#757575"
            colorComponentText = "#eee"
            colorComponentContent = "white"
            colorComponentBorder = "#777"
            colorComponentDown = "#595959"
            colorComponentBackground = "#393939"

        }

        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
