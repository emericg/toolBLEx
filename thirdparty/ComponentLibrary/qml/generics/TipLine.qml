import QtQuick
import QtQuick.Layouts
import ComponentLibrary

Item {
    id: control

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ////

    property bool background: true

    property string text
    property int textSize: Theme.fontSizeContent

    property color colorBackground: Theme.colorBackground
    property color colorText: Theme.colorSubText
    property color color: Theme.colorGreen

    ////

    Rectangle { // background
        anchors.fill: parent
        anchors.margins: -4
        radius: 2

        visible: control.background
        color: control.colorBackground
        opacity: 0.88
    }

    ////

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 8

        Rectangle { // indicator
            Layout.fillHeight: true
            Layout.preferredWidth: 4
            color: control.color
        }

        Text {
            Layout.fillWidth: true

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: control.textSize
            wrapMode: Text.WordWrap
            color: control.colorText
        }
    }

    ////
}
