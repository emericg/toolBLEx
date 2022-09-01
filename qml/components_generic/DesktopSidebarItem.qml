import QtQuick 2.15
import QtQuick.Layouts 1.15

import ThemeEngine 1.0

Item {
    id: control
    implicitWidth: 80
    implicitHeight: 64

    anchors.left: parent.left
    anchors.right: parent.right
    height: Math.max(implicitHeight, content.height + 24)

    // actions
    signal clicked()
    signal pressAndHold()

    // states
    property bool hovered: false
    property bool pressed: false
    property bool selected: false

    // settings
    property url source
    property int sourceSize: 40
    property string text
    property string highlightMode: "background" // available: background, indicator, circle, content

    // colors
    property string colorContent: Theme.colorSidebarContent
    property string colorHighlight: Theme.colorSidebarHighlight

    // indicator
    property url indicatorSource: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
    property bool indicatorAnimated: false

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: control.pressed = true
        onReleased: control.pressed = false

        onEntered: control.hovered = true
        onExited: control.hovered = false
        onCanceled: {
            control.hovered = false
            control.pressed = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.centerIn: parent

        width: (control.highlightMode === "circle") ? height : parent.width
        height: parent.height
        radius: (control.highlightMode === "circle") ? width : 0

        visible: (control.highlightMode === "background" ||
                  control.highlightMode === "indicator" ||
                  control.highlightMode === "circle")
        color: control.colorHighlight
        opacity: {
            if (control.selected) return 1
            if (control.hovered) return 0.5
            return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 233 } }
    }
    Rectangle {
        id: backgroundIndicator
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: 6
        visible: (control.selected && control.highlightMode === "indicator")
        color: Theme.colorPrimary
    }

    ////////////////////////////////////////////////////////////////////////////

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: -4

        IconSvg {
            id: contentImage
            width: control.sourceSize
            height: control.sourceSize

            Layout.alignment: Qt.AlignHCenter
            Layout.minimumWidth: control.sourceSize
            Layout.minimumHeight: control.sourceSize
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize

            visible: source.toString().length

            source: control.source
            color: (!control.selected && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            opacity: control.enabled ? 1.0 : 0.33

            Item {
                id: contentIndicator
                width: 24; height: 24;
                anchors.right: parent.right
                anchors.rightMargin: -4
                anchors.bottom: parent.bottom

                opacity: control.indicatorAnimated ? 1 : 0
                Behavior on opacity { OpacityAnimator { duration: 500 } }

                Rectangle {
                    width: 24; height: 24; radius: 12;
                    opacity: 0.66
                    color: Theme.colorHighContrast
                }

                IconSvg {
                    width: 20; height: 20;
                    anchors.centerIn: parent
                    source: control.indicatorSource
                    color: Theme.colorLowContrast

                    NumberAnimation on rotation {
                        running: control.indicatorAnimated
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        duration: 1000
                        from: 0
                        to: 360
                    }
                }
            }
        }

        Text {
            id: contentText
            width: parent.width

            visible: control.text
            text: control.text
            textFormat: Text.PlainText
            color: (!control.selected && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
