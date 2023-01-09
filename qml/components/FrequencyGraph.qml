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
