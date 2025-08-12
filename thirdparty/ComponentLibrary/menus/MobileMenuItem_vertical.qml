import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    focusPolicy: Qt.NoFocus

    // icon
    property url source
    property int sourceSize: 32
    property int sourceRotation: 0

    // colors
    property color colorContent: Theme.colorTabletmenuContent
    property color colorHighlight: Theme.colorTabletmenuHighlight
    property color colorIndicator: Theme.colorPrimary

    // settings
    property bool backgroundVisible: true

    // activity indicator
    property bool indicatorVisible: false
    property bool indicatorAnimated: false

    ////////////////

    background: Item {
        implicitWidth: 56
        implicitHeight: 56
    }

    ////////////////

    contentItem: ColumnLayout {
        spacing: -8

        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignHCenter

            IconSvg { // contentImage
                anchors.centerIn: parent
                width: control.sourceSize
                height: control.sourceSize

                visible: control.source.toString().length
                source: control.source

                rotation: control.sourceRotation
                opacity: control.enabled ? 1 : 0.66
                color: control.highlighted ? control.colorHighlight : control.colorContent
                Behavior on color { ColorAnimation { duration: 133 } }

                Rectangle { // backgroundIndicator
                    anchors.centerIn: parent
                    z: -1

                    height: 32
                    radius: height
                    color: control.colorHighlight
                    rotation: -control.sourceRotation

                    visible: control.backgroundVisible

                    width: control.highlighted ? 60 : 0
                    Behavior on width { NumberAnimation { duration: 133 } }

                    opacity: control.highlighted ? 0.2 : 0
                    Behavior on opacity { OpacityAnimator { duration: 133 } }
                }

                Rectangle { // activityIndicator
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    width: 6
                    height: 6
                    radius: 6
                    color: control.colorIndicator
                    visible: control.indicatorVisible

                    SequentialAnimation on opacity { // fade animation
                        loops: Animation.Infinite
                        running: control.indicatorAnimated
                        onStopped: opacity = 1
                        PropertyAnimation { to: 0.92; duration: 666; }
                        PropertyAnimation { to: 0.33; duration: 666; }
                    }
                }
            }
        }

        Text { // contentText
            Layout.preferredWidth: control.width
            Layout.alignment: Qt.AlignHCenter

            visible: control.text

            text: control.text
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeContentSmall - 1
            font.bold: true

            color: control.highlighted ? control.colorHighlight : control.colorContent
            Behavior on color { ColorAnimation { duration: 233 } }
        }
    }

    ////////////////
}
