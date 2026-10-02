import QtQuick
import QtGraphs

import ComponentLibrary

/*!
 * Scatter timeline of the received advertisement packets of a device.
 * One point per packet, x is the packet age, y its RSSI.
 * Points are colored by payload content (manufacturer data, service data, both, or neither).
 */
GraphsView {
    id: advTimelineGraph

    property var device: null
    property int timeWindow: 60 // seconds

    clip: false
    antialiasing: false
    shadowVisible: false

    marginTop: 0
    marginBottom: -16
    marginLeft: -16
    marginRight: 0

    theme: GraphsTheme {
        backgroundColor: Theme.colorBox
        backgroundVisible: true
        plotAreaBackgroundColor: Theme.colorBox
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
        min: -100
        max: -20
        tickInterval: 20

        labelsVisible: true
        labelDecimals: 0

        gridVisible: true
        subGridVisible: false
    }

    axisX: ValueAxis {
        min: -advTimelineGraph.timeWindow
        max: 0
        tickInterval: (advTimelineGraph.timeWindow > 60) ? 20 : 10

        labelsVisible: true
        labelDecimals: 0
        labelDelegate: GraphAxisLabelAge { }

        gridVisible: true
        subGridVisible: false
    }

    property Component pointMarker: Rectangle {
        property color pointColor
        width: 6; height: 6; radius: 3
        antialiasing: true
        color: pointColor
    }

    ScatterSeries { id: seriesNone; color: Theme.colorPrimary; pointDelegate: advTimelineGraph.pointMarker }
    ScatterSeries { id: seriesMfd; color: Theme.colorBlue; pointDelegate: advTimelineGraph.pointMarker }
    ScatterSeries { id: seriesSvd; color: Theme.colorGreen; pointDelegate: advTimelineGraph.pointMarker }
    ScatterSeries { id: seriesBoth; color: Theme.colorOrange; pointDelegate: advTimelineGraph.pointMarker }

    ////////////////////////////////////////////////////////////////////////////

    function updateGraph() {
        if (!advTimelineGraph.visible) return

        if (!advTimelineGraph.device) {
            seriesNone.clear(); seriesMfd.clear(); seriesSvd.clear(); seriesBoth.clear()
            return
        }

        advTimelineGraph.device.getAdvTimelineData(seriesNone, seriesMfd, seriesSvd, seriesBoth,
                                                   Date.now(), advTimelineGraph.timeWindow * 1000)
    }

    onDeviceChanged: updateGraph()
    onVisibleChanged: updateGraph()
    onTimeWindowChanged: updateGraph()
    Component.onCompleted: updateGraph()

    Timer {
        interval: SettingsManager.scanRssiInterval
        running: (advTimelineGraph.visible && deviceManager.scanning && !deviceManager.scanningPaused)
        repeat: true
        onTriggered: advTimelineGraph.updateGraph()
    }

    ////////////////////////////////////////////////////////////////////////////
}
