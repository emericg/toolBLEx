import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    implicitWidth: 128
    implicitHeight: 32

    property int hhh: 8
    property bool animated: true

    property real value: 0
    property real valueMin: 0
    property real valueMax: 100
    property real limitMin: -1
    property real limitMax: -1

    property string prefix
    property string suffix
    property int floatprecision: 0
    property bool warning: false

    property string legend
    property int legendWidth: item_legend.contentWidth
    property int legendContentWidth: item_legend.contentWidth

    // colors
    property color colorText: Theme.colorText
    property color colorForeground: Theme.colorPrimary
    property color colorBackground: Theme.colorForeground

    ////////////////

    Row {
        anchors.fill: parent
        spacing: 12

        Text {
            id: item_legend
            width: control.legendWidth
            anchors.verticalCenter: item_bg.verticalCenter

            visible: (control.legend.length)

            text: control.legend
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.capitalization: Font.AllUppercase
            color: Theme.colorSubText
            horizontalAlignment: Text.AlignRight
        }

        Item {
            id: item_bg
            width: control.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            height: control.hhh
            anchors.bottom: parent.bottom

            ////////

            Rectangle {
                id: rect_bg
                anchors.fill: parent

                radius: 4
                clip: isDesktop
                color: control.colorBackground

                layer.enabled: !isDesktop
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskInverted: false
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                    maskSpreadAtMax: 0.0
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            x: rect_bg.x
                            y: rect_bg.y
                            width: rect_bg.width
                            height: rect_bg.height
                            radius: rect_bg.radius
                        }
                    }
                }

                Rectangle {
                    id: rect_data
                    width: {
                        var res = UtilsNumber.normalize( control.value, control.valueMin, control.valueMax) * rect_bg.width

                        if ( control.value <= control.valueMin ||control.value >= control.valueMax)
                            res += 0
                        else
                            res += 1.5*radius // +radius, so the indicator arrow point to the real value, not the rounded end of the data bar

                        if (res > rect_bg.width)
                            res = rect_bg.width

                         return res
                    }
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom

                    radius: 3
                    color: control.colorForeground

                    Behavior on width { NumberAnimation { duration: control.animated ? 333 : 0 } }
                }

                Rectangle {
                    id: item_limit_low
                    width: 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    visible: (control.limitMin > 0 && control.limitMin > control.valueMin && control.limitMin < control.valueMax)
                    x: UtilsNumber.normalize(control.limitMin, control.valueMin, control.valueMax) * rect_bg.width
                    color: (control.limitMin < control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                    opacity: (control.limitMin < control.value) ? 0.66 : 0.33

                    Behavior on x { NumberAnimation { duration: control.animated ? 333 : 0 } }
                    Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                    Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
                }
                Rectangle {
                    id: item_limit_high
                    width: 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    visible: (control.limitMax > 0 && control.limitMax > control.valueMin && control.limitMax < control.valueMax)
                    x: UtilsNumber.normalize(control.limitMax, control.valueMin, control.valueMax) * rect_bg.width
                    color: (control.limitMax <control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                    opacity: (control.limitMax < control.value) ? 0.66 : 0.33

                    Behavior on x { NumberAnimation { duration: control.animated ? 333 : 0 } }
                    Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                    Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
                }
            }

            ////////

            Text {
                id: textIndicator
                height: 15
                y: -22
                x: {
                    if (rect_data.width < ((textIndicator.width / 2) + 8)) { // left
                        return 4
                    } else if ((rect_bg.width - rect_data.width) < (textIndicator.width / 2)) { // right
                        return rect_bg.width - textIndicator.width - 4
                    }
                    return rect_data.width - (textIndicator.width / 2) - 4
                }

                text: {
                    if ( control.value < -20)
                        return " ? ";
                    else {
                        if ( control.value % 1 === 0)
                            return control.prefix + control.value + control.suffix
                        else
                            return control.prefix + control.value.toFixed(control.floatprecision) + control.suffix
                    }
                }
                textFormat: Text.PlainText
                color: "white"
                font.bold: true
                font.pixelSize: Theme.fontSizeContentVerySmall
                horizontalAlignment: Text.AlignHCenter

                Rectangle {
                    height: 18
                    anchors.left: parent.left
                    anchors.leftMargin: -4
                    anchors.right: parent.right
                    anchors.rightMargin: -4
                    anchors.verticalCenter: parent.verticalCenter

                    z: -1
                    radius: 1
                    color: control.colorForeground

                    Rectangle {
                        id: item_indicator_triangle
                        width: 6
                        height: 6
                        anchors.top: parent.bottom
                        anchors.topMargin: -3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: {
                            if (rect_data.width < ((textIndicator.width / 2) + 8)) { // left
                                if (rect_data.width > 12) {
                                    return (rect_data.width - ((textIndicator.width / 2) + 8))
                                } else {
                                    return -((textIndicator.width / 2) - 4)
                                }
                            } else if ((rect_bg.width - rect_data.width) < (textIndicator.width / 2)) { // right
                                return -((rect_bg.width - rect_data.width) - (textIndicator.width / 2)) - 4
                            }
                            return 0
                        }

                        radius: 1
                        rotation: 45
                        color: control.colorForeground
                    }
                }
            }

            ////////

            IconSvg {
                id: warningIndicator
                width: 15
                height: 15
                anchors.verticalCenter: textIndicator.verticalCenter
                anchors.leftMargin: 8
                anchors.left: textIndicator.right

                color: Theme.colorRed
                opacity: (control.warning && control.value > -20 && control.value < control.limitMin) ? 1 : 0
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
                source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"
            }

            ////////
        }
    }

    ////////////////
}
