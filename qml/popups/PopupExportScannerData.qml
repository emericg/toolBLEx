import QtCore
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import ComponentLibrary
import DeviceUtils

Popup {
    id: popupExportScannerData

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    ////////////////////////////////////////////////////////////////////////////

    onAboutToShow: {
        buttonError.visible = false

        var foldersep = "/"
        if (settingsManager.exportDirectory_str.substr(-1) === "/") foldersep = ""

        tfExportPath.currentFolder = settingsManager.exportDirectory_url
        tfExportPath.text = settingsManager.exportDirectory_str + foldersep +
                            "devicelist_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm") + ".csv"
    }

    ////////////////////////////////////////////////////////////////////////////

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 133; } }

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: Theme.isLight ? 0.333 : 0.666
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground

        Item {
            anchors.fill: parent

            Rectangle { // title area
                anchors.left: parent.left
                anchors.right: parent.right
                height: 96
                color: Theme.colorPrimary
            }

            Rectangle { // border
                anchors.fill: parent
                radius: Theme.componentRadius
                color: "transparent"
                border.color: Theme.colorSeparator
                border.width: Theme.componentBorderWidth
                opacity: 0.4
            }

            layer.enabled: true
            layer.effect: MultiEffect { // clip
                maskEnabled: true
                maskInverted: false
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        x: background.x
                        y: background.y
                        width: background.width
                        height: background.height
                        radius: background.radius
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect { // shadow
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: Theme.isLight ? "#aa000000" : "#aaffffff"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        spacing: Theme.componentMarginXL

        ////////

        Item { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right
            height: 96

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginXL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginXL
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Export scanner device list")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: {
                        var txt = qsTr("%n device(s) found", "", deviceManager.deviceCountFound)
                        if (deviceManager.deviceCountShown !== deviceManager.deviceCountFound) {
                            txt += "  |  " + qsTr("%n device(s) shown", "", deviceManager.deviceCountShown)
                        }
                        if (deviceManager.deviceCountTotal !== deviceManager.deviceCountCached) {
                            txt += "  |  " + qsTr("%n device(s) cached", "", deviceManager.deviceCountCached)
                        }
                        //if (deviceManager.deviceCountBlacklisted > 0) {
                        //    txt += "  |  " + qsTr("%n device(s) blacklisted", "", deviceManager.deviceCountBlacklisted)
                        //}
                        //if (deviceManager.deviceCountTotal !== deviceManager.deviceCountShown) {
                        //    txt += "  |  " + qsTr("%n device(s) total", "", deviceManager.deviceCountTotal)
                        //}
                        return txt
                    }
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeTitle-4
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.92
                }
            }
        }

        ////////

        Column { // contentArea
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            spacing: Theme.componentMarginXL

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Flow { // status row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    TagClear {
                        height: 36
                        text: qsTr("%n Found", "", deviceManager.deviceCountFound)
                        //colorText: Theme.colorSubText
                    }
                    TagClear {
                        height: 36
                        text: qsTr("%n Shown", "", deviceManager.deviceCountShown)
                        //colorText: Theme.colorSubText
                    }
                    TagClear {
                        height: 36
                        text: qsTr("%n Hidden", "", deviceManager.deviceCountHidden)
                        //colorText: Theme.colorSubText
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Text {
                    text: qsTr("Select devices to export")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                SelectorMenuColorful {
                    id: selectorExportMode
                    height: 32

                    model: ListModel {
                        ListElement { idx: 0; txt: qsTr("All"); src: ""; sz: 16; }
                        ListElement { idx: 1; txt: qsTr("Found"); src: ""; sz: 16; }
                        ListElement { idx: 2; txt: qsTr("Shown"); src: ""; sz: 16; }
                    }

                    currentSelection: 2 // "shown"
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Text {
                    text: qsTr("Optional data to export")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                Flow {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    CheckBoxThemed {
                        id: cbManufacturer
                        text: qsTr("Manufacturer")
                        checked: true
                    }
                    CheckBoxThemed {
                        id: cbComment
                        text: qsTr("User comment")
                        checked: false
                    }
                    CheckBoxThemed {
                        id: cbSeen
                        text: qsTr("First/last seen")
                        checked: false
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Text {
                    text: qsTr("Select export file")
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContent
                    color: Theme.colorText
                }

                FileInputArea {
                    id: tfExportPath
                    anchors.left: parent.left
                    anchors.right: parent.right

                    dialogTitle: qsTr("Please select the export file")
                    dialogFilter: ["CSV file (*.csv)"]
                    dialogFileMode: FileDialog.SaveFile

                    currentFolder: settingsManager.exportDirectory_url
                }
            }
        }

        ////////

        Item  { width: 1; height: 1; } // spacer

        Item {
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL
            height: Theme.componentHeight

            ButtonSolid {
                id: buttonError
                color: Theme.colorWarning
                visible: false
                text: qsTr("Export error :(")
            }

            Row {
                anchors.right: parent.right
                spacing: Theme.componentMargin

                ButtonSolid {
                    color: Theme.colorMaterialGrey

                    text: qsTr("Cancel")
                    onClicked: popupExportScannerData.close()
                }

                ButtonSolid {
                    color: Theme.colorMaterialAmber

                    text: qsTr("Export data")
                    onClicked: {
                        var status = deviceManager.exportResults(tfExportPath.text,
                                                                 selectorExportMode.currentSelection,
                                                                 cbManufacturer.checked,
                                                                 cbComment.checked,
                                                                 cbSeen.checked)
                        if (status) {
                            buttonError.visible = false
                            popupExportScannerData.close()
                        } else {
                            buttonError.visible = true
                        }
                    }
                }
            }
        }

        Item  { width: 1; height: 1; } // spacer

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
