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

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: -4
        spacing: 8

        ButtonWireframeIcon {
            id: formatButton

            fullColor: true
            primaryColor: Theme.colorLightGrey

            visible: (selectedDevice && selectedDevice.deviceLog)

            text: qsTr("format:") + " " + logFormat

            onClicked: {
                if (logFormat === "adv") logFormat = "txt"
                else logFormat = "adv"
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -4
        spacing: 8

        ButtonWireframeIcon {
            id: clearButton

            fullColor: true
            primaryColor: Theme.colorLightGrey

            visible: (selectedDevice && selectedDevice.deviceLog)

            text: qsTr("Clear")
            //source: "qrc:/assets/icons_material/baseline-save-24px.svg"

            onClicked: {
                selectedDevice.clearLog()
            }
        }

        ButtonWireframeIcon {
            id: saveButton

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
