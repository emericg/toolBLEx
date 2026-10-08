import QtQuick
import QtQuick.Controls

import ComponentLibrary

Item {
    id: panelScanner
    anchors.fill: parent

    ////////////////

    Rectangle {
        id: menuBar
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
            separatorHeight: 0
            colorBackground: Theme.colorActionbar

            currentIndex: 0
            onCurrentIndexChanged: if (currentIndex === 2) rssiGraph.updateGraph()

            TabButtonThemed {
                text: qsTr("host info")
                colorBackground: Theme.colorActionbar
                colorBackgroundChecked: Theme.colorGrey
            }
            TabButtonThemed {
                text: qsTr("proximity radar")
                colorBackground: Theme.colorActionbar
                colorBackgroundChecked: Theme.colorGrey
            }
            TabButtonThemed {
                text: qsTr("RSSI graph")
                colorBackground: Theme.colorActionbar
                colorBackgroundChecked: Theme.colorGrey
            }
        }
    }

    ////////////////

    Flickable {
        id: hostInfos

        anchors.top: menuBar.bottom
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
                model: AdapterManager.adaptersList

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
        anchors.top: menuBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: (hostMenu.currentIndex === 1)
        enabled: (hostMenu.currentIndex === 1)
    }

    ////////////////

    RssiGraph {
        id: rssiGraph
        anchors.top: menuBar.bottom
        anchors.topMargin: -10
        anchors.left: parent.left
        anchors.leftMargin: -24
        anchors.right: parent.right
        anchors.rightMargin: -12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -24

        visible: (hostMenu.currentIndex === 2)
        enabled: (hostMenu.currentIndex === 2)
    }

    ////////////////
}
