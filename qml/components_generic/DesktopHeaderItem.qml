import QtQuick 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 64
    implicitHeight: 64

    width: Math.max(parent.height, content.width + 32)
    height: parent.height

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool selected: false

    // settings
    property url source
    property int sourceSize: 32
    property string text
    property string highlightMode: "background" // available: background, indicator, content

    // colors
    property string colorContent: Theme.colorHeaderContent
    property string colorHighlight: Theme.colorHeaderHighlight

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()

        Rectangle { // bgRect
            anchors.fill: parent

            visible: (control.selected && control.highlightMode === "background")
            color: control.colorHighlight
        }

        Rectangle { // bgFocus
            anchors.fill: parent

            visible: (highlightMode === "background")
            color: control.colorHighlight
            opacity: parent.containsMouse ? 0.5 : 0
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }

        Rectangle { //  indicator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 4
            visible: (control.selected && highlightMode === "indicator")
            color: Theme.colorPrimary
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        IconSvg {
            id: contentImage
            width: control.sourceSize
            height: control.sourceSize

            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            visible: source.toString().length

            source: control.source
            color: (!control.selected && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            opacity: control.enabled ? 1.0 : 0.33
        }

        Text {
            id: contentText
            height: parent.height

            visible: text

            text: control.text
            textFormat: Text.PlainText
            color: (!control.selected && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            font.pixelSize: Theme.fontSizeComponent
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
