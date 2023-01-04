import QtQuick

import ThemeEngine 1.0

Rectangle {
    id: deviceScannerHeader
    anchors.left: parent.left
    anchors.right: parent.right

    z: 5
    height: 36
    color: Theme.colorLVheader

    property bool showAddress: (Qt.platform.os !== "osx")
    property bool showManufacturer: (Qt.platform.os !== "osx")

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        Item { width: 16; height: 24; }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            visible: showAddress
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // address column header
            anchors.verticalCenter: parent.verticalCenter
            width: ref.contentWidth

            visible: showAddress

            text: qsTr("Address")
            color: Theme.colorText
            font.bold: (deviceManager.orderBy_role === "address")

            Text {
                id: ref
                visible: false
                text: (Qt.platform.os === "osx") ?
                          "329562a2-d357-470a-862c-6f6b73397607" :
                          "00:11:22:33:44:55"
                textFormat: Text.PlainText
                font.family: "Monospace"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_address()
            }

            Canvas {
                id: indicatorAddress
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "address")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorAddress.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // name column header
            anchors.verticalCenter: parent.verticalCenter
            width: 220

            text: qsTr("Advertised name")
            color: Theme.colorText
            font.bold: (deviceManager.orderBy_role === "name")

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_name()
            }

            Canvas {
                id: indicatorName
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "name")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorName.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            visible: showAddress
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // manufacturer column header
            anchors.verticalCenter: parent.verticalCenter
            width: 220

            visible: showAddress

            text: qsTr("Manufacturer")
            font.bold: (deviceManager.orderBy_role === "manufacturer")
            color: Theme.colorText

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_manufacturer()
            }

            Canvas {
                id: indicatorManuf
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "manufacturer")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorManuf.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Item { // RSSI column header
            anchors.verticalCenter: parent.verticalCenter
            width: 180
            height: 24

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                IconSvg {
                    width: 16; height: 16;
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-signal_cellular_full-24px.svg"
                    color: Theme.colorSubText
                    opacity: 0.8
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("RSSI")
                    font.bold: (deviceManager.orderBy_role === "rssi")
                    color: Theme.colorText
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_rssi()
            }

            Canvas {
                id: indicatorRSSI
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "rssi")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorRSSI.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Item { // Adv interval header column
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: 24

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                IconSvg {
                    width: 16; height: 16;
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-arrow_left_right-24px.svg"
                    color: Theme.colorSubText
                    opacity: 0.8
                }

                Text {
                    text: qsTr("Interval")
                    font.bold: (deviceManager.orderBy_role === "interval")
                    color: Theme.colorText
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_interval()
            }

            Canvas {
                id: indicatorInterval
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "interval")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorInterval.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // last seen header column
            anchors.verticalCenter: parent.verticalCenter
            width: 120

            text: qsTr("Last seen")
            font.bold: (deviceManager.orderBy_role === "lastseen")
            color: Theme.colorText

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_lastseen()
            }

            Canvas {
                id: indicatorLastSeen
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "lastseen")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorLastSeen.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // first seen header column
            anchors.verticalCenter: parent.verticalCenter
            width: 120

            text: qsTr("First seen")
            font.bold: (deviceManager.orderBy_role === "firstseen")
            color: Theme.colorText

            MouseArea {
                anchors.fill: parent
                onClicked: deviceManager.orderby_firstseen()
            }

            Canvas {
                id: indicatorFirstSeen
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: deviceManager.orderBy_order ? 0 : 180
                visible: (deviceManager.orderBy_role === "firstseen")

                Connections {
                    target: ThemeEngine
                    function onCurrentThemeChanged() { indicatorFirstSeen.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = Theme.colorIcon
                    ctx.fill()
                }
            }
        }

        Item { // separator ////////////////////////////////////////////////////
            width: 16
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 2
        color: Qt.lighter(Theme.colorLVseparator, 1.06)
    }
}
