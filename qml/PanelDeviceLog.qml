import QtQuick
import QtQuick.Controls

import QtCore
import QtQuick.Dialogs

import ThemeEngine
import DeviceUtils
import "qrc:/js/UtilsDeviceSensors.js" as UtilsDeviceSensors
import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth
import "qrc:/js/UtilsPath.js" as UtilsPath

Flickable {
    id: panelDeviceLog

    ////////

    property string logFormat: "adv"
    property bool logLegend: false

    Rectangle {
        width: detailView.ww
        height: log_nodata.height + 32
        radius: 4

        clip: false
        color: Theme.colorBox
        border.width: 2
        border.color: Theme.colorBoxBorder

        visible: (selectedDevice && selectedDevice.deviceLogCount <= 0)

        Text {
            id: log_nodata
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("No event logged yet...")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
        }
    }

    Loader {
        anchors.fill: parent
        anchors.margins: -16

        active: (logFormat === "txt")
        asynchronous: true
        sourceComponent: logTextView
    }

    Loader {
        anchors.fill: parent
        anchors.margins: -16

        active: (logFormat === "adv")
        asynchronous: true
        sourceComponent: logAdvView
    }

    ////////

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: -4
        spacing: 8

        visible: (selectedDevice && selectedDevice.deviceLogCount > 0)

        Row {
            visible: logLegend
            spacing: 8

            Repeater {
                model: [
                    "CONNECTION",
                    "STATE",
                    "DATA",
                    "ADVERTISEMENT",
                    "USER ACTION",
                    "ERROR",
                ]
                delegate:
                    Row {
                        spacing: 6
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            radius: 4
                            color: {
                                if (index === 0) return Theme.colorMaterialGreen
                                if (index === 1) return Theme.colorMaterialLime
                                if (index === 2) return Theme.colorMaterialBlue
                                if (index === 3) return Theme.colorMaterialLightBlue
                                if (index === 4) return Theme.colorPrimary
                                if (index === 5) return Theme.colorError
                                return Theme.colorBox
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            textFormat: Text.PlainText
                            color: {
                                if (index === 0) return Theme.colorMaterialGreen
                                if (index === 1) return Theme.colorMaterialLime
                                if (index === 2) return Theme.colorMaterialBlue
                                if (index === 3) return Theme.colorMaterialLightBlue
                                if (index === 4) return Theme.colorPrimary
                                if (index === 5) return Theme.colorError
                                return Theme.colorBox
                            }
                        }
                    }
            }
        }

        Row {
            spacing: 8

            ButtonWireframeIcon { // formatButton
                fullColor: true
                primaryColor: Theme.colorLightGrey

                visible: (selectedDevice && selectedDevice.deviceLog)

                text: qsTr("format:") + " " + logFormat

                onClicked: {
                    if (logFormat === "adv") logFormat = "txt"
                    else logFormat = "adv"
                }
            }

            ButtonWireframeIcon { // legendButton
                fullColor: true
                primaryColor: logLegend ? Theme.colorGrey : Theme.colorLightGrey

                visible: (selectedDevice && selectedDevice.deviceLog)

                text: qsTr("legend")

                onClicked: {
                    logLegend = !logLegend
                }
            }
        }
    }

    ////

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -4
        spacing: 8

        visible: (selectedDevice && selectedDevice.deviceLogCount > 0)

        ButtonWireframeIcon { // clearButton
            fullColor: true
            primaryColor: Theme.colorLightGrey

            visible: (selectedDevice && selectedDevice.deviceLog)

            text: qsTr("Clear")
            //source: "qrc:/assets/icons_material/baseline-save-24px.svg"

            onClicked: {
                selectedDevice.clearLog()
            }
        }

        ButtonWireframeIcon { // saveButton

            fullColor: true
            primaryColor: Theme.colorGrey

            visible: (selectedDevice && selectedDevice.deviceLog)

            text: qsTr("Save")
            source: "qrc:/assets/icons_material/baseline-save-24px.svg"

            onClicked: {
                selectedDevice.saveLog("")
            }
        }
    }

    ////////

    Component {
        id: logTextView

        ScrollView {
            anchors.fill: parent

            TextArea {
                text: (selectedDevice && selectedDevice.deviceLogStr)
                textFormat: Text.PlainText
                color: Theme.colorText
                wrapMode: Text.WrapAnywhere
                readOnly: true
            }
        }
    }

    Component {
        id: logAdvView

        ListView {
            anchors.fill: parent

            model: (selectedDevice && selectedDevice.deviceLog)
            delegate: DeviceLogWidget {
                width: parent.width
            }
        }
    }

    ////////
}
