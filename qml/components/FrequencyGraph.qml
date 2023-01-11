import QtQuick
import QtCharts

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

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
        graphMax.color = Theme.colorGreen

        graphCurrent = frequencyGraph.createSeries(ChartView.SeriesTypeLine, "", axisFrequency, axisRSSI)
        graphCurrent.useOpenGL = useOpenGL
        graphCurrent.color = Theme.colorBlue
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
        graphMax.color = Theme.colorGreen
        ubertooth.getFrequencyGraphMax(graphMax)
        graphCurrent.color = Theme.colorBlue
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
        id: legend_area

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
        anchors.fill: legend_area

        enabled: false
        acceptedButtons: (Qt.LeftButton | Qt.RightButton)

        property var lastMouse1: null
        property var lastMouse2: null

        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (lastMouse1 && lastMouse1 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse1 = null
                    h1.visible = false
                    v1.visible = false
                } else {
                    lastMouse1 = Qt.point(mouse.x, mouse.y)
                    lastMouse2 = null
                    moveIndicator(mouse, 1)
                }
            } else if (mouse.button === Qt.RightButton) {
                if (lastMouse2 && lastMouse2 === Qt.point(mouse.x, mouse.y)) {
                    lastMouse2 = null
                    h2.visible = false
                    v2.visible = false
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

        Rectangle {
            id: h1
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            visible: false
            color: Theme.colorYellow
        }
        Rectangle {
            id: v1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            visible: false
            color: Theme.colorYellow
        }

        Rectangle {
            id: h2
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            visible: false
            color: Theme.colorOrange
        }
        Rectangle {
            id: v2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            visible: false
            color: Theme.colorOrange
        }
    }

    function hasIndicators() {
        return (h1.visible || h2.visible)
    }

    function moveIndicator(mouse, idx) {
        var mmm = Qt.point(mouse.x, mouse.y)

        if (idx === 1) {
            h1.visible = true
            v1.visible = true
            h1.y = mouse.y
            v1.x = mouse.x
        } else if (idx === 2) {
            h2.visible = true
            v2.visible = true
            h2.y = mouse.y
            v2.x = mouse.x
        }

        console.log("clicked " + mouse.x + " " + mouse.y)
        console.log("freq: " + UtilsNumber.mapNumber(mouse.x, 0, width, ubertooth.freqMin, ubertooth.freqMax))
        console.log("rssi: " + UtilsNumber.mapNumber(mouse.y, 0, height, -20, -100))
    }

    function resetIndicators() {
        h1.visible = false
        v1.visible = false
        h2.visible = false
        v2.visible = false
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
}
