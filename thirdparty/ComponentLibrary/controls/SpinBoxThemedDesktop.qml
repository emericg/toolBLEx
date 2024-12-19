import QtQuick
import QtQuick.Effects
import QtQuick.Controls.impl
import QtQuick.Templates as T

import ComponentLibrary

T.SpinBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             up.implicitIndicatorHeight, down.implicitIndicatorHeight)

    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))

    font.pixelSize: Theme.componentFontSize

    property string legend

    ////////////////

    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    ////////////////

    background: Rectangle {
        implicitWidth: 128
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        color: Theme.colorComponentBackground
        opacity: control.enabled ? 1 : 0.66

        Rectangle {
            width: control.height
            height: control.height / 2
            x: control.mirrored ? 0 : control.width - width
            y: 0
            color: control.up.pressed ? Theme.colorComponentDown : Theme.colorComponent
            opacity: control.up.hovered ? 0.8 : 1
            Behavior on opacity { NumberAnimation { duration: 133 } }
        }
        Rectangle {
            width: control.height
            height: control.height / 2
            x: control.mirrored ? 0 : control.width - width
            y: height
            color: control.down.pressed ? Theme.colorComponentDown : Theme.colorComponent
            opacity: control.down.hovered ? 0.8 : 1
            Behavior on opacity { NumberAnimation { duration: 133 } }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.componentRadius
            color: "transparent"
            border.width: Theme.componentBorderWidth
            border.color: control.focus ? Theme.colorPrimary : Theme.colorComponentBorder
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: false
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSpreadAtMax: 0.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    width: control.width
                    height: control.height
                    radius: Theme.componentRadius
                }
            }
        }
    }

    ////////////////

    contentItem: Item {
        anchors.left: parent.left
        anchors.leftMargin: control.leftPadding
        anchors.right: parent.right
        anchors.rightMargin: control.rightPadding + control.height

        opacity: control.enabled ? 1 : 0.66

        Row {
            anchors.centerIn: parent
            spacing: 4

            TextInput {
                height: control.height
                anchors.verticalCenter: parent.verticalCenter

                color: Theme.colorComponentText
                selectionColor: Theme.colorPrimary
                selectedTextColor: "white"
                selectByMouse: control.editable

                text: control.value
                font: control.font
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter

                readOnly: !control.editable
                validator: control.validator
                inputMethodHints: Qt.ImhDigitsOnly

                onEditingFinished: {
                    //var v = parseInt(text)
                    //if (text.length <= 0) v = control.from
                    //if (isNaN(v)) v = control.from
                    //if (v < control.from) v = control.from
                    //if (v > control.to) v = control.to

                    //control.value = v
                    //control.valueModified()

                    control.focus = false
                    focus = false
                }
                Keys.onBackPressed: {
                    control.focus = false
                    focus = false
                }
            }

            Text {
                height: control.height
                anchors.verticalCenter: parent.verticalCenter

                visible: control.legend
                color: Theme.colorComponentText
                opacity: 0.66

                text: control.legend
                textFormat: Text.PlainText
                font: control.font
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
        }
    }

    ////////////////

    up.indicator: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight / 2

        width: control.height
        height: control.height / 2
        x: control.mirrored ? 0 : control.width - width
        y: 0

        opacity: enabled ? 1 : 0.5

        Canvas {
            id: arrowup
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 2
            width: control.height * 0.333
            height: control.height * 0.166
            rotation: 180

            Connections {
                target: Theme
                function onCurrentThemeChanged() { arrowup.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width / 2, height)
                ctx.closePath()
                ctx.fillStyle = Theme.colorIcon
                ctx.fill()
            }
        }
    }

    ////////////////

    down.indicator: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight / 2

        width: control.height
        height: control.height / 2
        x: control.mirrored ? 0 : control.width - width
        y: height

        opacity: enabled ? 1 : 0.5

        Canvas {
            id: arrowdown
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            width: control.height * 0.333
            height: control.height * 0.166
            rotation: 0

            Connections {
                target: Theme
                function onCurrentThemeChanged() { arrowdown.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width / 2, height)
                ctx.closePath()
                ctx.fillStyle = Theme.colorIcon
                ctx.fill()
            }
        }
    }

    ////////////////
}
