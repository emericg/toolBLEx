import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import ComponentLibrary

Rectangle {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: Theme.componentMargin
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentMargin
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.componentMargin

    radius: 8
    height: 44
    color: Theme.colorMaterialBlue
    //opacity: enabled ? 1 : 0.66

    layer.enabled: true
    layer.effect: MultiEffect {
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: "#30000000"
    }

    ////////////////

    property string text: "Banner progress button..."
    property string textButton: "Cancel"

    // icon
    property url source
    property int sourceSize: 24 // UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // progress
    property int progress: -1
    property bool progressRunning: false // (control.progress >= 0)

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
        spacing: 0 // Theme.componentMargin / 2

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
                color: "white"
                source: control.source
                rotation: control.sourceRotation

                opacity: 1
                Behavior on opacity { OpacityAnimator { duration: 233 } }

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
                color: "white"
            }

            ////

            Rectangle { // progress bar background
                anchors.left: parent.left
                anchors.right: parent.right

                height: 6
                visible: control.progressRunning
                color: Qt.rgba(255, 255, 255, 0.1)

                Rectangle { // progress bar
                    width: control.progress ? (parent.width * (control.progress/100)) : 0
                    height: parent.height
                    color: "white"
                }
            }

            ////
        }

        ////////

        ButtonSunken {
            id: button

            colorBackground: Theme.colorMaterialBlue
            colorText: "white"
            text: control.textButton

            onClicked: control.clicked()
        }

        ////////
    }

    ////////////////
}
