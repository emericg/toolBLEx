import QtQuick
import QtCharts

import ComponentLibrary

ChartView {
    id: frequencyGraph
    anchors.margins: -16

    legend.visible: false

    backgroundColor: "transparent"
    backgroundRoundness: 0

    clip: false
    antialiasing: true
    dropShadowEnabled: false
    animationOptions: ChartView.NoAnimation

    ////////////////////////////////////////////////////////////////////////////

    property bool useOpenGL: false
    property color legendColor: Theme.colorSubText

    property int graphCount: 32
    property int graphInterval: 120

    property var graphMax
    property var graphCurrent
    property var graphs: []
    property int graphs_idx: 0

    property bool needforspeed: (ubertooth.freqMax - ubertooth.freqMin > 100)

    Component.onCompleted: {
        //// AXIS
        ubertooth.getFrequencyGraphAxis(axisFrequency)

        graphMax = frequencyGraph.createSeries(ChartView.SeriesTypeLine, "", axisFrequency, axisRSSI)
        graphMax.useOpenGL = useOpenGL
        graphMax.color = Theme.colorMaterialLightGreen
        graphMax.opacity = 0.66

        graphCurrent = frequencyGraph.createSeries(ChartView.SeriesTypeLine, "", axisFrequency, axisRSSI)
        graphCurrent.useOpenGL = useOpenGL
        graphCurrent.color = Theme.colorMaterialLightBlue
    }

    function updateGraph() {
        if (!ubertooth.running || appContent.state !== "Ubertooth") return
        //console.log("frequencyGraph // updateGraph()")

        //// AXIS
        ubertooth.getFrequencyGraphAxis(axisFrequency)

        //// DATA
        if (needforspeed) {
            // method 1 // yolo
            if (!graphs[graphs_idx]) {
                //console.log("graph " + graphs_idx + " is being created")
                graphs[graphs_idx] = frequencyGraph.createSeries(ChartView.SeriesTypeLine, "", axisFrequency, axisRSSI)
                graphs[graphs_idx].useOpenGL = useOpenGL
                graphs[graphs_idx].color = Theme.colorText
                graphs[graphs_idx].opacity = 0.1
                graphs[graphs_idx].width = 1
            }
            if (graphs[graphs_idx]) {
                //console.log("graph " + graphs_idx + " is being updated")
                ubertooth.getFrequencyGraphData(graphs[graphs_idx], 1)
            }
            graphs_idx++
            if (graphs_idx > graphCount) graphs_idx = 0
        } else {
            // method 2 // with color gradient
            for (var idx = 0; idx < frequencyGraph.graphCount; idx++) {
                if (!graphs[idx]) {
                    //console.log("graph " + idx + " is being created")
                    graphs[idx] = frequencyGraph.createSeries(ChartView.SeriesTypeLine, "", axisFrequency, axisRSSI)
                    graphs[idx].useOpenGL = useOpenGL
                    graphs[idx].width = 1
                }
                if (graphs[idx]) {
                    //console.log("graph " + idx + " is being updated")
                    graphs[idx].color = Theme.colorSubText
                    graphs[idx].opacity = UtilsNumber.mapNumber(idx, 0, frequencyGraph.graphCount, 400, 100) / 1000
                    ubertooth.getFrequencyGraphData(graphs[idx], idx)
                }
            }
        }

        //// DATA
        ubertooth.getFrequencyGraphMax(graphMax)
        ubertooth.getFrequencyGraphCurrent(graphCurrent)
    }

    Timer {
        interval: frequencyGraph.graphInterval
        running: ubertooth.running
        repeat: true
        onTriggered: updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: legend_area_under

        width: parent.plotArea.width
        height: parent.plotArea.height
        x: parent.plotArea.x
        y: parent.plotArea.y
        z: -1

        clip: true

        FrequencyGraphLegend {
            id: legend24
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: clickableGraphArea
        anchors.fill: legend_area_under

        //enabled: ubertooth.running
        acceptedButtons: (Qt.LeftButton | Qt.RightButton)

        property var lastMouse1: null
        property var lastMouse2: null

        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (lastMouse1 && lastMouse1 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse1 = null
                    group1.visible = false
                } else {
                    lastMouse1 = Qt.point(mouse.x, mouse.y)
                    lastMouse2 = null
                    moveIndicator(mouse, 1)
                }
            } else if (mouse.button === Qt.RightButton) {
                if (lastMouse2 && lastMouse2 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse2 = null
                    group2.visible = false
                } else {
                    lastMouse1 = null
                    lastMouse2 = Qt.point(mouse.x, mouse.y)
                    moveIndicator(mouse, 2)
                }
            }
        }
        onPositionChanged: (mouse) => {
           if (lastMouse1) {
               moveIndicator(mouse, 1)
            } else if (lastMouse2) {
               moveIndicator(mouse, 2)
            }
        }

        ////

        Item {
            id: group1
            anchors.fill: parent
            visible: false

            Rectangle {
                id: h1
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.colorYellow
            }
            Rectangle {
                id: v1
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2
                color: Theme.colorYellow
            }

            Column {
                anchors.left: v1.right
                anchors.leftMargin: 8
                anchors.bottom: h1.top
                anchors.bottomMargin: 8

                Text {
                    id: lfreq1
                    text: "freq: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorYellow
                }
                Text {
                    id: lrssi1
                    text: "rssi: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorYellow
                }
            }
        }

        ////

        Item {
            id: group2
            anchors.fill: parent
            visible: false

            Rectangle {
                id: h2
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.colorOrange
            }
            Rectangle {
                id: v2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2
                color: Theme.colorOrange
            }

            Column {
                anchors.left: v2.right
                anchors.leftMargin: 8
                anchors.bottom: h2.top
                anchors.bottomMargin: 8

                Text {
                    id: lfreq2
                    text: "freq: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorOrange
                }
                Text {
                    id: lrssi2
                    text: "rssi: "
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.componentFontSize
                    color: Theme.colorOrange
                }
            }
        }

        ////
    }

    function hasIndicators() {
        return (group1.visible || group2.visible)
    }

    function moveIndicator(mouse, idx) {
        var mmm = Qt.point(mouse.x, mouse.y)

        var freqtxt = UtilsNumber.mapNumber(mouse.x, 0, legend_area_under.width, ubertooth.freqMin, ubertooth.freqMax).toFixed(0)
        var rssitxt = UtilsNumber.mapNumber(mouse.y, 0, legend_area_under.height, -20, -100).toFixed(0)

        if (idx === 1) {
            group1.visible = true
            h1.y = mouse.y
            v1.x = mouse.x
            lfreq1.text = "freq: " + freqtxt + " MHz"
            lrssi1.text = "rssi: " + rssitxt + " dB"
        } else if (idx === 2) {
            group2.visible = true
            h2.y = mouse.y
            v2.x = mouse.x
            lfreq2.text = "freq: " + freqtxt + " MHz"
            lrssi2.text = "rssi: " + rssitxt + " dB"
        }

        //console.log("clicked " + mouse.x + " " + mouse.y)
        //console.log("freq: " + freqtxt)
        //console.log("rssi: " + rssitxt)
    }

    function resetIndicators() {
        group1.visible = false
        group2.visible = false
        lastMouse1 = null
        lastMouse2 = null
    }

    ////////////////////////////////////////////////////////////////////////////

    ValueAxis {
        id: axisRSSI
        visible: true

        min: -100
        max: -20
        tickInterval: 10

        color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorGrid
        minorGridLineColor: Theme.colorGrid
        labelsVisible: true
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
        labelFormat: "%i"
    }

    ValueAxis {
        id: axisFrequency
        visible: true

        color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorGrid
        minorGridLineColor: Theme.colorGrid
        labelsVisible: true
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
        labelFormat: "%i"

        minorTickCount: 9
        tickCount: 11
        tickType: ValueAxis.TicksFixed
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: legend_area_over
        anchors.fill: legend_area_under

        Row {
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            spacing: 12

            Row {
                spacing: 6
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 4
                    color: graphCurrent.color
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("current")
                    textFormat: Text.PlainText
                    color: graphCurrent.color
                }
            }

            Row {
                spacing: 6
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 4
                    color: graphMax.color
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("max")
                    textFormat: Text.PlainText
                    color: graphMax.color
                }
            }

            Row {
                spacing: 6
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 4
                    color: Theme.colorGrey
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("history")
                    textFormat: Text.PlainText
                    color: Theme.colorGrey
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
