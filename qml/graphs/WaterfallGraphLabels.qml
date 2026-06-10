import QtQuick

import ComponentLibrary

Item {
    id: labels_area_over
    anchors.fill: parent

    // Frequency axis labels

    property int labelCount: 6

    property int freqMin: dataSource.freqMin / (dataSource.freqUnit ? 1000 : 1)
    property int freqMax: dataSource.freqMax / (dataSource.freqUnit ? 1000 : 1)

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Repeater {
            model: labelCount

            Item {
                width: 1
                height: waterfallGraph.height / labelCount

                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left

                    text: Math.round(UtilsNumber.mapNumber(index,
                                                           0, labels_area_over.labelCount,
                                                           labels_area_over.freqMax,
                                                           labels_area_over.freqMin)) + " MHz"
                    textFormat: Text.PlainText
                    font.pixelSize: Theme.fontSizeContentVerySmall
                    color: "white"
                }
            }
        }
    }
}
