import QtQuick

import ComponentLibrary

Rectangle {
    id: deviceScannerListHeader

    implicitWidth: 800
    implicitHeight: 36

    width: deviceManager.deviceHeader.width

    color: Theme.colorLVheader
    z: 5

    property bool showAddress: (Qt.platform.os !== "osx")

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////

    Text { // address field size reference
        visible: false
        text: (Qt.platform.os === "osx") ?
                  "329562a2-d357-470a-862c-6f6b73397607" :
                  "00:11:22:33:44:55"
        textFormat: Text.PlainText
        font.family: fontMonospace
        Component.onCompleted: deviceManager.deviceHeader.colAddress = contentWidth
    }
    Text { // "seen" fields size reference
        visible: false
        text: "00/00 00:00"
        textFormat: Text.PlainText
        Component.onCompleted: deviceManager.deviceHeader.colFirstSeen = contentWidth
    }

    ////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: deviceManager.deviceHeader.margin
        anchors.right: parent.right
        anchors.rightMargin: deviceManager.deviceHeader.margin
        anchors.verticalCenter: parent.verticalCenter

        Item { // color column header //////////////////////////////////////////
            width: deviceManager.deviceHeader.colColor
            height: 24
        }

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24
            visible: showAddress
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // address column header ////////////////////////////////////////
            id: colAddress
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colAddress

            clip: true
            visible: showAddress
            text: qsTr("Address")
            color: Theme.colorText
            font.bold: (deviceManager.orderBy_role === "address")

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_address()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "address")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colAddress.x + deviceManager.deviceHeader.minSize
                drag.maximumX: colAddress.x + 512

                onPositionChanged: {
                    var delta =  parent.x - (colAddress.x + colAddress.width)
                    if (delta != 0) deviceManager.deviceHeader.colAddress = colAddress.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return ThemeEngine.colorPrimary
                        if (parent.containsMouse) return ThemeEngine.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Text { // name column header ///////////////////////////////////////////
            id: colName
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colName

            clip: true
            text: qsTr("Advertised name")
            color: Theme.colorText
            font.bold: (deviceManager.orderBy_role === "name")

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_name()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "name")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colName.x + deviceManager.deviceHeader.minSize
                drag.maximumX: colName.x + 512

                onPositionChanged: {
                    var delta =  parent.x - (colName.x + colName.width)
                    if (delta != 0) deviceManager.deviceHeader.colName = colName.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return ThemeEngine.colorPrimary
                        if (parent.containsMouse) return ThemeEngine.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Text { // manufacturer column header ///////////////////////////////////
            id: colManuf
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colManuf

            clip: true
            visible: showAddress
            text: qsTr("Manufacturer")
            font.bold: (deviceManager.orderBy_role === "manufacturer")
            color: Theme.colorText

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_manufacturer()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "manufacturer")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24

            visible: showAddress
            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colManuf.x + deviceManager.deviceHeader.minSize
                drag.maximumX: colManuf.x + 512

                onPositionChanged: {
                    var delta =  parent.x - (colManuf.x + colManuf.width)
                    if (delta != 0) deviceManager.deviceHeader.colManuf = colManuf.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return ThemeEngine.colorPrimary
                        if (parent.containsMouse) return ThemeEngine.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Item { // RSSI column header ///////////////////////////////////////////
            id: colRssi
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colRssi
            height: 24
            clip: true

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                IconSvg {
                    width: 14; height: 14;
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/IconLibrary/material-symbols/signal_cellular_4_bar.svg"
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
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_rssi()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "rssi")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colRssi.x + deviceManager.deviceHeader.minSize
                drag.maximumX: colRssi.x + 256

                onPositionChanged: {
                    var delta =  parent.x - (colRssi.x + colRssi.width)
                    if (delta != 0) deviceManager.deviceHeader.colRssi = colRssi.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return ThemeEngine.colorPrimary
                        if (parent.containsMouse) return ThemeEngine.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Item { // Adv interval header column ///////////////////////////////////
            id: colInterval
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colInterval
            height: 24
            clip: true

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                IconSvg {
                    width: 14; height: 14;
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/IconLibrary/material-symbols/arrow_range.svg"
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
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_interval()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "interval")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colInterval.x + deviceManager.deviceHeader.minSize
                drag.maximumX: colInterval.x + 256

                onPositionChanged: {
                    var delta =  parent.x - (colInterval.x + colInterval.width)
                    if (delta != 0) deviceManager.deviceHeader.colInterval = colInterval.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return ThemeEngine.colorPrimary
                        if (parent.containsMouse) return ThemeEngine.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Text { // last seen header column //////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colLastSeen

            text: qsTr("Last seen")
            font.bold: (deviceManager.orderBy_role === "lastseen")
            color: Theme.colorText

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_lastseen()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "lastseen")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // first seen header column /////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: deviceManager.deviceHeader.colFirstSeen

            text: qsTr("First seen")
            font.bold: (deviceManager.orderBy_role === "firstseen")
            color: Theme.colorText

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        deviceManager.orderby_firstseen()
                    } else if (mouse.button === Qt.RightButton) {
                        if (deviceManager.orderBy_role === "firstseen")
                            deviceManager.orderby_default()
                    }
                }
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

        Item { // separator
            width: deviceManager.deviceHeader.spacing
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }
    }

    ////////

    Rectangle { // bottom separator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 2
        color: Qt.lighter(Theme.colorLVseparator, 1.06)
    }

    ////////
}
