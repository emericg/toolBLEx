import QtQuick
import QtGraphs

import ComponentLibrary

GraphsView {
    id: frequencyGraph

    clip: false
    antialiasing: false
    shadowVisible: false

    signal plotAreaUpdated(var x, var y, var width, var height)

    ////////////////////////////////////////////////////////////////////////////

    theme: GraphsTheme {
        backgroundVisible: false
        plotAreaBackgroundVisible: false
        labelBackgroundVisible: false
        labelBorderVisible: false

        gridVisible: true
        grid.mainColor: Theme.colorGrid
        grid.subColor: Theme.colorGrid

        axisX.mainColor: Theme.colorAxis
        axisX.labelTextColor: Theme.colorSubText
        axisY.mainColor: Theme.colorAxis
        axisY.labelTextColor: Theme.colorSubText

        axisXLabelFont.pixelSize: Theme.fontSizeContentVerySmall
        axisYLabelFont.pixelSize: Theme.fontSizeContentVerySmall
    }

    axisY: ValueAxis {
        id: axisRSSI
        visible: true

        min: -100
        max: -20
        tickInterval: 20

        labelsVisible: true
        labelDecimals: 0

        gridVisible: true
        subGridVisible: false
    }

    axisX: ValueAxis {
        id: axisFrequency
        visible: true

        labelsVisible: true
        labelDecimals: 0

        gridVisible: true
        subGridVisible: true
        subTickCount: 9
    }

    ////////////////////////////////////////////////////////////////////////////

    property int graphCount: SettingsManager.ubertooth_historyCurves
    property int graphInterval: (1000 / SettingsManager.ubertooth_samplingFreq)

    property var graphMax
    property var graphCurrent
    property var graphs: []
    property int graphs_idx: 0

    property bool needforspeed: false // (ubertooth.freqMax - ubertooth.freqMin > 100)

    function createLineSeries() {
        var s = Qt.createQmlObject('import QtGraphs; LineSeries {}', frequencyGraph)
        frequencyGraph.addSeries(s)
        return s
    }

    Component.onCompleted: {
        //// AXIS
        ubertooth.getFrequencyGraphAxis(axisFrequency)

        graphMax = createLineSeries()
        graphMax.color = Theme.colorMaterialLightGreen
        graphMax.opacity = 0.66

        graphCurrent = createLineSeries()
        graphCurrent.color = Theme.colorMaterialLightBlue

        // plotArea is a zero-rect during construction
        // give it just a bit of time before sending dimensions...
        Qt.callLater(frequencyGraph.updatePlotArea)
    }

    //onPlotAreaChanged: frequencyGraph.updatePlotArea() // Not compatible with Qt 6.8 :/
    onWidthChanged:  Qt.callLater(updatePlotArea)
    onHeightChanged: Qt.callLater(updatePlotArea)

    function updatePlotArea() {
        if (typeof frequencyGraph.plotArea === 'undefined') {
            // Qt 6.8 hack // plotArea isn't avaible, so "best effort" to match it manually
            frequencyGraph.plotAreaUpdated(frequencyGraph.x + 80,
                                           frequencyGraph.y + 20,
                                           frequencyGraph.width - 100,
                                           frequencyGraph.height - 80)
        } else {
            // plotArea coords are relative to frequencyGraph, so offset by its position
            frequencyGraph.plotAreaUpdated(frequencyGraph.x + frequencyGraph.plotArea.x,
                                           frequencyGraph.y + frequencyGraph.plotArea.y,
                                           frequencyGraph.plotArea.width,
                                           frequencyGraph.plotArea.height)
        }
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
                graphs[graphs_idx] = createLineSeries()
                graphs[graphs_idx].color = Theme.colorText
                graphs[graphs_idx].opacity = 0.2
                graphs[graphs_idx].width = 1
            }
            if (graphs[graphs_idx]) {
                ubertooth.getFrequencyGraphData(graphs[graphs_idx], 1)
            }
            graphs_idx++
            if (graphs_idx > frequencyGraph.graphCount) graphs_idx = 0

        } else {

            // method 2 // with color gradient
            for (var idx = 0; idx < frequencyGraph.graphCount; idx++) {
                if (!graphs[idx]) {
                    graphs[idx] = createLineSeries()
                    graphs[idx].width = 1
                }
                if (graphs[idx]) {
                    graphs[idx].color = Theme.colorSubText
                    graphs[idx].opacity = UtilsNumber.mapNumber(idx, 0, frequencyGraph.graphCount, 333, 10) / 1000
                    ubertooth.getFrequencyGraphData(graphs[idx], idx)
                }
            }

        }

        //// DATA
        ubertooth.getFrequencyGraphMax(graphMax)
        ubertooth.getFrequencyGraphCurrent(graphCurrent)
    }

    Timer {
        repeat: true
        running: ubertooth.running
        interval: frequencyGraph.graphInterval
        onTriggered: frequencyGraph.updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////
}
