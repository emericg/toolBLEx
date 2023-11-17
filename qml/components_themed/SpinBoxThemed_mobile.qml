import QtQuick 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

T.SpinBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             up.implicitIndicatorHeight, down.implicitIndicatorHeight)

    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))

    opacity: enabled ? 1 : 0.4
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
        implicitWidth: 140
        implicitHeight: Theme.componentHeight

        radius: Theme.componentRadius
        color: Theme.colorComponentBackground

        Rectangle {
            width: control.height
            height: control.height
            anchors.verticalCenter: parent.verticalCenter
            x: control.mirrored ? 0 : control.width - width
            color: control.up.pressed ? Theme.colorComponentDown : Theme.colorComponent
        }
        Rectangle {
            width: control.height
            height: control.height
            anchors.verticalCenter: parent.verticalCenter
            x: control.mirrored ? control.width - width : 0
            color: control.down.pressed ? Theme.colorComponentDown : Theme.colorComponent
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.componentRadius
            color: "transparent"
            border.width: Theme.componentBorderWidth
            border.color: control.focus ? Theme.colorPrimary : Theme.colorComponentBorder
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: control.x
                y: control.y
                width: control.width
                height: control.height
                radius: Theme.componentRadius
            }
        }
    }

    ////////////////

    contentItem: Item {
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
        implicitHeight: Theme.componentHeight

        width: control.height
        height: control.height
        x: control.mirrored ? 0 : control.width - width
        anchors.verticalCenter: control.verticalCenter

        opacity: enabled ? 1 : 0.33

        Rectangle {
            anchors.centerIn: parent
            width: UtilsNumber.round2(parent.height * 0.4)
            height: 2
            color: Theme.colorComponentContent
        }
        Rectangle {
            anchors.centerIn: parent
            width: 2
            height: UtilsNumber.round2(parent.height * 0.4)
            color: Theme.colorComponentContent
        }
    }

    ////////////////

    down.indicator: Item {
        implicitWidth: Theme.componentHeight
        implicitHeight: Theme.componentHeight

        width: control.height
        height: control.height
        x: control.mirrored ? control.width - width : 0
        anchors.verticalCenter: control.verticalCenter

        opacity: enabled ? 1 : 0.33

        Rectangle {
            anchors.centerIn: parent
            width: UtilsNumber.round2(parent.height * 0.4)
            height: 2
            color: Theme.colorComponentContent
        }
    }

    ////////////////
}
