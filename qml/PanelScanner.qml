import QtQuick
import QtQuick.Controls

import ComponentLibrary

Item {
    id: panelScanner
    anchors.fill: parent

    ////////////////

    Rectangle {
        id: actionBar
        anchors.left: parent.left
        anchors.right: parent.right

        z: 5
        height: 44
        color: Theme.colorActionbar

        // prevent clicks below this area
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

        TabBarThemed {
            id: hostMenu
            anchors.fill: parent

            contentHeight: parent.height - separatorHeight
            separatorHeight: 2
            colorBackground: Theme.colorActionbar

            currentIndex: 0
            onCurrentIndexChanged: if (currentIndex === 2) rssiGraph.updateGraph()

            TabButtonThemed {
                text: qsTr("host info")
                colorBackground: Theme.colorActionbar
            }
            TabButtonThemed {
                text: qsTr("proximity radar")
                colorBackground: Theme.colorActionbar
            }
            TabButtonThemed {
                text: qsTr("RSSI graph")
                colorBackground: Theme.colorActionbar
            }
        }
    }

    ////////////////

    Flickable {
        id: hostInfos

        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.componentMargin

        visible: (hostMenu.currentIndex === 0)

        contentWidth: -1
        contentHeight: hostInfosColumn.height

        boundsBehavior: Flickable.OvershootBounds
        ScrollBar.vertical: ScrollBarThemed { policy: ScrollBar.AlwaysOff; }

        Column {
            id: hostInfosColumn
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: Theme.componentMarginL

            Repeater {
                model: deviceManager.adaptersList

                AdapterWidget {
                    width: hostInfosColumn.width
                }
            }
        }
    }
/*
    DevicesSummaryWidget {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.componentMargin

        visible: (hostMenu.currentIndex === 0)

        onExportList: {
            popupLoader_export.active = true
            popupLoader_export.item.open()
        }
    }
*/
    ////////////////

    ProximityRadar {
        id: proximityRadar
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: (hostMenu.currentIndex === 1)
        enabled: (hostMenu.currentIndex === 1)
    }

    ////////////////

    RssiGraph {
        id: rssiGraph
        anchors.top: actionBar.bottom
        anchors.topMargin: -20
        anchors.left: parent.left
        anchors.leftMargin: -24
        anchors.right: parent.right
        anchors.rightMargin: -20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -24

        visible: (hostMenu.currentIndex === 2)
        enabled: (hostMenu.currentIndex === 2)
    }

    ////////////////
}
