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

    axisX: ValueAxis {
        id: axisTime
        visible: true

        min: -60
        max: 0
        tickInterval: 10

        labelsVisible: true
        labelDecimals: 0
        labelDelegate: GraphAxisLabelAge { }

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
        graphs[0] = createLineSeries()
    }

    function updateGraph() {
        if (!rssiGraph.visible) return
        if (!DeviceManager.scanning || DeviceManager.scanningPaused || hostMenu.currentIndex !== 2) return
        //console.log("rssiGraph // updateGraph()")

        //// DATA
        var now = Date.now()
        for (var i = 0; i < DeviceManager.deviceCount; i++) {
            if (!graphs[i]) {
                //console.log("graph " + i + " is being created")
                graphs[i] = createLineSeries()
            }
            if (graphs[i]) {
                //console.log("graph " + i + " is being updated")
                DeviceManager.getRssiGraphData(graphs[i], i, now, -axisTime.min * 1000)
            }
        }
    }

    Timer {
        interval: SettingsManager.scanRssiInterval
        running: (DeviceManager.scanning && !DeviceManager.scanningPaused && hostMenu.currentIndex === 2)
        repeat: true
        onTriggered: updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////
}
