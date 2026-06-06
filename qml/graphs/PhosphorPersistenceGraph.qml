import QtQuick

import ComponentLibrary

PhosphorPersistenceGraph_QuickItem {
    id: phosphorPersistenceGraph

    dataSource: ubertooth

    floorDb: actionBar.minRSSI
    ceilDb: actionBar.maxRSSI
    decay: 24 // 1..255, higher = shorter persistence trails

    Connections {
        target: ubertooth
        enabled: visible
        function onNewDataAvailable() { if (phosphorPersistenceGraph.visible) phosphorPersistenceGraph.refresh() }
        function onRunningChanged() { if (!ubertooth.running) phosphorPersistenceGraph.clear() }
        function onFreqChanged() { phosphorPersistenceGraph.clear() }
    }
}
