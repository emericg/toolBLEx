import QtQuick

import ComponentLibrary

Item {
    anchors.fill: parent

    // Graph legends

    Row {
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        spacing: 12

        Row {
            spacing: 6
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 4
                color: frequencyGraph.graphCurrent ? frequencyGraph.graphCurrent.color : "transparent"
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("current")
                textFormat: Text.PlainText
                color: frequencyGraph.graphCurrent ? frequencyGraph.graphCurrent.color : "transparent"
            }
        }

        Row {
            spacing: 6
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 4
                color: frequencyGraph.graphAverage ? frequencyGraph.graphAverage.color : "transparent"
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("average")
                textFormat: Text.PlainText
                color: frequencyGraph.graphAverage ? frequencyGraph.graphAverage.color : "transparent"
            }
        }

        Row {
            spacing: 6
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 4
                color: frequencyGraph.graphMax ? frequencyGraph.graphMax.color : "transparent"
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("max")
                textFormat: Text.PlainText
                color: frequencyGraph.graphMax ? frequencyGraph.graphMax.color : "transparent"
            }
        }

        Row {
            spacing: 6
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 4
                color: Theme.colorRed

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 2
                    color: Theme.colorBackground
                    visible: !spectrumGraph2D_container.showPeak
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("peak")
                textFormat: Text.PlainText
                color: Theme.colorRed
            }
        }

        Row {
            spacing: 6
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 4
                color: Theme.colorGrey
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("history")
                textFormat: Text.PlainText
                color: Theme.colorGrey
            }
        }
    }
}
