import QtQuick

import ComponentLibrary

WaterfallGraph_QuickItem {
    id: waterfallGraph

    dataSource: ubertooth
    maxDepth: 512

    floorDb: -100
    ceilDb: -20
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
