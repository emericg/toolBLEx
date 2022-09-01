import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

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

            SelectorMenuThemed {
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

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: hostInfos
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        visible: (hostMenu.currentSelection === 1)

        Flow {
            anchors.fill: parent
            spacing: 20

            Repeater {
                model: deviceManager.adaptersList

                AdapterWidget {
                    width: detailView.ww
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: radar
        anchors.top: actionBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: false
        visible: (hostMenu.currentSelection === 2)

        Rectangle {
            anchors.centerIn: cc
            width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 1.0) : (parent.height * 1.8)
            height: width
            radius: width
            color: Theme.colorActionbar
            opacity: 0.2
            border.width: 2
            border.color: Theme.colorLowContrast
        }
        Rectangle {
            anchors.centerIn: cc
            width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.75) : (parent.height * 1.33)
            height: width
            radius: width
            color: Theme.colorActionbar
            opacity: 0.5
            border.width: 2
            border.color: Theme.colorLowContrast
        }
        Rectangle {
            anchors.centerIn: cc
            width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.45) : (parent.height *0.75)
            height: width
            radius: width
            color: Theme.colorActionbar
            opacity: 0.75
            border.width: 2
            border.color: Theme.colorLowContrast
        }
        Rectangle {
            anchors.centerIn: cc
            width: (settingsManager.scanviewOrientation === Qt.Vertical) ? (parent.width * 0.2) : (parent.height * 0.4)
            height: width
            radius: width
            color: Theme.colorActionbar
            opacity: 1.0
            border.width: 2
            border.color: Theme.colorLowContrast
        }

        Rectangle {
            id: ra
            anchors.centerIn: cc
            width: 0
            height: width
            radius: width
            color: Theme.colorSeparator

            ParallelAnimation {
                alwaysRunToEnd: true
                loops: Animation.Infinite
                running: (deviceManager.scanning && hostMenu.currentSelection === 2)
                NumberAnimation { target: ra; property: "width"; from: 0; to: radar.width*3; duration: 2500; }
                NumberAnimation { target: ra; property: "opacity"; from: 0.85; to: 0; duration: 2500; }
            }
        }

        Rectangle {
            id: cc
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            anchors.verticalCenterOffset: -40
            width: 80
            height: 80
            radius: 80
            color: Theme.colorBackground
            border.width: 2
            border.color: Theme.colorSeparator

            IconSvg {
                anchors.centerIn: parent
                source: "qrc:/assets/icons_material/duotone-devices-24px.svg"
                color: Theme.colorIcon
            }
        }

        ////////

        Repeater {
            anchors.fill: parent
            anchors.margins: 24

            enabled: (deviceManager.scanning && hostMenu.currentSelection === 2)

            model: deviceManager.devicesList
            delegate: Rectangle {
                property var boxDevice: pointer

                property real alpha: Math.random() * (3.14/2) + (3.14/4)
                property real a: c * Math.cos(alpha)
                property real b: c * Math.sin(alpha)
                property real c: radar.height * Math.abs(((boxDevice.rssi)+12) / 100)

                x: (radar.width / 2) - a
                y: radar.height - b

                width: 32
                height: 32
                radius: 32
                opacity: (boxDevice.rssi < 0) ? 1 : 0.66

                border.width: boxDevice.selected ? 6 : 2
                border.color: boxDevice.selected ? Theme.colorSecondary : Qt.darker(color, 1.2)

                color: {
                    if (Math.abs(boxDevice.rssi) < 65) return Theme.colorGreen
                    if (Math.abs(boxDevice.rssi) < 85) return Theme.colorOrange
                    if (Math.abs(boxDevice.rssi) < 100) return Theme.colorRed
                    return Theme.colorRed
                }

                //MouseArea {
                //    anchors.fill: parent
                //    onClicked: boxDevice.selected = !boxDevice.selected
                //}
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

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

    ////////////////////////////////////////////////////////////////////////////
}
