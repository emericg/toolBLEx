import QtQuick
import QtCharts

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

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

    property bool useOpenGL: false
    property color legendColor: Theme.colorSubText

    property var graphMax
    property var graphCurrent

    property var graphs: []
    property int graphs_idx: 0

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

        //// DATA
        var graphCount = 64
        for (var graphs_idx = 0; graphs_idx < graphCount; graphs_idx++) {
            if (!graphs[graphs_idx]) {
                //console.log("graph " + graphs_idx + " is being created")
                graphs[graphs_idx] = frequencyGraph.createSeries(ChartView.SeriesTypeLine, "", axisFrequency, axisRSSI)
                graphs[graphs_idx].useOpenGL = useOpenGL
                graphs[graphs_idx].width = 1
            }
            if (graphs[graphs_idx]) {
                //console.log("graph " + graphs_idx + " is being updated")
                graphs[graphs_idx].color = Theme.colorText
                graphs[graphs_idx].opacity = UtilsNumber.mapNumber(graphs_idx*100, 0, graphCount*10, 500, 0) / 1000
                ubertooth.getFrequencyGraphData(graphs[graphs_idx], graphs_idx)
            }
        }

        //// DATA
        graphMax.color = Theme.colorGreen
        ubertooth.getFrequencyGraphMax(graphMax)
        graphCurrent.color = Theme.colorBlue
        ubertooth.getFrequencyGraphCurrent(graphCurrent)
    }

    Timer {
        interval: 100
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
