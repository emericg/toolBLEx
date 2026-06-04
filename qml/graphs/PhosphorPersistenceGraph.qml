import QtQuick

import ComponentLibrary

PhosphorPersistenceGraph_QuickItem {
    id: phosphorPersistenceGraph

    dataSource: ubertooth

    floorDb: -100
    ceilDb: -20
    decay: 24       // 1..255, higher = shorter persistence trails

    Connections {
        target: ubertooth
        enabled: visible
        function onNewDataAvailable() { if (phosphorPersistenceGraph.visible) phosphorPersistenceGraph.refresh() }
        function onRunningChanged() { if (!ubertooth.running) phosphorPersistenceGraph.clear() }
        function onFreqChanged() { phosphorPersistenceGraph.clear() }
    }
}
