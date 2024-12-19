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

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            spacing: 16

            SelectorMenu {
                id: hostMenu
                height: 32

                currentSelection: 1
                model: ListModel {
                    id: lmSelectorMenuTxt1
                    ListElement { idx: 1; txt: qsTr("host info"); src: ""; sz: 0; }
                    ListElement { idx: 2; txt: qsTr("proximity radar"); src: ""; sz: 0; }
                    ListElement { idx: 3; txt: qsTr("RSSI graph"); src: ""; sz: 0; }
                }

                onMenuSelected: (index) => {
                    //console.log("SelectorMenu clicked #" + index)
                    currentSelection = index
                    if (currentSelection === 3) rssiGraph.updateGraph()
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

    ////////////////

    Item {
        id: hostInfos
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16

        visible: (hostMenu.currentSelection === 1)

        Flow {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20

            Repeater {
                model: deviceManager.adaptersList

                AdapterWidget {
                    width: detailView.ww
                }
            }
        }
    }

    ////////////////

    ProximityRadar {
        id: proximityRadar
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: (hostMenu.currentSelection === 2)
        enabled: (hostMenu.currentSelection === 2)
    }

    ////////////////

    RssiGraph {
        id: rssiGraph
        anchors.top: actionBar.bottom
        anchors.topMargin: -16
        anchors.left: parent.left
        anchors.leftMargin: -16
        anchors.right: parent.right
        anchors.rightMargin: -16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -16

        visible: (hostMenu.currentSelection === 3)
        enabled: (hostMenu.currentSelection === 3)
    }

    ////////////////
}
