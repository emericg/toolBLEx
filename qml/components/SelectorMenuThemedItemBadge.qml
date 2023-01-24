import QtQuick 2.15

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 16 + content.width + 16
    implicitHeight: 32

    height: parent.height

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // states
    property bool selected: false

    // settings
    property int index
    property string text
    property string textBadge
    property url source
    property int sourceSize: 32

    // colors
    property string colorContent: Theme.colorComponentText
    property string colorContentHighlight: Theme.colorComponentContent
    property string colorBackgroundHighlight: Theme.colorComponentDown

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mouseArea
        anchors.fill: control
        hoverEnabled: (isDesktop && control.enabled)

        onClicked: control.clicked()
        onPressed: control.pressed()
        onPressAndHold: control.pressAndHold()
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: control
        anchors.margins: 0 // Theme.componentBorderWidth
        radius: Theme.componentRadius

        color: control.colorBackgroundHighlight
        opacity: {
            if (mouseArea.containsMouse && control.selected)
                return 0.9
            else if (control.selected)
                return 0.7
            else if (mouseArea.containsMouse)
                return 0.5
            else
                return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 133 } }
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: content
        anchors.centerIn: control
        spacing: 8

        IconSvg {
            width: control.sourceSize
            height: control.sourceSize
            anchors.verticalCenter: parent.verticalCenter

            source: control.source
            color: control.selected ? control.colorContentHighlight : control.colorContent
            opacity: control.selected ? 1 : 0.5
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeComponent
            verticalAlignment: Text.AlignVCenter

            color: control.selected ? control.colorContentHighlight : control.colorContent
            opacity: control.selected ? 1 : 0.6
        }

        Rectangle {
            width: control.height*0.6
            height: width
            radius: width
            anchors.verticalCenter: parent.verticalCenter

            visible: control.textBadge
            color: Theme.colorPrimary
            opacity: control.selected ? 1 : 0.6

            Text {
                anchors.fill: parent

                text: control.textBadge
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContentVerySmall
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: control.selected ? control.colorContentHighlight : control.colorContent
                opacity: control.selected ? 0.7 : 0.7
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
