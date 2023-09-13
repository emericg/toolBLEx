pragma Singleton

import QtQuick

Item {
    enum ThemeNames {

        // toolBLEx
        THEME_DESKTOP_LIGHT = 0,
        THEME_DESKTOP_DARK = 1,

        THEME_LAST
    }
    property int currentTheme: -1

    ////////////////

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    ////////////////

    // Status bar (mobile)
    property int themeStatusbar
    property color colorStatusbar

    // Header
    property color colorHeader
    property color colorHeaderContent
    property color colorHeaderHighlight

    // Side bar (desktop)
    property color colorSidebar
    property color colorSidebarContent
    property color colorSidebarHighlight

    // Action bar
    property color colorActionbar
    property color colorActionbarContent
    property color colorActionbarHighlight

    // Tablet bar (mobile)
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
    property color colorLightGrey: "#7f7f7f"

    ////////////////

    // Palette colors
    property color colorRed: "#ff7657"
    property color colorGreen: "#8cd200"
    property color colorBlue: "#4cafe9"
    property color colorYellow: "#ffcf00"
    property color colorOrange: "#ffa635"
    property color colorGrey: "#555151"

    // Material colors
    readonly property color colorMaterialRed: "#F44336"
    readonly property color colorMaterialPink: "#E91E63"
    readonly property color colorMaterialPurple: "#9C27B0"
    readonly property color colorMaterialDeepPurple: "#673AB7"
    readonly property color colorMaterialIndigo: "#3F51B5"
    readonly property color colorMaterialBlue: "#2196F3"
    readonly property color colorMaterialLightBlue: "#03A9F4"
    readonly property color colorMaterialCyan: "#00BCD4"
    readonly property color colorMaterialTeal: "#009688"
    readonly property color colorMaterialGreen: "#4CAF50"
    readonly property color colorMaterialLightGreen: "#8BC34A"
    readonly property color colorMaterialLime: "#CDDC39"
    readonly property color colorMaterialYellow: "#FFEB3B"
    readonly property color colorMaterialAmber: "#FFC107"
    readonly property color colorMaterialOrange: "#FF9800"
    readonly property color colorMaterialDeepOrange: "#FF5722"
    readonly property color colorMaterialBrown: "#795548"
    readonly property color colorMaterialGrey: "#9E9E9E"

    ////////////////

    // Qt Quick controls & theming
    property color colorComponent
    property color colorComponentText
    property color colorComponentContent
    property color colorComponentBorder
    property color colorComponentDown
    property color colorComponentBackground

    property int componentMargin: isHdpi ? 12 : 16
    property int componentMarginL: isHdpi ? 16 : 20
    property int componentMarginXL: isHdpi ? 20 : 24

    property int componentHeight: (isDesktop && isHdpi) ? 34 : 36
    property int componentHeightL: (isDesktop && isHdpi) ? 36 : 38
    property int componentHeightXL: (isDesktop && isHdpi) ? 38 : 40

    property int componentRadius: 6
    property int componentBorderWidth: 2

    property int componentFontSize: 15

    ////////////////

    // Fonts (sizes in pixel)
    readonly property int fontSizeHeader: 26
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeContentVeryVerySmall: 10
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeContentVeryVeryBig: 22

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

            colorYellow = "#facb00"
            colorOrange = "#ffa635"
            colorRed    = "#ff7657"
            colorBlue   = "#4cafe9"
            colorGreen  = "#85c700"

            colorHeader                 = "#f1f0ef"
            colorHeaderContent          = "#444"
            colorHeaderHighlight        = "#e2e1df"

            colorSidebar                = "white"
            colorSidebarContent         = "#444"
            colorSidebarHighlight       = "#888"

            colorActionbar              = "#eaeae8"
            colorActionbarContent       = "#444"
            colorActionbarHighlight     = "#bab5b6"

            colorTabletmenu             = "#ffffff"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#cfcbcb"

            colorBackground             = "#f9f8f7"
            colorForeground             = "#f3f2f1"

            colorPrimary                = colorYellow
            colorSecondary              = "#ffe800"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#373737"
            colorSubText                = "#666666"
            colorIcon                   = "#373737"
            colorSeparator              = "#e8e8e8"
            colorLowContrast            = "white"
            colorHighContrast           = "#303030"

            colorBox                    = "white"
            colorBoxBorder              = "#f4f4f4"
            colorGrid                   = "#ebebeb"
            colorLVheader               = "#fafafa"
            colorLVpair                 = "white"
            colorLVimpair               = "#f5f5f5"
            colorLVselected             = "#0080e0"
            colorLVseparator            = "#e2e2e2"

            colorComponent              = "#eaeaea"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#ddd"
            colorComponentDown          = "#dadada"
            colorComponentBackground    = "#fcfcfc"

        } else if (themeIndex === ThemeEngine.THEME_DESKTOP_DARK) {

            colorYellow = "#fcc632"
            colorOrange = "#ff8f35"
            colorRed    = "#e8635a"
            colorBlue   = "#4dceeb"
            colorGreen  = "#58cf77"

            colorHeader                 = "#b16bee"
            colorHeaderContent          = "white"
            colorHeaderHighlight        = "#725595"

            colorSidebar                = "#b16bee"
            colorSidebarContent         = "white"
            colorSidebarHighlight       = "#725595"

            colorActionbar              = "#252024"
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#7c54ac"

            colorTabletmenu             = "#292929"
            colorTabletmenuContent      = "#808080"
            colorTabletmenuHighlight    = "#bb86fc"

            colorBackground             = "#2e2a2e"
            colorForeground             = "#333"

            colorPrimary                = "#bb86fc"
            colorSecondary              = "#b16bee"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#eee"
            colorSubText                = "#999"
            colorIcon                   = "#eee"
            colorSeparator              = "#333"
            colorLowContrast            = "#111"
            colorHighContrast           = "white"

            colorBox                    = "#252024"
            colorBoxBorder              = "#333"
            colorGrid                   = "#333"
            colorLVheader               = "#252024"
            colorLVpair                 = "#302b2e"
            colorLVimpair               = "#252024"
            colorLVseparator            = "#333"
            colorLVselected             = "#e90c76"

            colorComponent              = "#757575"
            colorComponentText          = "#eee"
            colorComponentContent       = "white"
            colorComponentBorder        = "#777"
            colorComponentDown          = "#595959"
            colorComponentBackground    = "#393939"

        }

        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
