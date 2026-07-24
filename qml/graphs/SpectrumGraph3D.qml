import QtQuick
import QtGraphs

import ComponentLibrary

Item {
    id: spectrumGraph3D_container

    ////////////////////////////////////////////////////////////////////////

    property int colorScheme: ColormapFactory.Inferno

    property var dataSource

    Connections {
        target: spectrumGraph3D_container.dataSource
        enabled: spectrumGraph3D_container.visible
        function onNewDataAvailable() { surfaceHandler.refresh(surfaceSeries) }
    }

    SpectrumGraph3D_SurfaceHandler {
        id: surfaceHandler

        dataSource: spectrumGraph3D_container.dataSource
        maxDepth: 320

        floorDb: actionBar.minRSSI

        timeSmoothing: 0    // box-blur radius along time (sweeps); 0 = raw
        freqSmoothing: 0    // box-blur radius along frequency (bins); 0 = raw
    }

    ////////////////////////////////////////////////////////////////////////

    Item { // RSSI legend
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24

        width: 64
        height: 256

        Rectangle {
            anchors.fill: parent

            border.width: 2
            border.color: Theme.colorComponentBorder

            rotation: 180
            gradient: ColormapFactory.getGradient(spectrumGraph3D_container.colorScheme,
                                                  actionBar.minRSSI, actionBar.maxRSSI)
        }

        Text {
            anchors.top: parent.top
            anchors.right: parent.left
            anchors.rightMargin: Theme.componentMarginXS

            text: actionBar.maxRSSI
            textFormat: Text.PlainText
            font.pixelSize: Theme.componentFontSize
            color: Theme.colorSubText
        }
        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.left
            anchors.rightMargin: Theme.componentMarginXS

            text: actionBar.minRSSI
            textFormat: Text.PlainText
            font.pixelSize: Theme.componentFontSize
            color: Theme.colorSubText
        }
    }

    ////////////////////////////////////////////////////////////////////////

    Surface3D {
        id: surfaceGraph

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 1.25 // make the graph appears a little higher

        // Graph box proportions: pin them explicitly instead of letting the data ranges ugly auto-scale work
        // horizontalAspectRatio = X:Z, so 1.0 = square area, < 1.0 = rectangular area
        // aspectRatio = X:Y, keeping the magnitude axis from getting too tall
        horizontalAspectRatio: 0.66
        aspectRatio: 5.0

        selectionMode: Graphs3D.SelectionFlag.Item

        cameraPreset: Graphs3D.CameraPreset.Left
        cameraTargetPosition: Qt.vector3d(0.0, 0.0, 0.0)
        cameraZoomLevel: 140

        ambientLightStrength: 1.0
        shadowQuality: Graphs3D.ShadowQuality.SoftHigh // Graphs3D.ShadowQuality.None

        theme: GraphsTheme {
            theme: GraphsTheme.Theme.UserDefined

            backgroundVisible: false
            backgroundColor: Theme.colorBackground

            plotAreaBackgroundVisible: false
            plotAreaBackgroundColor: Theme.colorBackground

            colorScheme: GraphsTheme.ColorScheme.Light
            colorStyle: GraphsTheme.ColorStyle.RangeGradient

            baseGradients: [ ColormapFactory.getGradient(spectrumGraph3D_container.colorScheme,
                                                         actionBar.minRSSI, actionBar.maxRSSI) ]

            gridVisible: true
            grid.mainColor: Theme.colorSubText
            grid.mainWidth: 2
            grid.subColor: Theme.colorGrid
            grid.subWidth: 2

            labelBackgroundColor: Theme.colorGrid
            labelBackgroundVisible: true
            labelBorderVisible: false
            labelTextColor: Theme.colorSubText
        }

        axisX: Value3DAxis {
            title: qsTr("Frequency (MHz)")
            titleVisible: true
            labelFormat: (dataSource.freqUnit ? "%.1f" : "%.0f")

            segmentCount: 8
        }
        axisY: Value3DAxis {
            title: qsTr("RSSI (dB)")
            titleVisible: true
            labelFormat: "%.0f"

            segmentCount : 4
            subSegmentCount : 2

            Component.onCompleted: {
                // set min before max to avoid a transient "max <= min" warning at init
                min = actionBar.minRSSI
                max = actionBar.maxRSSI
            }
        }
        axisZ: Value3DAxis {
            title: qsTr("Samples history")
            titleVisible: true
            labelFormat: "%.0f"

            segmentCount : 4
            subSegmentCount : 4
        }

        Surface3DSeries {
            id: surfaceSeries

            drawMode: Surface3DSeries.DrawSurface
            //shading: Surface3DSeries.Shading.Flat

            baseColor: Theme.colorPrimary
            itemLabelVisible: false
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
