import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: control
    implicitWidth: 80
    implicitHeight: 28
    width: contentRow.width + 20

    radius: Theme.componentRadius
    color: backgroundColor

    property string text: "TAG"
    property string textColor: "white"
    property int textSize: Theme.fontSizeComponent

    property url source: "qrc:/assets/icons_material/baseline-add-24px.svg"
    property string sourceColor: "white"
    property int sourceSize: 20

    property string backgroundColor: Theme.colorPrimary

    signal clicked()

    Row {
        id: contentRow
        anchors.centerIn: parent
        height: control.height

        Text {
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            text: control.text
            textFormat: Text.PlainText
            color: control.textColor
            elide: Text.ElideMiddle
            font.capitalization: Font.AllUppercase
            font.pixelSize: Theme.fontSizeComponent
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 20

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 6
                width: 2
                color: control.textColor
                opacity: 0.5
            }
        }

        IconSvg {
            anchors.verticalCenter: parent.verticalCenter
            source: control.source
            width: control.sourceSize
            color: control.sourceColor
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: control.clicked()
    }
}
