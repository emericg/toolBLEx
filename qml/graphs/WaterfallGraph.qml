import QtQuick

import ComponentLibrary

WaterfallGraph_QuickItem {
    id: waterfallGraph

    dataSource: ubertooth
    maxDepth: 512

    floorDb: actionBar.minRSSI
    ceilDb: actionBar.maxRSSI
    smooth: false

    Connections {
        target: ubertooth
        enabled: waterfallGraph.visible
        function onNewDataAvailable() { waterfallGraph.refresh() }
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
