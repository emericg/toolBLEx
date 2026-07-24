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
            height: columnServiceScan.height + 32
            radius: 4

            clip: false
            color: Theme.colorBox
            border.width: 2
            border.color: Theme.colorBoxBorder

            Column {
                id: columnServiceScan
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.componentMarginS

                ////

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Services have not been scanned yet...")
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                }

                ////

                Flow { // buttons row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Theme.componentMarginS

                    property int www: (width > 400) ? ((width - spacing) / 2) : width

                    ButtonScanMenu {
                        width: parent.www
                    }

                    ButtonFlat {
                        width: parent.www

                        color: Theme.colorGrey

                        text: qsTr("Load from cache")
                        source: "qrc:/IconLibrary/material-symbols/save.svg"

                        visible: (selectedDevice && selectedDevice.hasServiceCache)
                        //enabled: selectedDevice.status === DeviceUtils.DEVICE_OFFLINE
                        onClicked: selectedDevice.restoreServiceCache()
                    }
                }

                ////
            }
        }
    }

    ////////////////

    ListView { // servicesView
        anchors.fill: parent

        clip: false
        visible: (selectedDevice && selectedDevice.servicesCount > 0)

        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
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

        ButtonSolid {
            id: cacheButton

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
