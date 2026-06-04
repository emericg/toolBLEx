import QtQuick
import QtGraphs

import ComponentLibrary

Item {
    id: spectrumGraph2D_container

    clip: false

    anchors.top: actionBar.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    visible: (actionBar.viewMode === 0)

    // Spectrum history style: 0 = phosphor accumulation buffer, 1 = history lines (only one at a time, to reduce clutter)
    property int graphHistoryMethod: 0

    property bool showPeak: false

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: frequencyGraphUnderlay

        clip: true

        ////////

        PhosphorPersistenceGraph {
            id: phosphorPersistenceGraph
            anchors.fill: parent

            traceColor: Theme.colorSubText
            visible: (spectrumGraph2D_container.graphHistoryMethod === 0)
        }

        ////////

        FrequencyGraphOverlayBands {
            id: frequencyBands
            anchors.fill: parent
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    FrequencyGraph {
        id: frequencyGraph
        anchors.fill: parent

        anchors.topMargin: -20
        anchors.leftMargin: -28
        anchors.rightMargin: -20
        anchors.bottomMargin: -28

        onPlotAreaUpdated: (x, y, width, height) => {
            //console.log("onPlotAreaUpdated")
            //console.log("- plotArea x      " + frequencyGraph.plotArea.x)
            //console.log("- plotArea y      " + frequencyGraph.plotArea.y)
            //console.log("- plotArea width  " + frequencyGraph.plotArea.width)
            //console.log("- plotArea height " + frequencyGraph.plotArea.height)

            frequencyGraphUnderlay.x = x
            frequencyGraphUnderlay.y = y
            frequencyGraphUnderlay.width = width
            frequencyGraphUnderlay.height = height

            frequencyGraphOverlay.x = x
            frequencyGraphOverlay.y = y
            frequencyGraphOverlay.width = width
            frequencyGraphOverlay.height = height
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        id: frequencyGraphOverlay

        clip: true

        ////////

        FrequencyGraphOverlayClickable {
            id: overlayClickable
            anchors.fill: parent
        }

        ////////

        FrequencyGraphLegend {
            id: overlayLegend
            anchors.fill: parent
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
