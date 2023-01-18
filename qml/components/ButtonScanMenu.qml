import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: control
    width: content.width + 32 + leftPadding + rightPadding
    height: Theme.componentHeight

    property int leftPadding: 12
    property int rightPadding: 12 + (control.source.toString().length && control.text ? 2 : 0)

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // settings
    property string scanmode: "full"
    property string text
    property url source
    property int sourceSize: UtilsNumber.alignTo(height * 0.666, 2)
    property int layoutDirection: Qt.LeftToRight

    // colors
    property string color: Theme.colorPrimary
    property string colorText: "white"

    // animation
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    MouseArea {
        id: mousearea
        anchors.fill: parent
        enabled: control.hoverAnimation

        hoverEnabled: control.hoverAnimation

        onClicked: control.clicked()
        onPressAndHold: control.pressAndHold()

        onPressed: {
            mouseBackground.width = (control.width * 2)
        }
        onReleased: {
            //mouseBackground.width = 0 // disabled, we let the click expand the ripple
        }

        onEntered: {
            mouseBackground.width = 72
        }
        onExited: {
            mouseBackground.width = 0
        }
        onCanceled: {
            mouseBackground.width = 0
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        id: background
        anchors.fill: parent
        implicitWidth: 80
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        opacity: enabled ? (mousearea.containsPress && !control.hoverAnimation ? 0.8 : 1.0) : 0.4
        color: control.color

        border.width: Theme.componentBorderWidth
        border.color: Qt.darker(color, 1.03)

        Item {
            anchors.fill: parent

            Rectangle { // menu toggle
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                width: 32
                color: Qt.darker(control.color, 1.03)

                IconSvg {
                    anchors.centerIn: parent
                    width: 28
                    height: 28

                    Layout.maximumWidth: control.sourceSize
                    Layout.maximumHeight: control.sourceSize
                    Layout.alignment: Qt.AlignVCenter

                    opacity: enabled ? 1.0 : 0.66
                    color: control.colorText
                    source: "qrc:/assets/icons_material/baseline-more_vert-24px.svg"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                    onClicked: (mouse) => {
                                   actionMenu.open()
                        mouse.accepted = true
                    }
                }
            }

            Rectangle { // mouse circle
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: mousearea.mouseX - (width / 2)
                y: mousearea.mouseY - (width / 2)

                visible: control.hoverAnimation
                color: "white"
                opacity: mousearea.containsMouse ? 0.16 : 0
                Behavior on opacity { NumberAnimation { duration: 333 } }
                Behavior on width { NumberAnimation { duration: 200 } }
            }

            layer.enabled: control.hoverAnimation
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    RowLayout {
        id: content
        x: leftPadding
        height: control.height
        spacing: 6
        layoutDirection: control.layoutDirection

        IconSvg {
            source: control.source
            width: control.sourceSize
            height: control.sourceSize

            visible: control.source.toString().length
            Layout.maximumWidth: control.sourceSize
            Layout.maximumHeight: control.sourceSize
            Layout.alignment: Qt.AlignVCenter

            opacity: enabled ? 1.0 : 0.66
            color: control.colorText
        }
        Text {
            text: control.text
            textFormat: Text.PlainText

            visible: control.text
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            opacity: enabled ? (mousearea.containsPress && !control.hoverAnimation ? 0.8 : 1.0) : 0.66
            color: control.colorText
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Popup { // menu
        id: actionMenu
        x: 0
        y: control.height + 8
        width: control.width

        padding: 0
        margins: 0

        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition { NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 133; } }
        exit: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 133; } }

        background: Rectangle {
            color: Theme.colorComponentBackground
            radius: Theme.componentRadius
            border.color: Theme.colorPrimary
            border.width: Theme.componentBorderWidth
        }

        contentItem: Column {
            padding: Theme.componentBorderWidth

            topPadding: 0
            bottomPadding: 0
            spacing: -8

            CheckBoxThemed {
                anchors.right: parent.right
                anchors.rightMargin: 4
                layoutDirection: Qt.RightToLeft

                text: qsTr("services & data")
                checked: (scanmode === "full")
                onClicked: scanmode = "full"
                nextCheckState: function() { if (checkState === Qt.Checked) return Qt.Checked }
            }

            CheckBoxThemed {
                anchors.right: parent.right
                anchors.rightMargin: 4
                layoutDirection: Qt.RightToLeft

                text: qsTr("services only")
                checked: (scanmode === "skip")
                onClicked: scanmode = "skip"
                nextCheckState: function() { if (checkState === Qt.Checked) return Qt.Checked }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
