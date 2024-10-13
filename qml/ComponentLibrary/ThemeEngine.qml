pragma Singleton

import QtQuick
import QtQuick.Controls.Material

Item {
    enum ThemeNames {
        // Generic mobile themes
        THEME_MOBILE_LIGHT,
        THEME_MOBILE_DARK,

        // Generic mobile material themes
        THEME_MATERIAL_LIGHT,
        THEME_MATERIAL_DARK,

        // Generic desktop themes
        THEME_DESKTOP_LIGHT,
        THEME_DESKTOP_DARK,

        // WatchFlower
        THEME_SNOW,
        THEME_PLANT,
        THEME_RAIN,
        THEME_DAY,
        THEME_NIGHT,

        // OffloadBuddy
        THEME_LIGHT_AND_WARM,
        THEME_DARK_AND_SPOOKY,
        THEME_PLAIN_AND_BORING,
        THEME_BLOOD_AND_TEARS,
        THEME_MIGHTY_KITTENS,

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

    property bool isLight
    property bool isDark

    // Status bar (mobile)
    property int themeStatusbar
    property color colorStatusbar

    // Header
    property color colorHeader
    property color colorHeaderContent
    property color colorHeaderHighlight

    // Action bar (mobile)
    property color colorActionbar
    property color colorActionbarContent
    property color colorActionbarHighlight

    // Side bar (desktop)
    property color colorSidebar
    property color colorSidebarContent
    property color colorSidebarHighlight

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

    ////////////////

    // App specific (toolBLEx)
    property color colorBox: "white"
    property color colorBoxBorder: "#f4f4f4"
    property color colorBoxShadow: "#20000000"
    property color colorGrid: "#ebebeb"
    property color colorLVheader: "#fafafa"
    property color colorLVpair: "white"
    property color colorLVimpair: "#f5f5f5"
    property color colorLVselected: "#0080e0"
    property color colorLVseparator: "#e2e2e2"

    // App specific (OffloadBuddy)
    property string sidebarSelector // 'arrow' or 'bar'

    // App specific (WatchFlower)
    property color colorDeviceWidget
    readonly property color colorLightGrey: "#a9bcb8"
    readonly property color colorLightGreen: "#09debc"
    readonly property color colorNeutralNight: "#ffb300"
    readonly property color colorMaterialLightGrey: "#f8f8f8"
    readonly property color colorMaterialDarkGrey: "#ececec"

    ////////////////

    // Palette colors
    property color colorRed: "#ff7657"
    property color colorGreen: "#8cd200"
    property color colorBlue: "#4cafe9"
    property color colorYellow: "#ffcf00"
    property color colorOrange: "#ffa635"
    property color colorGrey: "#666"

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

    // Qt Quick Controls & theming
    property color colorComponent
    property color colorComponentText
    property color colorComponentContent
    property color colorComponentBorder
    property color colorComponentDown
    property color colorComponentBackground
    property color colorComponentShadow: isLight ? "#33000000" : "#aaffffff"

    property int componentRadius: 4
    property int componentBorderWidth: 2

    property int componentFontSize: isHdpi ? 14 : 15

    property int componentMarginXS: isHdpi ? 4 : 8
    property int componentMarginS: isHdpi ? 8 : 12
    property int componentMargin: isHdpi ? 12 : 16
    property int componentMarginL: isHdpi ? 16 : 20
    property int componentMarginXL: isHdpi ? 20 : 24

    property int componentHeight: {
        if (isDesktop && isHdpi) return 34
        if (isDesktop) return 38
        return 40
    }
    property int componentHeightL: {
        if (isDesktop && isHdpi) return 42
        if (isDesktop) return 46
        return 48
    }
    property int componentHeightXL: {
        if (isDesktop && isHdpi) return 50
        if (isDesktop) return 54
        return 56
    }

    ////////////////

    // Fonts (sizes in pixel)
    readonly property int fontSizeHeader: isMobile ? 22 : 26
    readonly property int fontSizeTitle: isMobile ? 24 : 28
    readonly property int fontSizeContentVeryVerySmall: 10
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeContentVeryVeryBig: 22

    // Fonts
    property font headerFont: Qt.font({
        family: 'Encode Sans',
        weight: Font.Black,
        italic: false,
        pixelSize: fontSizeHeader
    })

    ////////////////////////////////////////////////////////////////////////////

    function getThemeIndex(name) {
        if (name === "THEME_MOBILE_LIGHT") return ThemeEngine.THEME_MOBILE_LIGHT
        if (name === "THEME_MOBILE_DARK") return ThemeEngine.THEME_MOBILE_DARK

        if (name === "THEME_MATERIAL_LIGHT") return ThemeEngine.THEME_MATERIAL_LIGHT
        if (name === "THEME_MATERIAL_DARK") return ThemeEngine.THEME_MATERIAL_DARK

        if (name === "THEME_DESKTOP_LIGHT") return ThemeEngine.THEME_DESKTOP_LIGHT
        if (name === "THEME_DESKTOP_DARK") return ThemeEngine.THEME_DESKTOP_DARK

        if (name === "THEME_SNOW") return ThemeEngine.THEME_SNOW
        if (name === "THEME_PLANT") return ThemeEngine.THEME_PLANT
        if (name === "THEME_RAIN") return ThemeEngine.THEME_RAIN
        if (name === "THEME_DAY") return ThemeEngine.THEME_DAY
        if (name === "THEME_NIGHT") return ThemeEngine.THEME_NIGHT

        if (name === "THEME_LIGHT_AND_WARM") return ThemeEngine.THEME_LIGHT_AND_WARM
        if (name === "THEME_DARK_AND_SPOOKY") return ThemeEngine.THEME_DARK_AND_SPOOKY
        if (name === "THEME_PLAIN_AND_BORING") return ThemeEngine.THEME_PLAIN_AND_BORING
        if (name === "THEME_BLOOD_AND_TEARS") return ThemeEngine.THEME_BLOOD_AND_TEARS
        if (name === "THEME_MIGHTY_KITTENS") return ThemeEngine.THEME_MIGHTY_KITTENS

        return -1
    }

    function getThemeName(index) {
        if (index === ThemeEngine.THEME_MOBILE_LIGHT) return "THEME_MOBILE_LIGHT"
        if (index === ThemeEngine.THEME_MOBILE_DARK) return "THEME_MOBILE_DARK"

        if (index === ThemeEngine.THEME_MATERIAL_LIGHT) return "THEME_MATERIAL_LIGHT"
        if (index === ThemeEngine.THEME_MATERIAL_DARK) return "THEME_MATERIAL_DARK"

        if (index === ThemeEngine.THEME_DESKTOP_LIGHT) return "THEME_DESKTOP_LIGHT"
        if (index === ThemeEngine.THEME_DESKTOP_DARK) return "THEME_DESKTOP_DARK"

        if (index === ThemeEngine.THEME_SNOW) return "THEME_SNOW"
        if (index === ThemeEngine.THEME_PLANT) return "THEME_PLANT"
        if (index === ThemeEngine.THEME_RAIN) return "THEME_RAIN"
        if (index === ThemeEngine.THEME_DAY) return "THEME_DAY"
        if (index === ThemeEngine.THEME_NIGHT) return "THEME_NIGHT"

        if (index === ThemeEngine.THEME_LIGHT_AND_WARM) return "THEME_LIGHT_AND_WARM"
        if (index === ThemeEngine.THEME_DARK_AND_SPOOKY) return "THEME_DARK_AND_SPOOKY"
        if (index === ThemeEngine.THEME_PLAIN_AND_BORING) return "THEME_PLAIN_AND_BORING"
        if (index === ThemeEngine.THEME_BLOOD_AND_TEARS) return "THEME_BLOOD_AND_TEARS"
        if (index === ThemeEngine.THEME_MIGHTY_KITTENS) return "THEME_MIGHTY_KITTENS"

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

        // Validate the result (or set the default)
        if (themeIndex < 0 || themeIndex >= ThemeEngine.THEME_LAST) {
            if (isDesktop) themeIndex = ThemeEngine.THEME_LIGHT_AND_WARM
            else if (isMobile) themeIndex = ThemeEngine.THEME_MOBILE_LIGHT
            else themeIndex = 1
        }

        // Handle day/night themes
        if (settingsManager.appThemeAuto) {
            var rightnow = new Date()
            var hour = Qt.formatDateTime(rightnow, "hh")
            if (hour >= 21 || hour <= 8) {
                if (themeIndex === ThemeEngine.THEME_MOBILE_LIGHT)
                    themeIndex = ThemeEngine.THEME_MOBILE_DARK

                if (themeIndex === ThemeEngine.THEME_MATERIAL_LIGHT)
                    themeIndex = ThemeEngine.THEME_MATERIAL_DARK

                if (themeIndex === ThemeEngine.THEME_DESKTOP_LIGHT)
                    themeIndex = ThemeEngine.THEME_DESKTOP_DARK

                if (themeIndex === ThemeEngine.THEME_SNOW ||
                    themeIndex === ThemeEngine.THEME_PLANT ||
                    themeIndex === ThemeEngine.THEME_RAIN ||
                    themeIndex === ThemeEngine.THEME_DAY)
                    themeIndex = ThemeEngine.THEME_NIGHT

                if (themeIndex === ThemeEngine.THEME_LIGHT_AND_WARM ||
                    themeIndex === ThemeEngine.THEME_PLAIN_AND_BORING)
                    themeIndex = ThemeEngine.THEME_DARK_AND_SPOOKY

                // theme doesn't have a dark variant set? just don't change the theme...
            }
        }

        // Do not reload the same theme
        if (themeIndex === currentTheme) return

        // Set the theme
        if (themeIndex === ThemeEngine.THEME_MOBILE_LIGHT) { ///////////////////

            colorGreen  = "#07bf97"
            colorBlue   = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorOrange = "#ff863a"
            colorRed    = "#ff523a"

            isLight = true
            isDark = false

            themeStatusbar = Material.Light
            colorStatusbar = "#eeeeee"

            colorHeader                 = "#eeeeee"
            colorHeaderContent          = "#ff7b36"
            colorHeaderHighlight        = "white"

            colorActionbar              = colorGreen
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#00a27d"

            colorSidebar                = "#eee"
            colorSidebarContent         = "#777"
            colorSidebarHighlight       = "#ddd"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = colorMaterialDeepOrange // "#ff7b36"

            colorBackground             = colorMaterialLightGrey
            colorForeground             = "#f0f0f0"

            colorPrimary                = colorMaterialDeepOrange // colorRed
            colorSecondary              = colorMaterialOrange // "#ff7b36"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#303030"
            colorSubText                = "#666666"
            colorIcon                   = "#303030"
            colorSeparator              = "#ececec"
            colorLowContrast            = "white"
            colorHighContrast           = "black"

            colorComponent              = "#f0f0f0"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#e0e0e0"
            colorComponentDown          = "#e9e9e9"
            colorComponentBackground    = "white"

            componentRadius = 6
            componentBorderWidth = 2

        } else if (themeIndex === ThemeEngine.THEME_MOBILE_DARK) {

            colorGreen  = "#58CF77"
            colorBlue   = "#4dceeb"
            colorYellow = "#fcc632"
            colorOrange = "#ff7657"
            colorRed    = "#e8635a"

            isLight = false
            isDark = true

            themeStatusbar = Material.Dark
            colorStatusbar = "#292929"

            colorHeader                 = "#292929"
            colorHeaderContent          = "#ee8c21"
            colorHeaderHighlight        = "#444"

            colorActionbar              = colorGreen
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#00a27d"

            colorSidebar                = "#333"
            colorSidebarContent         = "#ccc"
            colorSidebarHighlight       = "#555"

            colorTabletmenu             = "#292929"
            colorTabletmenuContent      = "#808080"
            colorTabletmenuHighlight    = "#ff9f1a"

            colorBackground             = "#313236"
            colorForeground             = "#292929"

            colorPrimary                = "#ff9f1a"
            colorSecondary              = "#ffb81a"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "white"
            colorSubText                = "#aaa"
            colorIcon                   = "#ddd"
            colorSeparator              = "#404040"
            colorLowContrast            = "black"
            colorHighContrast           = "white"

            colorComponent              = "#666"
            colorComponentText          = "#eee"
            colorComponentContent       = "white"
            colorComponentBorder        = "#666"
            colorComponentDown          = "#444"
            colorComponentBackground    = "#505050"

            componentRadius = 6
            componentBorderWidth = 2

        } else if (themeIndex === ThemeEngine.THEME_MATERIAL_LIGHT) { /////////

            colorGreen  = "#07bf97"
            colorBlue   = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorOrange = "#ff863a"
            colorRed    = "#ff523a"

            isLight = true
            isDark = false

            themeStatusbar = Material.Light
            colorStatusbar = "white"

            colorHeader                 = "white"
            colorHeaderContent          = "#1a73e8"
            colorHeaderHighlight        = "white"

            colorActionbar              = colorGreen
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#00a27d"

            colorSidebar                = "#eee"
            colorSidebarContent         = "#777"
            colorSidebarHighlight       = "#ddd"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#888"
            colorTabletmenuHighlight    = colorMaterialDeepOrange

            colorBackground             = "white"
            colorForeground             = "#f9f9f9"

            colorPrimary                = "#1a73e8"
            colorSecondary              = "#ff7b36"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#303030"
            colorSubText                = "#666"
            colorIcon                   = "#303030"
            colorSeparator              = "#ececec"
            colorLowContrast            = "white"
            colorHighContrast           = "black"

            colorComponent              = "#f6f6f6"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#f2f2f2"
            colorComponentDown          = "#eee"
            colorComponentBackground    = "white"

            componentRadius = 6
            componentBorderWidth = 2

        } else if (themeIndex === ThemeEngine.THEME_MATERIAL_DARK) {

            colorGreen  = "#58CF77"
            colorBlue   = "#4dceeb"
            colorYellow = "#fcc632"
            colorOrange = "#ff7657"
            colorRed    = "#e8635a"

            isLight = false
            isDark = true

            themeStatusbar = Material.Dark
            colorStatusbar = "#313236"

            colorHeader                 = "#313236"
            colorHeaderContent          = "#ee8c21"
            colorHeaderHighlight        = "#444"

            colorActionbar              = colorGreen
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#00a27d"

            colorSidebar                = "#333"
            colorSidebarContent         = "#ccc"
            colorSidebarHighlight       = "#555"

            colorTabletmenu             = "#292929"
            colorTabletmenuContent      = "#808080"
            colorTabletmenuHighlight    = "#ff9f1a"

            colorBackground             = "#313236"
            colorForeground             = "#292929"

            colorPrimary                = "#ff9f1a"
            colorSecondary              = "#ffb81a"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "white"
            colorSubText                = "#aaa"
            colorIcon                   = "#ccc"
            colorSeparator              = "#404040"
            colorLowContrast            = "black"
            colorHighContrast           = "white"

            colorComponent              = "#666"
            colorComponentText          = "#ddd"
            colorComponentContent       = "white"
            colorComponentBorder        = "#666"
            colorComponentDown          = "#444"
            colorComponentBackground    = "#505050"

            componentRadius = 8
            componentBorderWidth = 2

        } else if (themeIndex === ThemeEngine.THEME_DESKTOP_LIGHT) { ///////////

            colorRed    = "#ff7657"
            colorGreen  = "#85c700"
            colorBlue   = "#4cafe9"
            colorYellow = "#ffcf00"
            colorOrange = "#ffa635"
            colorGrey   = "#9E9E9E"

            isLight = true
            isDark = false

            themeStatusbar = Material.Light
            colorStatusbar = "#f1f0ef"

            colorHeader                 = "#f1f0ef"
            colorHeaderContent          = "#444"
            colorHeaderHighlight        = "#e2e1df"

            colorSidebar                = "white"
            colorSidebarContent         = "#444"
            colorSidebarHighlight       = "#888"

            colorActionbar              = "#eaeaea"
            colorActionbarContent       = "#444"
            colorActionbarHighlight     = "#dadada"

            colorTabletmenu             = "#ffffff"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#cfcbcb"

            colorBackground             = "#f9f8f7"
            colorForeground             = "#f3f2f1"

            colorPrimary                = "#ffc900"
            colorSecondary              = "#ffeb00"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#373737"
            colorSubText                = "#666666"
            colorIcon                   = "#373737"
            colorSeparator              = "#e8e8e8"
            colorLowContrast            = "white"
            colorHighContrast           = "#303030"

            colorComponent              = "#eaeaea"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#ddd"
            colorComponentDown          = "#dadada"
            colorComponentBackground    = "#fcfcfc"

            componentRadius = 6
            componentBorderWidth = 2

            // (app)
            colorBox                    = "white"
            colorBoxBorder              = "#f4f4f4"
            colorBoxShadow              = "#20000000"
            colorGrid                   = "#ebebeb"
            colorLVheader               = "#fafafa"
            colorLVpair                 = "white"
            colorLVimpair               = "#f5f5f5"
            colorLVselected             = "#0080e0"
            colorLVseparator            = "#e2e2e2"

        } else if (themeIndex === ThemeEngine.THEME_DESKTOP_DARK) {

            colorRed    = "#e8635a"
            colorGreen  = "#58cf77"
            colorBlue   = "#4dceeb"
            colorYellow = "#ffcf00"
            colorOrange = "#ff8f35"
            colorGrey   = "#5e5e5e"

            isLight = false
            isDark = true

            themeStatusbar              = Material.Dark
            colorStatusbar              = "#b16bee"

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
            colorSeparator              = "#444"
            colorLowContrast            = "#111"
            colorHighContrast           = "white"

            colorComponent              = "#757575"
            colorComponentText          = "#eee"
            colorComponentContent       = "white"
            colorComponentBorder        = "#777"
            colorComponentDown          = "#595959"
            colorComponentBackground    = "#393939"

            componentRadius = 6
            componentBorderWidth = 2

            // (app)
            colorBox                    = "#252024"
            colorBoxBorder              = "#333"
            colorBoxShadow              = "#aa000000"
            colorGrid                   = "#333"
            colorLVheader               = "#252024"
            colorLVpair                 = "#302b2e"
            colorLVimpair               = "#252024"
            colorLVseparator            = "#333"
            colorLVselected             = "#e90c76"

        } else if (themeIndex === ThemeEngine.THEME_SNOW) { ////////////////////

            colorGreen = "#85c700"
            colorBlue = "#4cafe9"
            colorYellow = "#facb00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            isLight = true
            isDark = false

            themeStatusbar = Material.Light
            colorStatusbar = "white"

            colorHeader                 = "white"
            colorHeaderContent          = "#444"
            colorHeaderHighlight        = colorMaterialDarkGrey

            colorSidebar                = "white"
            colorSidebarContent         = "#444"
            colorSidebarHighlight       = colorMaterialDarkGrey

            colorActionbar              = colorGreen
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#7ab800"

            colorTabletmenu             = "#ffffff"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#0079fe"

            colorBackground             = "white"
            colorForeground             = "#fbfbfb"

            colorPrimary                = colorYellow
            colorSecondary              = "#ffe800"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#474747"
            colorSubText                = "#666666"
            colorIcon                   = "#474747"
            colorSeparator              = colorMaterialDarkGrey
            colorLowContrast            = "white"
            colorHighContrast           = "#303030"

            colorComponent              = "#EFEFEF"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#EAEAEA"
            colorComponentDown          = "#DADADA"
            colorComponentBackground    = "#FAFAFA"

            componentRadius = (componentHeight / 2)
            componentBorderWidth = 2

            // (app)
            colorDeviceWidget = "#fdfdfd"

        } else if (themeIndex === ThemeEngine.THEME_PLANT) {

            colorGreen = "#07bf97"
            colorBlue = "#4CA1D5"
            colorYellow = "#ffba5a"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            isLight = true
            isDark = false

            themeStatusbar = Material.Dark
            colorStatusbar = "#009688"

            colorHeader                 = colorGreen
            colorHeaderContent          = "white"
            colorHeaderHighlight        = "#009688"

            colorSidebar                = colorGreen
            colorSidebarContent         = "white"
            colorSidebarHighlighttent       = "#009688"

            colorActionbar              = "#00b5c4"
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#069fac"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#0079fe"

            colorBackground             = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? "white" : colorMaterialLightGrey
            colorForeground             = (Qt.platform.os === "android" || Qt.platform.os === "ios") ? colorMaterialLightGrey : "#eeeeee"

            colorPrimary                = colorGreen
            colorSecondary              = colorLightGreen
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#333333"
            colorSubText                = "#666666"
            colorIcon                   = "#333333"
            colorSeparator              = "#e8e8e8"
            colorLowContrast            = "white"
            colorHighContrast           = "black"

            colorComponent              = "#EAEAEA"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#E3E3E3"
            colorComponentDown          = "#D0D0D0"
            colorComponentBackground    = "#F1F1F1"

            componentRadius = 4
            componentBorderWidth = 2

            // (app)
            colorDeviceWidget = "#fdfdfd"

        } else if (themeIndex === ThemeEngine.THEME_RAIN) {

            colorGreen = "#8cd200"
            colorBlue = "#4cafe9"
            colorYellow = "#ffcf00"
            colorOrange = "#ffa635"
            colorRed = "#ff7657"

            isLight = true
            isDark = false

            themeStatusbar = Material.Dark
            colorStatusbar = "#1e3c77"

            colorHeader                 = "#325da9"
            colorHeaderHighlight        = "#0f295c"
            colorHeaderContent          = "white"

            colorSidebar                = "#ffcf00"
            colorSidebarContent         = "white"
            colorSidebarHighlight       = colorNeutralNight

            colorActionbar              = colorBlue
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#4c8ee9"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#0079fe"

            colorBackground             = "white"
            colorForeground             = colorMaterialLightGrey

            colorPrimary                = "#325da9"
            colorSecondary              = "#446eb7"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#474747"
            colorSubText                = "#666666"
            colorIcon                   = "#474747"
            colorSeparator              = colorMaterialDarkGrey
            colorLowContrast            = "white"
            colorHighContrast           = "#303030"

            colorComponent              = "#EFEFEF"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#E8E8E8"
            colorComponentDown          = "#DDDDDD"
            colorComponentBackground    = "#FAFAFA"

            componentRadius = 6
            componentBorderWidth = 2

            // (app)
            colorDeviceWidget = "#fdfdfd"

        } else if (themeIndex === ThemeEngine.THEME_DAY) {

            colorGreen  = "#8cd200"
            colorBlue   = "#4cafe9"
            colorYellow = "#ffcf00"
            colorOrange = "#ffa635"
            colorRed    = "#ff7657"

            isLight = true
            isDark = false

            themeStatusbar = Material.Dark
            colorStatusbar = colorNeutralNight

            colorHeader                 = "#ffcf00"
            colorHeaderContent          = "white"
            colorHeaderHighlight        = colorNeutralNight

            colorSidebar                = "#ffcf00"
            colorSidebarContent         = "white"
            colorSidebarHighlight       = colorNeutralNight

            colorActionbar              = colorGreen
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#7ab800"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#0079fe"

            colorBackground             = "white"
            colorForeground             = colorMaterialLightGrey

            colorPrimary                = colorYellow
            colorSecondary              = "#ffe800"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#474747"
            colorSubText                = "#666666"
            colorIcon                   = "#474747"
            colorSeparator              = colorMaterialDarkGrey
            colorLowContrast            = "white"
            colorHighContrast           = "#303030"

            colorComponent              = "#EFEFEF"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#E8E8E8"
            colorComponentDown          = "#DDDDDD"
            colorComponentBackground    = "#FAFAFA"

            componentRadius = 6
            componentBorderWidth = 2

            // (app)
            colorDeviceWidget = "#fdfdfd"

        } else if (themeIndex === ThemeEngine.THEME_NIGHT) {

            colorGreen = "#58CF77"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorOrange = "#ff8f35"
            colorRed = "#e8635a"

            isLight = false
            isDark = true

            themeStatusbar = Material.Dark
            colorStatusbar = "#725595"

            colorHeader                 = "#b16bee"
            colorHeaderContent          = "white"
            colorHeaderHighlight        = "#725595"

            colorSidebar                = "#b16bee"
            colorSidebarContent         = "white"
            colorSidebarHighlight       = "#725595"

            colorActionbar              = colorBlue
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#4dabeb"

            colorTabletmenu             = "#292929"
            colorTabletmenuContent      = "#808080"
            colorTabletmenuHighlight    = "#bb86fc"

            colorBackground             = "#313236"
            colorForeground             = "#292929"

            colorPrimary                = "#bb86fc"
            colorSecondary              = "#b16bee"
            colorSuccess                = colorGreen
            colorWarning                = colorOrange
            colorError                  = colorRed

            colorText                   = "#EEE"
            colorSubText                = "#AAA"
            colorIcon                   = "#EEE"
            colorSeparator              = "#404040"
            colorLowContrast            = "#111"
            colorHighContrast           = "white"

            colorComponent              = "#757575"
            colorComponentText          = "#eee"
            colorComponentContent       = "white"
            colorComponentBorder        = "#777"
            colorComponentDown          = "#595959"
            colorComponentBackground    = "#292929"

            componentRadius = 4
            componentBorderWidth = 2

            // (app)
            colorDeviceWidget = "#333"

        } else if (themeIndex === ThemeEngine.THEME_LIGHT_AND_WARM) { //////////

            isLight = true
            isDark = false

            themeStatusbar = Material.Dark
            colorStatusbar = "#BBB"

            colorHeader                 = "#e4e5e6"
            colorHeaderContent          = "#353637"
            colorHeaderHighlight        = Qt.darker(colorHeader, 1.08)

            colorSidebar                = "#555"
            colorSidebarContent         = "white"
            colorSidebarHighlight       =  Qt.lighter(colorSidebar, 1.33)

            colorActionbar              = "#e9e9e9"
            colorActionbarContent       = "#333"
            colorActionbarHighlight     = "#dadada"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#0079fe"

            colorBackground             = "#F4F4F4"
            colorForeground             = "#E9E9E9"

            colorPrimary                = "#FFCA28"
            colorSecondary              = "#FFDD28"
            colorSuccess                = "#8CD200"
            colorWarning                = "#FFAC00"
            colorError                  = "#E64B39"

            colorText                   = "#222"
            colorSubText                = "#555"
            colorIcon                   = "#333"
            colorSeparator              = "#E4E4E4"
            colorLowContrast            = "white"
            colorHighContrast           = "black"

            colorComponent              = "#EAEAEA"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#DDD"
            colorComponentDown          = "#E6E6E6"
            colorComponentBackground    = "#FAFAFA"

            componentRadius = 6
            componentBorderWidth = 2

            // (app)
            sidebarSelector = ""

        } else if (themeIndex === ThemeEngine.THEME_DARK_AND_SPOOKY) {

            isLight = false
            isDark = true

            themeStatusbar = Material.Dark
            colorStatusbar = "black"

            colorHeader                 = "#282828"
            colorHeaderContent          = "#C0C0C0"
            colorHeaderHighlight        = Qt.lighter(colorHeader, 1.4)

            colorSidebar                = "#2E2E2E"
            colorSidebarContent         = "white"
            colorSidebarHighlight       = Qt.lighter(colorSidebar, 1.5)

            colorActionbar              = "#ff894a"
            colorActionbarContent       = "white"
            colorActionbarHighlight     = Qt.darker(colorActionbar, 1.3)

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#FF9F1A"

            colorBackground             = "#3F3F3F"
            colorForeground             = "#555555"

            colorPrimary                = "#FF9F1A" // indigo: "#6C5ECD"
            colorSecondary              = "#FFB81A" // indigo2: "#9388E5"
            colorSuccess                = colorMaterialLightGreen
            colorWarning                = "#FE8F2D"
            colorError                  = "#D33E39"

            colorText                   = "white"
            colorSubText                = "#999"
            colorIcon                   = "white"
            colorSeparator              = "#666" // darker: "#333" // lighter: "#666"
            colorLowContrast            = "black"
            colorHighContrast           = "white"

            colorComponent              = "#666"
            colorComponentText          = "white"
            colorComponentContent       = "white"
            colorComponentBorder        = "#6C6C6C"
            colorComponentDown          = "#7C7C7C"
            colorComponentBackground    = "#333"

            componentRadius = 3
            componentBorderWidth = 2

            // (app)
            sidebarSelector = ""

        } else if (themeIndex === ThemeEngine.THEME_PLAIN_AND_BORING) {

            isLight = true
            isDark = false

            themeStatusbar = Material.Dark
            colorStatusbar = "#BBB"

            colorHeader                 = "#eee"
            colorHeaderContent          = "#444"
            colorHeaderHighlight        = Qt.darker(colorHeader, 1.08)

            colorSidebar                = "#eee"
            colorSidebarContent         = "#444"
            colorSidebarHighlight       = Qt.darker(colorSidebar, 1.08)

            colorActionbar              = "#dadada"
            colorActionbarContent       = "#444"
            colorActionbarHighlight     = Qt.darker(colorActionbar, 1.08)

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#0079fe"

            colorBackground             = "#fefefe"
            colorForeground             = "#f6f6f6"

            colorPrimary                = "#ffca28"
            colorSecondary              = "#ffdb28"
            colorSuccess                = colorMaterialLightGreen
            colorWarning                = "#ffac00"
            colorError                  = "#dc4543"

            colorText                   = "#222222"
            colorSubText                = "#555555"
            colorIcon                   = "#333333"
            colorSeparator              = "#e4e4e4"
            colorLowContrast            = "white"
            colorHighContrast           = "black"

            colorComponent              = "#f5f5f5"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#ddd"
            colorComponentDown          = "#eee"
            colorComponentBackground    = "#f8f8f8"

            componentRadius = 4
            componentBorderWidth = 2

            // (app)
            sidebarSelector = "arrow"

        } else if (themeIndex === ThemeEngine.THEME_BLOOD_AND_TEARS) {

            isLight = false
            isDark = true

            themeStatusbar = Material.Dark
            colorStatusbar = "black"

            colorHeader                 = "#141414"
            colorHeaderContent          = "white"
            colorHeaderHighlight        = "#222"

            colorSidebar                = "#181818"
            colorSidebarContent         = "#DDD"
            colorSidebarHighlight       = "#333"

            colorActionbar              = "#009EE2"
            colorActionbarContent       = "white"
            colorActionbarHighlight     = "#0089C3"

            colorTabletmenu             = "#f3f3f3"
            colorTabletmenuContent      = "#9d9d9d"
            colorTabletmenuHighlight    = "#009EE2"

            colorBackground             = "#222"
            colorForeground             = "#333"

            colorPrimary                = "#009EE2"
            colorSecondary              = "#00BEE2"
            colorSuccess                = colorMaterialLightGreen
            colorWarning                = "#FFDB63"
            colorError                  = "#FA6871"

            colorText                   = "#D4D4D4"
            colorSubText                = "#888"
            colorIcon                   = "#A0A0A0"
            colorSeparator              = "#666"
            colorLowContrast            = "black"
            colorHighContrast           = "white"

            colorComponent              = "#fcfcfc"
            colorComponentText          = "black"
            colorComponentContent       = "black"
            colorComponentBorder        = "#e4e4e4"
            colorComponentDown          = "#ddd"
            colorComponentBackground    = "white"

            componentRadius = 2
            componentBorderWidth = 2

            // (app)
            sidebarSelector = "bar"

        } else if (themeIndex === ThemeEngine.THEME_MIGHTY_KITTENS) {

            isLight = true
            isDark = false

            themeStatusbar = Material.Dark
            colorStatusbar = "#944197"

            colorHeader                 = "#FFB4DC"
            colorHeaderContent          = "#aa39ae"
            colorHeaderHighlight        = Qt.darker(colorHeader, 1.1)

            colorSidebar                = "#E31D8D"
            colorSidebarContent         = "#ffc8e4"
            colorSidebarHighlight       = Qt.darker(colorSidebar, 1.15)

            colorActionbar              = "#FFE400"
            colorActionbarContent       = "white"
            colorActionbarHighlight     = Qt.darker(colorActionbar, 1.1)

            colorTabletmenu             = "white"
            colorTabletmenuContent      = "#FFAAD4"
            colorTabletmenuHighlight    = "#944197"

            colorBackground             = "white"
            colorForeground             = "#ffe0ef"

            colorPrimary                = "#FFE400"
            colorSecondary              = "#FFF600"
            colorSuccess                = colorMaterialLightGreen
            colorWarning                = "#944197"
            colorError                  = "#FA6871"

            colorText                   = "#932A97"
            colorSubText                = "#B746BB"
            colorIcon                   = "#ffd947"
            colorSeparator              = "#FFDCED"
            colorLowContrast            = "white"
            colorHighContrast           = "#944197"

            colorComponent              = "#FF87D0"
            colorComponentText          = "#944197"
            colorComponentContent       = "white"
            colorComponentBorder        = "#F592C1"
            colorComponentDown          = "#FF9ED9"
            colorComponentBackground    = "#FFF4F9"

            componentRadius = (componentHeight / 2)
            componentBorderWidth = 2

            // (app)
            sidebarSelector = ""

        }

        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
