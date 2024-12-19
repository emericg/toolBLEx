import QtQuick
import QtCharts

import ComponentLibrary

ChartView {
    id: rssiGraph

    legend.visible: false

    backgroundColor: Theme.colorBackground
    backgroundRoundness: 0

    clip: false
    antialiasing: true
    dropShadowEnabled: false
    animationOptions: ChartView.NoAnimation

    ////////////////////////////////////////////////////////////////////////////

    property bool useOpenGL: false
    property color legendColor: Theme.colorSubText

    property var graphs: []

    Component.onCompleted: {
        deviceManager.getRssiGraphAxis(axisTime)

        graphs[0] = rssiGraph.createSeries(ChartView.SeriesTypeLine, "", axisTime, axisRSSI)
        graphs[0].useOpenGL = useOpenGL
    }

    function updateGraph() {
        if (!deviceManager.scanning || deviceManager.scanningPaused || hostMenu.currentSelection !== 3) return
        //console.log("rssiGraph // updateGraph()")

        //// AXIS
        deviceManager.getRssiGraphAxis(axisTime)

        //// DATA
        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (!graphs[i]) {
                //console.log("graph " + i + " is being created")
                graphs[i] = rssiGraph.createSeries(ChartView.SeriesTypeLine, "", axisTime, axisRSSI)
                graphs[i].useOpenGL = useOpenGL
            }
            if (graphs[i]) {
                //console.log("graph " + i + " is being updated")
                deviceManager.getRssiGraphData(graphs[i], i)
            }
        }
    }

    Timer {
        interval: settingsManager.scanRssiInterval
        running: (deviceManager.scanning && !deviceManager.scanningPaused && hostMenu.currentSelection === 3)
        repeat: true
        onTriggered: updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////

    ValueAxis {
        id: axisRSSI
        visible: true

        min: -100
        max: -20

        color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorGrid
        minorGridLineColor: Theme.colorGrid
        labelsVisible: true
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
        labelFormat: "%i"
    }

    DateTimeAxis {
        id: axisTime
        visible: true

        color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorGrid
        minorGridLineColor: Theme.colorGrid
        labelsVisible: false
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
    }

    ////////////////////////////////////////////////////////////////////////////
}
