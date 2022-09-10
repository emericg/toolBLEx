import QtQuick
import QtCharts

import ThemeEngine 1.0

ChartView {
    id: frequencyGraph

    legend.visible: false

    backgroundColor: Theme.colorBackground
    backgroundRoundness: 0

    clip: false
    antialiasing: true
    dropShadowEnabled: false
    animationOptions: ChartView.NoAnimation

    ////////////////////////////////////////////////////////////////////////////

    property bool useOpenGL: true
    property color legendColor: Theme.colorSubText

    property var graphs: []

    Component.onCompleted: {
        ubertooth.getFrequencyGraphAxis(axisFrequency)
    }

    function updateGraph() {
        if (!ubertooth.running || appContent.state !== "Ubertooth") return
        console.log("frequencyGraph // updateGraph()")

        //// DATA       
        for (var i = 0; i < 1; i++) {
            if (!graphs[i]) {
                //console.log("graph " + i + " is being created")
                graphs[i] = frequencyGraph.createSeries(ChartView.SeriesTypeLine,
                                                        "", axisFrequency, axisRSSI)
                graphs[i].useOpenGL = useOpenGL
            }
            if (graphs[i]) {
                //console.log("graph " + i + " is being updated")
                ubertooth.getFrequencyGraphData(graphs[i], i);
            }
        }
    }

    Timer {
        interval: 60
        running: ubertooth.running
        repeat: true
        onTriggered: updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////

    ValueAxis {
        id: axisRSSI
        visible: true

        min: -100
        max: 0

        //color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorSeparator
        labelsVisible: true
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
    }

    ValueAxis {
        id: axisFrequency
        visible: true

        //color: legendColor
        gridVisible: true
        gridLineColor: Theme.colorSeparator
        labelsVisible: true
        labelsFont.pixelSize: Theme.fontSizeContentVerySmall
        labelsColor: legendColor
    }

    ////////////////////////////////////////////////////////////////////////////
}
