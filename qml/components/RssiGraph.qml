import QtQuick
import QtCharts

import ThemeEngine 1.0

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

    property bool useOpenGL: true
    property bool showGraphDots: false
    property color legendColor: Theme.colorSubText

    property var graphs: []
/*
    Connections {
        target: deviceManager
        function onDevicesListUpdated() {
            //console.log("rssiGraph // onDevicesListUpdated()")

            for (var i = 0; i < deviceManager.deviceCount; i++) {
                if (graphs[i]) {
                    //console.log("graph " + i + " already exists")
                } else {
                    //console.log("graph " + i + " is being created")
                    graphs[i] = rssiGraph.createSeries(ChartView.SeriesTypeLine,
                                                       "", axisTime, axisRSSI);
                }
            }
        }
    }
*/
    function updateGraph() {
        if (!deviceManager.scanning || hostMenu.currentSelection !== 3) return
        //console.log("rssiGraph // updateGraph()")

        //// DATA
        deviceManager.getRssiGraphAxis(axisTime);

        for (var i = 0; i < deviceManager.deviceCount; i++) {
            if (!graphs[i]) {
                //console.log("graph " + i + " is being created")
                graphs[i] = rssiGraph.createSeries(ChartView.SeriesTypeLine,
                                                   "", axisTime, axisRSSI)
                graphs[i].useOpenGL = useOpenGL
                graphs[i].pointsVisible = showGraphDots
            }
            if (graphs[i]) {
                //console.log("graph " + i + " is being updated")
                deviceManager.getRssiGraphData(graphs[i], i);
            }
        }
    }

    Timer {
        interval: settingsManager.scanRssiInterval
        running: (deviceManager.scanning && hostMenu.currentSelection === 3)
        repeat: true
        onTriggered: updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////

    ValueAxis {
        id: axisRSSI
        visible: true

        min: -100
        max: -30

        //color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorSeparator
        labelsVisible: true
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
    }

    DateTimeAxis {
        id: axisTime
        visible: true

        //color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorSeparator
        labelsVisible: false
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
    }

    ////////////////////////////////////////////////////////////////////////////
}
