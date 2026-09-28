import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: 64
    implicitHeight: 64

    width: parent.width // width drive the size of this element
    height: parent.width

    focusPolicy: Qt.NoFocus

    // settings
    property url source
    property int sourceSize: 36
    property int sourceRotation: 0

    property string highlightMode: "background" // available: background, content
    property int backgroundRadius: 0

    // colors
    property color color: checked ? Theme.colorPrimary : Theme.colorSidebarContent
    property color colorBackground: Qt.rgba(color.r, color.g, color.b, checked ? 0.2 : 1)
    property color colorHighlight: checked ? Theme.colorPrimary : Theme.colorSidebarHighlight
    property color colorContent: checked ? Theme.colorPrimary : Theme.colorText

    // indicator
    property bool indicatorVisible: false
    property bool indicatorAnimated: false
    property color indicatorColor: "white"
    property url indicatorSource

    ////////////////////////////////////////////////////////////////////////////

    background: Item {
        implicitWidth: 64
        implicitHeight: 64

        Rectangle {
            width: control.width
            height: control.height
            radius: control.backgroundRadius

            visible: (control.highlightMode === "background")
            color: (control.highlightMode === "background" || control.checked)
                        ? control.colorHighlight : control.colorBackground
            opacity: {
                if (control.highlighted) return 1
                if (control.checked) return 0.33
                if (control.hovered) return 0.5
                return 0
            }
            Behavior on opacity { OpacityAnimator { duration: Theme.animationMediumSpeed } }
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
            font.pixelSize: Theme.fontSizeContentVeryVerySmall
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
