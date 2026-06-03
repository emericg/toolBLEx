import QtQuick
import QtGraphs

import ComponentLibrary

GraphsView {
    id: frequencyGraph
    anchors.fill: parent

    clip: false
    antialiasing: false
    shadowVisible: false

    property int graphCount: SettingsManager.ubertooth_historyCurves
    property int graphInterval: (1000 / SettingsManager.ubertooth_samplingFreq)

    Timer {
        repeat: true
        running: ubertooth.running && frequencyGraph.visible
        interval: frequencyGraph.graphInterval
        onTriggered: frequencyGraph.updateGraph()
    }

    property var graphMax
    property var graphAverage
    property var graphCurrent
    property var graphsHistory: []

    ////////////////////////////////////////////////////////////////////////////

    signal plotAreaUpdated(var x, var y, var width, var height)

    //onPlotAreaChanged: frequencyGraph.updatePlotArea() // Not compatible with Qt 6.8 :/
    onWidthChanged:  Qt.callLater(updatePlotArea) // Qt 6.8 hack
    onHeightChanged: Qt.callLater(updatePlotArea) // Qt 6.8 hack

    Component.onCompleted: {
        //// AXIS
        ubertooth.getFrequencyGraphAxis(axisFrequency)

        graphMax = createLineSeries()
        graphMax.color = Theme.colorMaterialLightGreen
        graphMax.opacity = 0.66

        graphAverage = createLineSeries()
        graphAverage.color = Theme.colorMaterialOrange
        graphAverage.opacity = 0.66

        graphCurrent = createLineSeries()
        graphCurrent.color = Theme.colorMaterialLightBlue

        // plotArea is a zero-rect during construction
        // give it just a bit of time before sending dimensions...
        Qt.callLater(frequencyGraph.updatePlotArea)
    }

    function createLineSeries() {
        var s = Qt.createQmlObject('import QtGraphs; LineSeries {}', frequencyGraph)
        frequencyGraph.addSeries(s)
        return s
    }

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

        //// DATA HISTORY

            // method 2 // with color gradient
            for (var idx = 0; idx < frequencyGraph.graphCount; idx++) {
                if (!graphsHistory[idx]) {
                    graphsHistory[idx] = createLineSeries()
                    graphsHistory[idx].width = 1
                }
                if (graphsHistory[idx]) {
                    graphsHistory[idx].visible = true
                    graphsHistory[idx].color = Theme.colorSubText
                    graphsHistory[idx].opacity = UtilsNumber.mapNumber(idx, 0, frequencyGraph.graphCount, 500, 10) / 1000
                    ubertooth.getFrequencyGraphData(graphsHistory[idx], idx)
                }
            }

        //// DATA
        ubertooth.getFrequencyGraphMax(graphMax)
        ubertooth.getFrequencyGraphAverage(graphAverage)
        ubertooth.getFrequencyGraphCurrent(graphCurrent)
    }

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
}
