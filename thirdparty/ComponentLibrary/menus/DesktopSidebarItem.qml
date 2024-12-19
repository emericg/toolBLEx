import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: 64
    implicitHeight: 64

    width: parent.width // width drive the size of this element
    height: Math.max(parent.width, contentColumn.height + 24)

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: 40
    property int sourceRotation: 0
    property string highlightMode: "background" // available: background, indicator, circle, content

    // colors
    property color colorContent: Theme.colorSidebarContent
    property color colorHighlight: Theme.colorSidebarHighlight

    // indicator
    property bool indicatorVisible: false
    property bool indicatorAnimated: false
    property color indicatorColor: "white"
    property url indicatorSource

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: 64

        width: control.width
        height: control.height
        radius: (control.highlightMode === "circle") ? width : 0

        visible: (control.highlightMode === "background" ||
                  control.highlightMode === "indicator" ||
                  control.highlightMode === "circle")
        color: control.colorHighlight
        opacity: {
            if (control.highlighted) return 1
            if (control.hovered) return 0.5
            return 0
        }
        Behavior on opacity { OpacityAnimator { duration: 233 } }

        Rectangle { // backgroundIndicator
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            width: 6
            visible: (control.highlighted && control.highlightMode === "indicator")
            color: Theme.colorPrimary
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: -4

        IconSvg { // contentImage
            Layout.preferredWidth: control.sourceSize
            Layout.preferredHeight: control.sourceSize
            Layout.alignment: Qt.AlignHCenter

            visible: source.toString().length

            source: control.source
            rotation: control.sourceRotation
            color: (!control.highlighted && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            opacity: control.enabled ? 1 : 0.66

            Item { // activityIndicator
                width: 24; height: 24;
                anchors.right: parent.right
                anchors.rightMargin: -4
                anchors.bottom: parent.bottom

                opacity: (control.indicatorVisible || control.indicatorAnimated) ? 1 : 0
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

        Text { // contentText
            Layout.preferredWidth: control.sourceSize
            Layout.alignment: Qt.AlignHCenter

            visible: control.text
            text: control.text
            textFormat: Text.PlainText
            color: (!control.highlighted && control.highlightMode === "content") ? control.colorHighlight : control.colorContent
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
