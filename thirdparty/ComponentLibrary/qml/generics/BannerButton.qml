import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Templates as T

import ComponentLibrary

T.Control {
    id: control

    // Standard anchors:
    //anchors.left: parent.left
    //anchors.leftMargin: Theme.componentMarginXL
    //anchors.right: parent.right
    //anchors.rightMargin: Theme.componentMarginXL
    //anchors.bottom: parent.bottom
    //anchors.bottomMargin: Theme.componentMarginXL

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    //opacity: enabled ? 1 : 0.66
    Behavior on opacity { OpacityAnimator { duration: Theme.animationMediumSpeed } }

    font.pixelSize: Theme.fontSizeContent
    font.bold: false

    ////////////////

    // settings
    property int radius: 8

    // colors
    property color colorBackground: Theme.colorMaterialBlue
    property color colorContent: "white"

    // icon
    property url source: "qrc:/IconLibrary/material-symbols/autorenew.svg"
    property int sourceSize: UtilsNumber.alignTo(height * 0.5, 2)
    property int sourceRotation: 0

    // text
    property string text: "Banner button..."
    property string textButton: qsTr("Cancel")

    // animation
    property string animation // available: rotate, fade, both
    property bool animationRunning: false

    // signal
    signal clicked()

    ////////////////

    background: Rectangle {
        implicitWidth: 256
        implicitHeight: Theme.componentHeightXL

        radius: control.radius
        color: control.colorBackground

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
            shadowEnabled: true
            shadowColor: Theme.colorComponentShadow
        }
    }

    ////////////////

    contentItem: RowLayout {

        ////////

        Item {
            Layout.preferredWidth: control.height
            Layout.preferredHeight: control.height

            visible: control.source.toString().length

            IconSvg { // workingIndicator
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

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: control.text
            textFormat: Text.PlainText
            font: control.font
            color: control.colorContent
        }

        ////////

        ButtonSunken {
            Layout.fillHeight: true

            colorBackground: Theme.colorMaterialBlue
            colorText: control.colorContent

            text: control.textButton
            font: control.font

            onClicked: control.clicked()
        }

        ////////
    }

    ////////////////
}
