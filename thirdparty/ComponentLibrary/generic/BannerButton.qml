import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import ComponentLibrary

Rectangle {
    id: control

    anchors.left: parent.left
    anchors.leftMargin: Theme.componentMarginXL
    anchors.right: parent.right
    anchors.rightMargin: Theme.componentMarginXL
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.componentMarginXL

    radius: 8
    height: 44
    color: Theme.colorMaterialBlue

    layer.enabled: true
    layer.effect: MultiEffect {
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowColor: "#30000000"
    }

    ////////////////

    property string text: "Banner button..."
    property string textButton: "Cancel"
    property string source: "qrc:/IconLibrary/material-symbols/autorenew.svg"

    property bool running: false
    property int progress: 0

    signal clicked()

    ////////////////

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.componentMargin / 2

        IconSvg {
            id: workingIndicator
            anchors.verticalCenter: parent.verticalCenter

            width: 24
            height: 24
            color: "white"
            source: control.source
            opacity: 1
            Behavior on opacity { OpacityAnimator { duration: 233 } }

            NumberAnimation on rotation { // refreshAnimation (rotate)
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
                easing.type: Easing.Linear
                running: control.running
                alwaysRunToEnd: true
                onStarted: workingIndicator.opacity = 1
                onStopped: workingIndicator.opacity = 0
            }
            SequentialAnimation on opacity { // scanAnimation (fade)
                loops: Animation.Infinite
                running: control.running
                onStopped: workingIndicator.opacity = 0
                PropertyAnimation { to: 1; duration: 750; }
                PropertyAnimation { to: 0.33; duration: 750; }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: control.text
            font.pixelSize: Theme.componentFontSize
            color: "white"
        }
    }

    ////////////////

    ButtonSunken {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        colorBackground: Theme.colorMaterialBlue
        colorText: "white"
        text: control.textButton

        onClicked: control.clicked()
    }

    ////////////////
}
