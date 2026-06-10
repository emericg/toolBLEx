import QtQuick
import QtGraphs

import ComponentLibrary

GraphsView {
    id: frequencyGraph
    anchors.fill: parent

    clip: false
    antialiasing: false
    shadowVisible: false

    Connections {
        target: dataSource
        enabled: frequencyGraph.visible
        function onNewDataAvailable() { frequencyGraph.updateGraph() }
    }

    property var dataSource

    property var graphMax
    property var graphAverage
    property var graphCurrent
    property var graphsHistory: []

    property int historyCurvesCount: SettingsManager.spectrogram_historyCurves

    ////////////////////////////////////////////////////////////////////////////

    signal plotAreaUpdated(var x, var y, var width, var height)

    //onPlotAreaChanged: frequencyGraph.updatePlotArea() // Not compatible with Qt 6.8 :/
    onWidthChanged:  Qt.callLater(updatePlotArea) // Qt 6.8 hack
    onHeightChanged: Qt.callLater(updatePlotArea) // Qt 6.8 hack

    Component.onCompleted: {
        //// AXIS
        dataSource.getFrequencyGraphAxis(axisFrequency)

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

    function hideHistory() {
        for (var idx = 0; idx < graphsHistory.length; idx++) {
            if (graphsHistory[idx]) graphsHistory[idx].visible = false
        }
    }

    function updateGraph() {
        //if (!dataSource.running || appContent.state !== "Ubertooth") return
        //if (!dataSource.running || appContent.state !== "Ubertooth") return
        //console.log("frequencyGraph // updateGraph()")

        //// AXIS
        dataSource.getFrequencyGraphAxis(axisFrequency)

        //// DATA HISTORY
        if (spectrumGraph2D_container.graphHistoryMethod === 1) {

            // method 2 // (history curves with opacity gradient)
            for (var idx = 0; idx < frequencyGraph.historyCurvesCount; idx++) {
                if (!graphsHistory[idx]) {
                    graphsHistory[idx] = createLineSeries()
                    graphsHistory[idx].width = 1
                }
                if (graphsHistory[idx]) {
                    graphsHistory[idx].visible = true
                    graphsHistory[idx].color = Theme.colorSubText
                    graphsHistory[idx].opacity = UtilsNumber.mapNumber(idx,
                                                                       0, frequencyGraph.historyCurvesCount,
                                                                       500, 10) / 1000
                    dataSource.getFrequencyGraphData(graphsHistory[idx], idx)
                }
            }

        } else {

            // method 3 // (hide history curves, the phospor persistence graph will be used)
            hideHistory()

        }

        //// DATA
        dataSource.getFrequencyGraphMax(graphMax)
        dataSource.getFrequencyGraphAverage(graphAverage)
        dataSource.getFrequencyGraphCurrent(graphCurrent)
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

        min: actionBar.minRSSI
        max: actionBar.maxRSSI
        tickInterval: 20

        labelsVisible: true
        labelDecimals: 0

        gridVisible: true
        subGridVisible: false
    }

    axisX: ValueAxis {
        id: axisFrequency
        visible: true

        min: dataSource.freqMin / (dataSource.freqUnit ? 1000 : 1)
        max: dataSource.freqMax / (dataSource.freqUnit ? 1000 : 1)

        labelsVisible: true
        labelDecimals: (dataSource.freqUnit ? 1 : 0)

        gridVisible: true
        subGridVisible: true
        subTickCount: 9
    }

    ////////////////////////////////////////////////////////////////////////////
}
