import QtQuick

import ComponentLibrary

Rectangle {
    id: deviceScannerListHeader

    implicitWidth: 800
    implicitHeight: 36

    width: DeviceManager.deviceHeader.width

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
        Component.onCompleted: DeviceManager.deviceHeader.colAddress = contentWidth
    }
    Text { // "seen" fields size reference
        visible: false
        text: "00/00 00:00"
        textFormat: Text.PlainText
        Component.onCompleted: DeviceManager.deviceHeader.colFirstSeen = contentWidth
    }

    ////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: DeviceManager.deviceHeader.margin
        anchors.right: parent.right
        anchors.rightMargin: DeviceManager.deviceHeader.margin
        anchors.verticalCenter: parent.verticalCenter

        Item { // color column header //////////////////////////////////////////
            width: DeviceManager.deviceHeader.colColor
            height: 24
        }

        Item { // separator
            width: DeviceManager.deviceHeader.spacing
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
            width: DeviceManager.deviceHeader.colAddress

            clip: true
            visible: showAddress

            text: qsTr("Address")
            textFormat: Text.PlainText
            color: Theme.colorText
            font.bold: (DeviceManager.orderBy_role === "address")
            elide: Text.ElideRight

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_address()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "address")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorAddress
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "address")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colAddress.x + DeviceManager.deviceHeader.minSize
                drag.maximumX: colAddress.x + 512

                onPositionChanged: {
                    var delta =  parent.x - (colAddress.x + colAddress.width)
                    if (delta != 0) DeviceManager.deviceHeader.colAddress = colAddress.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return Theme.colorPrimary
                        if (parent.containsMouse) return Theme.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Text { // name column header ///////////////////////////////////////////
            id: colName
            anchors.verticalCenter: parent.verticalCenter
            width: DeviceManager.deviceHeader.colName

            clip: true

            text: qsTr("Advertised name")
            textFormat: Text.PlainText
            color: Theme.colorText
            font.bold: (DeviceManager.orderBy_role === "name")
            elide: Text.ElideRight

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_name()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "name")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorName
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "name")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colName.x + DeviceManager.deviceHeader.minSize
                drag.maximumX: colName.x + 512

                onPositionChanged: {
                    var delta =  parent.x - (colName.x + colName.width)
                    if (delta != 0) DeviceManager.deviceHeader.colName = colName.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return Theme.colorPrimary
                        if (parent.containsMouse) return Theme.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Text { // manufacturer column header ///////////////////////////////////
            id: colManuf
            anchors.verticalCenter: parent.verticalCenter
            width: DeviceManager.deviceHeader.colManuf

            clip: true
            visible: showAddress

            text: qsTr("Manufacturer")
            textFormat: Text.PlainText
            font.bold: (DeviceManager.orderBy_role === "manufacturer")
            color: Theme.colorText
            elide: Text.ElideRight

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_manufacturer()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "manufacturer")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorManuf
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "manufacturer")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
            height: 24

            visible: showAddress
            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colManuf.x + DeviceManager.deviceHeader.minSize
                drag.maximumX: colManuf.x + 512

                onPositionChanged: {
                    var delta =  parent.x - (colManuf.x + colManuf.width)
                    if (delta != 0) DeviceManager.deviceHeader.colManuf = colManuf.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return Theme.colorPrimary
                        if (parent.containsMouse) return Theme.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Item { // RSSI column header ///////////////////////////////////////////
            id: colRssi
            anchors.verticalCenter: parent.verticalCenter
            width: DeviceManager.deviceHeader.colRssi
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
                    textFormat: Text.PlainText
                    font.bold: (DeviceManager.orderBy_role === "rssi")
                    color: Theme.colorText
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_rssi()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "rssi")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorRSSI
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "rssi")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colRssi.x + DeviceManager.deviceHeader.minSize
                drag.maximumX: colRssi.x + 256

                onPositionChanged: {
                    var delta =  parent.x - (colRssi.x + colRssi.width)
                    if (delta != 0) DeviceManager.deviceHeader.colRssi = colRssi.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return Theme.colorPrimary
                        if (parent.containsMouse) return Theme.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Item { // Adv interval header column ///////////////////////////////////
            id: colInterval
            anchors.verticalCenter: parent.verticalCenter
            width: DeviceManager.deviceHeader.colInterval
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
                    textFormat: Text.PlainText
                    font.bold: (DeviceManager.orderBy_role === "interval")
                    color: Theme.colorText
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_interval()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "interval")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorInterval
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "interval")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
            height: 24

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SplitHCursor

                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: colInterval.x + DeviceManager.deviceHeader.minSize
                drag.maximumX: colInterval.x + 256

                onPositionChanged: {
                    var delta =  parent.x - (colInterval.x + colInterval.width)
                    if (delta != 0) DeviceManager.deviceHeader.colInterval = colInterval.width + delta
                }

                Rectangle { // marker
                    anchors.centerIn: parent
                    width: 2; height: 18;
                    color: {
                        if (parent.containsPress || parent.drag.active) return Theme.colorPrimary
                        if (parent.containsMouse) return Theme.colorSecondary
                        return Theme.colorLVseparator
                    }
                }
            }
        }

        Text { // last seen header column //////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: DeviceManager.deviceHeader.colLastSeen

            text: qsTr("Last seen")
            textFormat: Text.PlainText
            font.bold: (DeviceManager.orderBy_role === "lastseen")
            color: Theme.colorText
            elide: Text.ElideRight

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_lastseen()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "lastseen")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorLastSeen
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "lastseen")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
            height: 24
            Rectangle {
                anchors.centerIn: parent
                width: 2; height: 18;
                color: Theme.colorLVseparator
            }
        }

        Text { // first seen header column /////////////////////////////////////
            anchors.verticalCenter: parent.verticalCenter
            width: DeviceManager.deviceHeader.colFirstSeen

            text: qsTr("First seen")
            textFormat: Text.PlainText
            font.bold: (DeviceManager.orderBy_role === "firstseen")
            color: Theme.colorText
            elide: Text.ElideRight

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        DeviceManager.orderby_firstseen()
                    } else if (mouse.button === Qt.RightButton) {
                        if (DeviceManager.orderBy_role === "firstseen")
                            DeviceManager.orderby_default()
                    }
                }
            }

            Canvas {
                id: indicatorFirstSeen
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 4
                rotation: DeviceManager.orderBy_order ? 0 : 180
                visible: (DeviceManager.orderBy_role === "firstseen")

                Connections {
                    target: Theme
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
            width: DeviceManager.deviceHeader.spacing
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
