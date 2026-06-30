import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import ComponentLibrary

Rectangle {
    id: control

    // Standard anchors:
    //anchors.left: parent.left
    //anchors.leftMargin: Theme.componentMargin
    //anchors.right: parent.right
    //anchors.rightMargin: Theme.componentMargin
    //anchors.bottom: parent.bottom
    //anchors.bottomMargin: Theme.componentMargin

    height: 44
    radius: 8

    color: Theme.colorMaterialBlue
    //opacity: enabled ? 1 : 0.66

    layer.enabled: true
    layer.effect: MultiEffect {
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: Theme.colorComponentShadow
    }

    ////////////////

    // colors
    property color colorContent: "white"

    // icon
    property url source: "qrc:/IconLibrary/material-symbols/autorenew.svg"
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // text
    property string text: "Banner progress button..."
    property string textButton: qsTr("Cancel")

    // progress
    property int progress: -1
    property bool progressRunning: (control.progress >= 0)

    // animation
    property string animation // available: rotate, fade, both
    property bool animationRunning: false

    // signal
    signal clicked()

    ////////////////

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        ////////

        Item {
            Layout.preferredWidth: control.height
            Layout.preferredHeight: control.height

            visible: control.source.toString().length

            IconSvg {
                id: workingIndicator
                anchors.centerIn: parent

                width: control.sourceSize
                height: control.sourceSize
                color: control.colorContent
                source: control.source
                rotation: control.sourceRotation

                opacity: 1
                Behavior on opacity { OpacityAnimator { duration: Theme.animationMediumSpeed } }

                SequentialAnimation on opacity {
                    running: (control.animationRunning &&
                              (control.animation === "fade" || control.animation === "both"))
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    PropertyAnimation { to: 0.5; duration: 666; }
                    PropertyAnimation { to: 1; duration: 666; }
                }
                NumberAnimation on rotation {
                    running: (control.animationRunning &&
                              (control.animation === "rotate" || control.animation === "both"))
                    alwaysRunToEnd: true
                    loops: Animation.Infinite

                    duration: 1500
                    from: 0
                    to: 360
                    easing.type: Easing.Linear
                }
            }
        }

        ////////

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            ////

            Text {
                text: control.text
                font.pixelSize: Theme.componentFontSize
                color: control.colorContent
            }

            ////

            Rectangle { // progress bar background
                anchors.left: parent.left
                anchors.right: parent.right

                height: 6
                visible: control.progressRunning
                color: Qt.rgba(control.colorContent.r, control.colorContent.g, control.colorContent.b, 0.1)

                Rectangle { // progress bar
                    width: control.width * (Math.max(0, Math.min(control.progress, 100)) / 100)
                    height: parent.height
                    color: control.colorContent
                }
            }

            ////
        }

        ////////

        ButtonSunken {
            Layout.fillHeight: true

            colorBackground: Theme.colorMaterialBlue
            colorText: control.colorContent
            text: control.textButton

            onClicked: control.clicked()
        }

        ////////
    }

    ////////////////
}
