import QtQuick

import ComponentLibrary

WaterfallGraph_QuickItem {
    id: waterfallGraph
    //anchors.fill: parent

    dataSource: ubertooth
    floorDb: -100
    ceilDb: -20
    smooth: false

    property int graphInterval: (1000 / SettingsManager.ubertooth_samplingFreq)

    Timer {
        repeat: true
        running: ubertooth.running && waterfallGraph.visible
        interval: waterfallGraph.graphInterval
        onTriggered: waterfallGraph.refresh()
    }

    ////////////////

    WaterfallGraphLabels {
        anchors.fill: parent
    }

    ////////////////

    WaterfallGraphOverlayBands {
        anchors.fill: parent
    }

    ////////////////
}
