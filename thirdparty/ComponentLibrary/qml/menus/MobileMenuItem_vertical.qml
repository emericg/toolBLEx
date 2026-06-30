import QtQuick
import QtQuick.Layouts
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
    property bool backgroundVisible: false

    // activity indicator
    property bool indicatorVisible: false
    property bool indicatorAnimated: false

    ////////////////

    background: Item {
        implicitWidth: 56
        implicitHeight: 56
    }

    ////////////////

    contentItem: Item {
        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0
            spacing: 0

            IconSvg { // contentImage
                anchors.horizontalCenter: parent.horizontalCenter
                width: control.sourceSize
                height: control.sourceSize

                visible: control.source.toString().length
                source: control.source

                rotation: control.sourceRotation
                opacity: control.enabled ? 1 : 0.66
                color: control.highlighted ? control.colorHighlight : control.colorContent
                Behavior on color { ColorAnimation { duration: Theme.animationFastSpeed } }

                Rectangle { // backgroundIndicator
                    anchors.centerIn: parent

                    height: control.sourceSize
                    radius: height
                    z: -1

                    color: control.colorHighlight
                    rotation: -control.sourceRotation
                    visible: control.backgroundVisible

                    width: control.highlighted ? 60 : 0
                    Behavior on width { NumberAnimation { duration: Theme.animationFastSpeed } }

                    opacity: control.highlighted ? 0.2 : 0
                    Behavior on opacity { OpacityAnimator { duration: Theme.animationFastSpeed } }
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

            Text { // contentText
                width: control.width

                visible: control.text

                text: control.text
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeContentVerySmall
                font.bold: true

                color: control.highlighted ? control.colorHighlight : control.colorContent
                Behavior on color { ColorAnimation { duration: Theme.animationMediumSpeed } }
            }
        }
    }

    ////////////////
}
