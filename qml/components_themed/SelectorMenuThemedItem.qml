import QtQuick 2.15

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 16 + contentText.width + (source.toString().length ? sourceSize : 0) + 16
    implicitHeight: 32

    height: parent.height

    // actions
    signal clicked()
    signal pressAndHold()

    // states
    property bool hovered: false
    property bool pressed: false
    property bool selected: false

    // settings
    property int index
    property string text
    property url source
    property int sourceSize: 32

    // colors
    property string colorContent: Theme.colorComponentText
    property string colorContentHighlight: Theme.colorComponentContent
    property string colorBackgroundHighlight: Theme.colorComponentDown

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: control
        hoverEnabled: (isDesktop && control.enabled)

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onEntered: control.hovered = true
        onExited: control.hovered = false
        onCanceled: control.hovered = false
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: control
        anchors.margins: 0

        color: control.colorBackgroundHighlight
        opacity: {
            if (control.hovered && control.selected)
                return 0.9
            else if (control.selected)
                return 0.7
            else if (control.hovered)
                return 0.5
            else
                return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    IconSvg {
        id: contentImage
        width: control.sourceSize
        height: control.sourceSize
        anchors.centerIn: control

        source: control.source
        color: control.selected ? control.colorContentHighlight : control.colorContent
        opacity: control.selected ? 1 : 0.5
    }

    Text {
        id: contentText
        anchors.centerIn: control

        text: control.text
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeComponent
        verticalAlignment: Text.AlignVCenter

        color: control.selected ? control.colorContentHighlight : control.colorContent
        opacity: control.selected ? 1 : 0.6
    }

    ////////////////////////////////////////////////////////////////////////////
}
