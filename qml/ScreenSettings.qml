import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import ComponentLibrary

Loader {
    id: screenSettings
    anchors.fill: parent

    ////////////////

    function loadScreen() {
        screenSettings.active = true
        appContent.state = "Settings"
    }

    function backAction() {
        if (screenSettings.status === Loader.Ready)
            screenSettings.item.backAction()
    }

    ////////////////

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

        ////////////////////////////////////////////////////////////////////////

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: settingsColumn.height

            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: settingsColumn
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: 0
                bottomPadding: Theme.componentMarginL
                spacing: Theme.componentMarginL

                property int flowElementWidth: (width >= 1080) ? (width / 3) - (spacing*1) - (spacing / 3)
                                                               : (width / 2) - (spacing*1) - (spacing / 2)

                ////////////////////////

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
                        source: "qrc:/assets/gfx/logos/pattern_ble.png"
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

                                    text: qsTr("version %1 %2").arg(utilsApp.appVersion()).arg(utilsApp.appBuildMode())
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentBig
                                    color: "white" // Theme.colorSubText
                                }

                                Text {
                                    anchors.baseline: title.baseline

                                    visible: utilsApp.isDebugBuild()
                                    text: qsTr("built on %1").arg(utilsApp.appBuildDateTime())
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

                ////////////////////////

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.componentMarginL

                    flow: Flow.LeftToRight // Flow.TopToBottom
                    spacing: Theme.componentMarginL

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Application settings")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"
                                color: Theme.colorIcon
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Theme")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                z: 1
                                spacing: 10

                                Rectangle {
                                    id: rectangleLight
                                    width: 80
                                    height: Theme.componentHeight
                                    anchors.verticalCenter: parent.verticalCenter

                                    radius: 4
                                    color: "white"
                                    border.color: (settingsManager.appTheme === "THEME_DESKTOP_LIGHT") ? Theme.colorSecondary : "#757575"
                                    border.width: 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("light")
                                        textFormat: Text.PlainText
                                        color: (settingsManager.appTheme === "THEME_DESKTOP_LIGHT") ? Theme.colorPrimary : "#757575"
                                        font.bold: true
                                        font.pixelSize: Theme.fontSizeContentSmall
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: settingsManager.appTheme = "THEME_DESKTOP_LIGHT"
                                    }
                                }
                                Rectangle {
                                    id: rectangleDark
                                    width: 80
                                    height: Theme.componentHeight
                                    anchors.verticalCenter: parent.verticalCenter

                                    radius: 4
                                    color: "#555151"
                                    border.color: Theme.colorSecondary
                                    border.width: (settingsManager.appTheme === "THEME_DESKTOP_DARK") ? 2 : 0

                                    Text {
                                        anchors.centerIn: parent
                                        text: qsTr("dark")
                                        textFormat: Text.PlainText
                                        color: (settingsManager.appTheme === "THEME_DESKTOP_DARK") ? Theme.colorPrimary : "#ececec"
                                        font.bold: true
                                        font.pixelSize: Theme.fontSizeContentSmall
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: settingsManager.appTheme = "THEME_DESKTOP_DARK"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Language")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            ComboBoxThemed {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                enabled: false
                                model: ["auto"]
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Unit system")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SelectorMenuColorful {
                                height: 32
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                model: ListModel {
                                    ListElement { idx: 0; txt: qsTr("metric"); src: ""; sz: 16; }
                                    ListElement { idx: 1; txt: qsTr("imperial"); src: ""; sz: 16; }
                                }

                                currentSelection: settingsManager.appUnits
                                onMenuSelected: (index) => {
                                    currentSelection = index
                                    settingsManager.appUnits = index
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: selector_prefscreen.left
                                anchors.rightMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Preferred screen")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SelectorMenuColorful {
                                id: selector_prefscreen
                                height: 32
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                ListModel {
                                    id: lmScreens1
                                    ListElement { idx: 0; txt: qsTr("scanner"); src: ""; sz: 16; }
                                    ListElement { idx: 1; txt: qsTr("advertiser"); src: ""; sz: 16; }
                                    ListElement { idx: 2; txt: qsTr("freq. analyzer"); src: ""; sz: 16; }
                                }
                                ListModel {
                                    id: lmScreens2
                                    ListElement { idx: 0; txt: qsTr("scanner"); src: ""; sz: 16; }
                                    ListElement { idx: 1; txt: qsTr("advertiser"); src: ""; sz: 16; }
                                }
                                model: ubertooth.toolsAvailable ? lmScreens1 : lmScreens2

                                currentSelection: settingsManager.preferredScreen
                                onMenuSelected: (index) => { settingsManager.preferredScreen = index }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Show splashscreen on startup")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemed {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.appSplashScreen
                                onClicked: settingsManager.appSplashScreen = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Default export directory:")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            FolderInputArea {
                                id: exportDirectory
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMargin
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                placeholderText: qsTr("Default export directory")
                                selectByMouse: true

                                dialogTitle: qsTr("Please specify the default export directory")
                                currentFolder: {
                                    if (settingsManager.exportDirectory.length) {
                                        return settingsManager.exportDirectory
                                    }
                                    return StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                }

                                text: settingsManager.exportDirectory
                                onTextChanged: settingsManager.exportDirectory = text
                            }
                        }
                    }

                    ////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Scanner")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/IconLibrary/material-icons/duotone/devices.svg"
                                color: Theme.colorIcon
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Start scanning automatically")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemed {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.scanAuto
                                onClicked: settingsManager.scanAuto = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Pause scanning while in the background")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemed {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.scanPause
                                onClicked: settingsManager.scanPause = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Scanning timeout")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SpinBoxThemedDesktop {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                editable: false
                                legend: "m"
                                from: 0
                                to: 10

                                value: settingsManager.scanTimeout
                                onValueModified: settingsManager.scanTimeout = value
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("RSSI graph interval")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SpinBoxThemedDesktop {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                editable: false
                                legend: "ms"
                                from: 250
                                to: 2500
                                stepSize: 250

                                value: settingsManager.scanRssiInterval
                                onValueModified: settingsManager.scanRssiInterval = value
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Automatically save devices seen nearby")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContent
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            SwitchThemed {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter

                                checked: settingsManager.scanCacheAuto
                                onClicked: settingsManager.scanCacheAuto = checked
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: (deviceManager.deviceSeenCached > 0)

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.componentMarginXL

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("Device seen cache")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("%n device(s)", "", deviceManager.deviceSeenCached)
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentSmall
                                    color: Theme.colorText

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        z: -1
                                        radius: Theme.componentRadius
                                        color: Theme.colorComponent
                                    }
                                }
                            }

                            ButtonFlat {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter
                                height: 34

                                text: qsTr("Clear cache")
                                onClicked: {
                                    popupLoader_cacheseen.active = true
                                    popupLoader_cacheseen.item.open()
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: (deviceManager.deviceSeenCached > 0)

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 64
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.componentMarginXL

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("Device structure cache")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("%n device(s)", "", deviceManager.deviceStructureCached)
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentSmall
                                    color: Theme.colorText

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        z: -1
                                        radius: Theme.componentRadius
                                        color: Theme.colorComponent
                                    }
                                }
                            }

                            ButtonFlat {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter
                                height: 34

                                text: qsTr("Clear cache")
                                onClicked: {
                                    popupLoader_cachestructure.active = true
                                    popupLoader_cachestructure.item.open()
                                }
                            }
                        }
                    }

                    ////

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        visible: (Qt.platform.os === "linux" || Qt.platform.os === "osx")

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Spectrum analyzer")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/IconLibrary/material-icons/duotone/microwave.svg"
                                color: Theme.colorIcon
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: colUber.height + 16
                            color: Theme.colorForeground

                            Column {
                                id: colUber
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 52
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    text: qsTr("This feature relies on specific hardware.")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    text: qsTr("Ubertooth One is an open source 2.4 GHz wireless development platform suitable for Bluetooth experimentation.")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                }/*
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    text: "https://greatscottgadgets.com/ubertoothone/"
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContent
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                }*/
                            }

                            IconSvg {
                                width: 28
                                height: 28
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                source: "qrc:/IconLibrary/material-symbols/help-fill.svg"
                                color: Theme.colorSubText
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            FileInputArea {
                                id: ubertoothPath
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMargin
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                selectByMouse: true

                                text: settingsManager.ubertooth_path
                                placeholderText: "ubertooth-specan"

                                dialogTitle: qsTr("Please specify the path to the ubertooth-specan binary")
                                dialogFilter: ["specan binary (ubertooth-specan)"]
                                dialogFileMode: FileDialog.OpenFile

                                IconSvg {
                                    anchors.right: parent.right
                                    anchors.rightMargin: parent.buttonWidth+4
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 24
                                    height: 24

                                    visible: ubertooth.toolsAvailable
                                    source: "qrc:/IconLibrary/material-symbols/check_circle.svg"
                                    color: Theme.colorSuccess
                                }

                                onTextChanged: {
                                    settingsManager.ubertooth_path = text
                                    ubertooth.checkPath()
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: ubertooth.toolsAvailable

                            RangeSliderThemed {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 2

                                from: 2300
                                to: 2600
                                first.value: settingsManager.ubertooth_freqMin
                                first.onMoved: settingsManager.ubertooth_freqMin = first.value
                                second.value: settingsManager.ubertooth_freqMax
                                second.onMoved: settingsManager.ubertooth_freqMax = second.value
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            visible: ubertooth.toolsAvailable

                            SpinBoxThemedDesktop {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter
                                z: 2

                                hoverEnabled: false
                                editable: false
                                from: 2300
                                to: 2600
                                legend: "MHz"

                                value: settingsManager.ubertooth_freqMin
                                onValueModified: settingsManager.ubertooth_freqMin = value
                            }

                            ButtonDesktop {
                                anchors.centerIn: parent
                                visible: (settingsManager.ubertooth_freqMin !== 2402 || settingsManager.ubertooth_freqMax !== 2480)

                                text: qsTr("Default")
                                onClicked: {
                                    settingsManager.ubertooth_freqMin = 2402
                                    settingsManager.ubertooth_freqMax = 2480
                                }
                            }

                            SpinBoxThemedDesktop {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter
                                z: 2

                                hoverEnabled: false
                                editable: false
                                from: 2300
                                to: 2600
                                legend: "MHz"

                                value: settingsManager.ubertooth_freqMax
                                onValueModified: settingsManager.ubertooth_freqMax = value
                            }
                        }
                    }

                    ////
                }

                ////////////////////////

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.componentMarginL
                    flow: Flow.LeftToRight // Flow.TopToBottom
                    spacing: Theme.componentMarginL

                    Column {
                        width: settingsColumn.flowElementWidth
                        spacing: 2

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorActionbar

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("Third parties")
                                textFormat: Text.PlainText
                                font.pixelSize: Theme.fontSizeContentVeryBig
                                font.bold: false
                                color: Theme.colorText
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            color: Theme.colorForeground

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMarginL
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("This application is made possible thanks to a couple of third party open source projects:")
                                textFormat: Text.PlainText
                                color: Theme.colorText
                                font.pixelSize: Theme.fontSizeContent
                                wrapMode: Text.WordWrap
                            }
                        }

                        Repeater {
                            model: ListModel {
                                ListElement { txt: "Qt6"; license: "LGPL v3"; link: "https://qt.io" }
                                ListElement { txt: "SingleApplication"; license: "MIT"; link: "https://github.com/itay-grudev/SingleApplication" }
                                ListElement { txt: "Google Material Icons"; license: "MIT"; link: "https://fonts.google.com/icons" }
                                ListElement { txt: "Bootstrap Icons"; license: "MIT"; link: "https://icons.getbootstrap.com/" }
                            }
                            delegate: Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 2

                                Rectangle {
                                    width: parent.width * 0.66 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.componentMarginL
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: "- " + txt
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    width: parent.width * 0.24 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.centerIn: parent

                                        text: license
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    width: parent.width * 0.1 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: Qt.openUrlExternally(link)
                                        hoverEnabled: true

                                        IconSvg {
                                            anchors.centerIn: parent
                                            width: 20
                                            height: 20

                                            source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                                            color: parent.containsMouse ? Theme.colorPrimary : Theme.colorText
                                            Behavior on color { ColorAnimation { duration: 133 } }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ////

                    Loader { // DEBUG PANEL
                        active: utilsApp.isDebugBuild()
                        asynchronous: true

                        sourceComponent: Column {
                            width: settingsColumn.flowElementWidth
                            spacing: 2

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 48
                                color: Theme.colorActionbar

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.componentMarginL
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: qsTr("System info")
                                    textFormat: Text.PlainText
                                    font.pixelSize: Theme.fontSizeContentVeryBig
                                    font.bold: false
                                    color: Theme.colorText
                                    wrapMode: Text.WordWrap
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 2

                                Rectangle {
                                    width: parent.width * 0.5 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.componentMarginL
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: {
                                            var txt = utilsSysInfo.getOsName()
                                            if (utilsSysInfo.getOsVersion() !== "unknown")
                                            {
                                                if (txt.length) txt += " "
                                                txt += utilsSysInfo.getOsVersion()
                                            }
                                            return txt
                                        }

                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    width: parent.width * 0.5 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.centerIn: parent

                                        text: {
                                            var txt = utilsSysInfo.getOsDisplayServer()
                                            if (txt.length) txt += " / "
                                            txt += utilsApp.qtRhiBackend()
                                            return txt
                                        }
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 2

                                Rectangle {
                                    width: parent.width * 0.5 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.componentMarginL
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: "Qt version"
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    width: parent.width * 0.5 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.centerIn: parent

                                        text: utilsApp.qtVersion()
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 2

                                Rectangle {
                                    width: parent.width * 0.5 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.componentMarginL
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: "Qt architecture"
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    width: parent.width * 0.5 - 1
                                    height: 32
                                    color: Theme.colorForeground

                                    Text {
                                        anchors.centerIn: parent

                                        text: utilsApp.qtArchitecture()
                                        textFormat: Text.PlainText
                                        color: Theme.colorText
                                        font.pixelSize: Theme.fontSizeContent
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }

                    ////
                }

                ////////
            }
        }

        ////////////////////////////////////////////////////////////////////////
    }

    ////////////////
}
