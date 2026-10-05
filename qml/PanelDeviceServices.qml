import QtQuick
import QtQuick.Controls

import QtCore
import QtQuick.Dialogs

import ComponentLibrary
import DeviceUtils

Item {
    id: panelDeviceService

    ////////////////

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.componentMargin

        z: 5
        spacing: Theme.componentMargin
        visible: (selectedDevice && selectedDevice.servicesCount === 0)

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right

            height: svd_nodata.height + Theme.componentMargin*2
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            Text {
                id: svd_nodata
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Services have not been scanned yet...")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorText
            }
        }
    }

    ////////////////

    ListView { // servicesView
        anchors.fill: parent

        clip: false
        visible: (selectedDevice && selectedDevice.servicesCount > 0)

        boundsBehavior: Flickable.OvershootBounds
        ScrollBar.vertical: ScrollBarThemed { policy: ScrollBar.AsNeeded; }

        header: Rectangle {
            width: ListView.view.width
            height: visible ? 40 : 0
            color: Theme.colorForeground

            visible: (selectedDevice && (selectedDevice.servicesCached || !selectedDevice.connected))

            IconSvg {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"
                color: Theme.colorSubText
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                visible: (selectedDevice && selectedDevice.servicesCached)
                text: qsTr("Services info loaded from cache")
                color: Theme.colorText
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                visible: (selectedDevice && !selectedDevice.servicesCached && !selectedDevice.connected)
                text: qsTr("Device is disconnected")
                color: Theme.colorText
            }
        }

        model: (selectedDevice && selectedDevice.servicesList)
        delegate: BleServiceWidget {
            width: ListView.view.width
        }
    }

    ////////////////

    Row { // buttons row
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.componentMarginXS
        spacing: Theme.componentMarginXS

        ButtonSolid { // loading
            visible: (selectedDevice && selectedDevice.hasServices && !selectedDevice.servicesScanned &&
                      selectedDevice.status >= DeviceUtils.DEVICE_WORKING)

            text: qsTr("Scanning...")
            color: Theme.colorGrey
        }

        ButtonSolid { // clearButton
            visible: (selectedDevice && selectedDevice.hasServices && selectedDevice.servicesScanned)

            text: qsTr("Clear")
            color: Theme.colorGrey

            enabled: (selectedDevice && selectedDevice.status < DeviceUtils.DEVICE_WORKING)
            onClicked: {
                selectedDevice.clearDeviceServices()
            }
        }
        ButtonSolid { // cacheButton
            visible: (selectedDevice && selectedDevice.hasServices && selectedDevice.servicesScanned)

            text: qsTr("Cache")
            color: Theme.colorGrey
            source: "qrc:/IconLibrary/material-symbols/save.svg"

            onClicked: {
                selectedDevice.saveServiceCache()
            }
        }
    }

    ////////////////
}
