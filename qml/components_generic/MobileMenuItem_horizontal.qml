import QtQuick 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 48
    implicitHeight: 48

    width: Math.max(parent.height, content.width + 24)
    height: parent.height

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool selected: false

    // settings
    property string text
    property url source
    property int sourceSize: 24

    // colors
    property string colorContent: Theme.colorTabletmenuContent
    property string colorHighlight: Theme.colorTabletmenuHighlight

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()
    }

    ////////////////////////////////////////////////////////////////////////////

    RowLayout {
        id: content
        anchors.centerIn: control
        spacing: isPhone ? 6 : 12

        IconSvg { // contentImage
            width: control.sourceSize
            height: control.sourceSize
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize
            visible: source.toString().length

            source: control.source
            opacity: control.enabled ? 1.0 : 0.33
            color: control.selected ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 133 } }
        }

        Text { // contentText
            height: control.height
            Layout.alignment: Qt.AlignVCenter
            visible: text

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: Theme.componentFontSize
            font.bold: true
            color: control.selected ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 133 } }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
