import QtQuick
import QtQuick.Layouts

import ComponentLibrary

import "qrc:/js/UtilsBluetooth.js" as UtilsBluetooth

Rectangle {
    id: adapterWidget
    height: box.height + 28
    radius: 4

    clip: false
    color: Theme.colorBox
    border.width: 2
    border.color: Theme.colorBoxBorder

    ////////

    Rectangle { // yellow bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 8
        radius: 2
        color: Theme.colorPrimary
        visible: modelData.isDefault
    }

    ////////

    Column {
        id: box
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        property int legendWidth: 64

        Component.onCompleted: {
            legendWidth = 64
            legendWidth = Math.max(legendWidth, legendHostname.contentWidth)
            legendWidth = Math.max(legendWidth, legendAddress.contentWidth)
            legendWidth = Math.max(legendWidth, legendMAC.contentWidth)
            legendWidth = Math.max(legendWidth, legendBluetooth.contentWidth)
            legendWidth = Math.max(legendWidth, legendHostMode.contentWidth)
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            height: 32

            text: qsTr("Bluetooth adapter #%1").arg(index+1)
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            font.bold: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: Theme.colorText
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                id: legendHostname
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("Hostname")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: 32

                text: modelData.hostname
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                id: legendAddress
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("MAC address")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: 32

                text: modelData.address
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            visible: modelData.manufacturer.length

            Text {
                id: legendMAC
                Layout.preferredWidth: box.legendWidth
                Layout.alignment: Qt.AlignCenter

                text: qsTr("MAC vendor")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TextSelectable {
                Layout.fillWidth: true
                Layout.minimumHeight: 32

                text: modelData.manufacturer
                wrapMode: Text.WrapAnywhere
            }
        }

        Row {
            height: 32
            spacing: 12

            visible: modelData.version.length

            Text {
                id: legendBluetooth
                anchors.verticalCenter: parent.verticalCenter
                width: box.legendWidth

                text: qsTr("Bluetooth")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TagDesktop {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.version
                colorBackground: Theme.colorComponent
                colorBorder: Theme.colorComponent
            }
        }

        Row {
            height: 32
            spacing: 12

            Text {
                id: legendHostMode
                anchors.verticalCenter: parent.verticalCenter
                width: box.legendWidth

                text: qsTr("Host mode")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                horizontalAlignment: Text.AlignRight
                color: Theme.colorSubText
            }

            TagDesktop {
                anchors.verticalCenter: parent.verticalCenter
                text: UtilsBluetooth.getBluetoothAdapterModeText(modelData.mode)
                colorBackground: Theme.colorComponent
                colorBorder: Theme.colorComponent
            }
        }
    }

    ////////

    Rectangle { // bluetooth icon
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: 96; height: 96; radius: 96;
        color: Theme.colorBackground

        visible: (detailView.ww > 400)
/*
        Rectangle { // scanning indicator
            id: circlePulseAnimation
            anchors.centerIn: parent
            width: 64
            height: 64
            radius: 64
            color: Theme.colorBox

            ParallelAnimation {
                running: (deviceManager.scanning && !deviceManager.scanningPaused &&
                          appContent.state === "Scanner" && hostMenu.currentSelection === 1)
                alwaysRunToEnd: true
                loops: Animation.Infinite

                NumberAnimation { target: circlePulseAnimation; property: "width"; from: 40; to: 96; duration: 1500; }
                NumberAnimation { target: circlePulseAnimation; property: "height"; from: 40; to: 96; duration: 1500; }
                OpacityAnimator { target: circlePulseAnimation; from: 1; to: 0; duration: 1500; }
            }
        }
*/
        IconSvg {
            anchors.centerIn: parent
            width: 64
            height: 64

            source: "qrc:/IconLibrary/bootstrap/bluetooth.svg"
            color: Theme.colorSubText
        }
    }

    ////////
}
