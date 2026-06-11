import QtQuick

import ComponentLibrary

Column { // APP SETTINGS

    width: 512
    spacing: 2

    ////////

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

    ////////

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

            Rectangle { // rectangleAuto
                anchors.verticalCenter: parent.verticalCenter
                width: 72
                height: 36
                radius: 4

                color: "white"
                border.color: (SettingsManager.appThemeAuto) ? Theme.colorPrimary : Theme.colorComponentBorder
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: qsTr("auto")
                    textFormat: Text.PlainText
                    color: (SettingsManager.appThemeAuto) ? Theme.colorPrimary : Theme.colorComponentBorder
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        SettingsManager.appThemeAuto = true
                    }
                }
            }
            Rectangle {
                id: rectangleLight
                anchors.verticalCenter: parent.verticalCenter
                width: 72
                height: 36

                property bool selected: (SettingsManager.appTheme === "THEME_DESKTOP_LIGHT" &&
                                         !SettingsManager.appThemeAuto)

                property bool autoselected: (SettingsManager.appThemeAuto &&
                                             Theme.currentTheme === Theme.THEME_DESKTOP_LIGHT)

                radius: 4
                color: "white"
                border.color: rectangleLight.selected ? Theme.colorPrimary : "#757575"
                border.width: 2

                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    width: 8
                    height: 8
                    radius: 8

                    color: Theme.colorPrimary
                    visible: rectangleLight.autoselected
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("light")
                    textFormat: Text.PlainText
                    color: rectangleLight.selected ? Theme.colorPrimary : "#757575"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        SettingsManager.appThemeAuto = false
                        SettingsManager.appTheme = "THEME_DESKTOP_LIGHT"
                    }
                }
            }
            Rectangle {
                id: rectangleDark
                anchors.verticalCenter: parent.verticalCenter
                width: 72
                height: 36
                radius: 4

                property bool selected: (SettingsManager.appTheme === "THEME_DESKTOP_DARK" &&
                                         !SettingsManager.appThemeAuto)

                property bool autoselected: (SettingsManager.appThemeAuto &&
                                             Theme.currentTheme === Theme.THEME_DESKTOP_DARK)

                color: "#555151"
                border.color: Theme.colorSecondary
                border.width: rectangleDark.selected ? 2 : 0

                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    width: 8
                    height: 8
                    radius: 8

                    color: Theme.colorPrimary
                    visible: rectangleDark.autoselected
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("dark")
                    textFormat: Text.PlainText
                    color: rectangleDark.selected ? Theme.colorPrimary : "#ececec"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContentSmall
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        SettingsManager.appThemeAuto = false
                        SettingsManager.appTheme = "THEME_DESKTOP_DARK"
                    }
                }
            }
        }
    }

    ////

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

            z: 1
            wheelEnabled: false

            model: ListModel {
                id: cbAppLanguage
                ListElement {
                    text: qsTr("auto", "short for automatic");
                }
                ListElement { text: "English"; }
                ListElement { text: "Français"; }
                ListElement { text: "Pусский"; }
            }

            Component.onCompleted: {
                for (var i = 0; i < cbAppLanguage.count; i++) {
                    if (cbAppLanguage.get(i).text === SettingsManager.appLanguage)
                        currentIndex = i
                }
            }
            onActivated: {
                utilsLanguage.loadLanguage(cbAppLanguage.get(currentIndex).text)
                SettingsManager.appLanguage = cbAppLanguage.get(currentIndex).text
            }
        }
    }

    ////

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

            currentSelection: SettingsManager.appUnits
            onMenuSelected: (index) => {
                currentSelection = index
                SettingsManager.appUnits = index
            }
        }
    }

    ////

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

            currentSelection: SettingsManager.preferredScreen
            onMenuSelected: (index) => { SettingsManager.preferredScreen = index }
        }
    }

    ////

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

            checked: SettingsManager.appSplashScreen
            onClicked: SettingsManager.appSplashScreen = checked
        }
    }

    ////

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

    ////

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
                if (SettingsManager.exportDirectory.length) {
                    return SettingsManager.exportDirectory
                }
                return StandardPaths.writableLocation(StandardPaths.HomeLocation)
            }

            text: SettingsManager.exportDirectory
            onTextChanged: SettingsManager.exportDirectory = text
        }
    }

    ////
}
