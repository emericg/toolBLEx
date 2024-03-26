import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects

import ThemeEngine
import DeviceUtils
import "qrc:/js/UtilsPath.js" as UtilsPath

Popup {
    id: popupExportDeviceData

    x: ((appWindow.width / 2) - (width / 2))
    y: ((appWindow.height / 2) - (height / 2) - (appHeader.height))
    width: 720
    padding: 0

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "opacity"; from: 0.333; to: 1.0; duration: 233; } }

    signal confirmed()

    ////////////////////////////////////////////////////////////////////////////

    onAboutToShow: {
        buttonError.visible = false

        tfExportPath.currentFolder = UtilsPath.cleanUrl(StandardPaths.writableLocation(StandardPaths.DocumentsLocation))
        tfExportPath.text = tfExportPath.currentFolder +
                            "/" + selectedDevice.deviceName_export +
                            "-" + selectedDevice.deviceAddr_export + ".txt"

        cbGenericInfo.checked = true
        cbAdvPackets.checked = true
        cbServices.checked = true
        cbData.checked = true
    }

    ////////////////////////////////////////////////////////////////////////////

    Overlay.modal: Rectangle {
        color: "#000"
        opacity: ThemeEngine.isLight ? 0.333 : 0.666
    }

    background: Rectangle {
        radius: Theme.componentRadius
        color: Theme.colorBackground
        border.color: Theme.colorSeparator
        border.width: Theme.componentBorderWidth

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: ThemeEngine.isLight ? "#aa000000" : "#aaffffff"
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Column {
        id: columnContent
        spacing: 24

        ////////

        Rectangle { // titleArea
            anchors.left: parent.left
            anchors.right: parent.right

            height: 96
            color: Theme.colorPrimary
            radius: Theme.componentRadius

            border.color: Qt.darker(color, 1.05)
            border.width: Theme.componentBorderWidth

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Export device data")
                    font.pixelSize: Theme.fontSizeTitle
                    font.bold: true
                    elide: Text.ElideRight
                    color: "white"
                    opacity: 0.98
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Text {
                        Layout.fillWidth: true

                        text: selectedDevice.deviceName
                        font.pixelSize: Theme.fontSizeTitle-4
                        elide: Text.ElideRight
                        color: "white"
                        opacity: 0.92
                    }
                    Text {
                        text: selectedDevice.deviceAddress
                        font.pixelSize: Theme.fontSizeTitle-4
                        elide: Text.ElideRight
                        color: "white"
                        opacity: 0.88
                    }
                }
            }
        }

        ////////

        Column { // contentArea
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            spacing: 24

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    height: 40
                    radius: Theme.componentRadius
                    color: Theme.colorForeground
                    visible: (selectedDevice && selectedDevice.servicesCached)

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24
                        source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
                        color: Theme.colorSubText
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 52
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Services info loaded from cache")
                        color: Theme.colorSubText
                    }
                }

                Flow { // status row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12

                    ItemTag {
                        height: 36
                        text: qsTr("%n adv packet(s)", "", selectedDevice.advCount)
                        textColor: Theme.colorSubText
                    }
                    ItemTag {
                        height: 36
                        text: qsTr("%n service(s)", "", selectedDevice.servicesCount)
                        textColor: Theme.colorSubText
                    }
                    ItemTag {
                        height: 36
                        text: qsTr("%n characteristic(s)", "", selectedDevice.characteristicsCount)
                        textColor: Theme.colorSubText
                    }

                    ButtonWireframe {
                        height: 36

                        text: qsTr("load cache")
                        primaryColor: Theme.colorSubText

                        visible: (selectedDevice && selectedDevice.hasServiceCache &&
                                  !selectedDevice.servicesCached &&
                                  selectedDevice.status === DeviceUtils.DEVICE_OFFLINE)

                        onClicked: selectedDevice.restoreServiceCache()
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Text {
                    text: qsTr("Select data to export")
                    color: Theme.colorText
                }

                Column {
                    Row {
                        CheckBoxThemed {
                            id: cbGenericInfo
                            text: qsTr("Generic info")
                            checked: true
                        }
                        CheckBoxThemed {
                            id: cbAdvPackets
                            text: qsTr("Advertisement packets")
                            checked: true
                        }
                    }
                    Row {
                        CheckBoxThemed {
                            id: cbServices
                            text: qsTr("Services scanned")
                            checked: true
                        }
                        CheckBoxThemed {
                            id: cbData
                            text: qsTr("Characteristics data")
                            checked: true
                        }
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Text {
                    text: qsTr("Select export file")
                    color: Theme.colorText
                }

                TextFieldFileDialog {
                    id: tfExportPath
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40

                    dialogTitle: qsTr("Please select the export file")
                    dialogFilter: ["Text file (*.txt)"]
                    dialogFileMode: FileDialog.SaveFile

                    currentFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
                }
            }
        }

        ////////

        Item  { width: 1; height: 1; } // spacer

        Item {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            height: Theme.componentHeight

            ButtonWireframe {
                id: buttonError
                fullColor: true
                primaryColor: Theme.colorWarning
                visible: false
                text: qsTr("Export error :(")
            }

            Row {
                anchors.right: parent.right
                spacing: 16

                ButtonWireframe {
                    primaryColor: Theme.colorSubText
                    secondaryColor: Theme.colorForeground

                    text: qsTr("Cancel")
                    onClicked: popupExportDeviceData.close()
                }

                ButtonWireframe {
                    fullColor: true
                    primaryColor: Theme.colorOrange

                    text: qsTr("Export data")
                    onClicked: {
                        var status = selectedDevice.exportDeviceInfo(tfExportPath.text,
                                                                     cbGenericInfo.checked, cbAdvPackets.checked,
                                                                     cbServices.checked, cbData.checked)
                        if (status) {
                            buttonError.visible = false
                            popupExportDeviceData.confirmed()
                            popupExportDeviceData.close()
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
