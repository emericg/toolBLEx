import QtQuick
import QtGraphs

import ComponentLibrary

GraphsView {
    id: rssiGraph

    clip: false
    antialiasing: false
    shadowVisible: false

    theme: GraphsTheme {
        backgroundColor: Theme.colorBackground
        backgroundVisible: true
        plotAreaBackgroundColor: Theme.colorBackground
        plotAreaBackgroundVisible: true
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

    axisX: DateTimeAxis {
        id: axisTime
        visible: true

        labelsVisible: true
        labelFormat: "mm:ss"

        gridVisible: true
        subGridVisible: false
    }

    ////////////////////////////////////////////////////////////////////////////

    property var graphs: []

    function createLineSeries() {
        var s = Qt.createQmlObject('import QtGraphs; LineSeries {}', rssiGraph)
        rssiGraph.addSeries(s)
        return s
    }

    Component.onCompleted: {
        deviceManager.getRssiGraphAxis(axisTime)
        graphs[0] = createLineSeries()
    }

    function updateGraph() {
        if (!rssiGraph.visible) return
        if (!deviceManager.scanning || deviceManager.scanningPaused || hostMenu.currentSelection !== 3) return
        //console.log("rssiGraph // updateGraph()")

        //// AXIS
        deviceManager.getRssiGraphAxis(axisTime)

        //// DATA
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (!graphs[i]) {
                //console.log("graph " + i + " is being created")
                graphs[i] = createLineSeries()
            }
            if (graphs[i]) {
                //console.log("graph " + i + " is being updated")
                deviceManager.getRssiGraphData(graphs[i], i)
            }
        }
    }

    Timer {
        interval: SettingsManager.scanRssiInterval
        running: (deviceManager.scanning && !deviceManager.scanningPaused && hostMenu.currentSelection === 3)
        repeat: true
        onTriggered: updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////
}
