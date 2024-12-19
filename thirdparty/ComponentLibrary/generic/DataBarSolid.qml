import QtQuick
import QtQuick.Effects

import ComponentLibrary

Item {
    id: control

    implicitWidth: 128
    implicitHeight: 16

    property int hhh: 16
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
    property color colorForeground: Theme.colorPrimary
    property color colorBackground: Theme.colorForeground

    ////////////////

    Row {
        anchors.fill: parent
        spacing: 12

        Text {
            id: item_legend
            width: control.legendWidth
            anchors.verticalCenter: parent.verticalCenter

            visible: (control.legend.length)

            text: control.legend
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.bold: true
            font.capitalization: Font.AllUppercase
            color: Theme.colorSubText
            horizontalAlignment: Text.AlignRight
        }

        Item {
            id: item_bg
            width: control.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            height: control.hhh
            anchors.verticalCenter: parent.verticalCenter

            clip: true

            Rectangle {
                id: rect_bg
                anchors.fill: parent

                radius: control.hhh
                color: control.colorBackground

                layer.enabled: true
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
                    id: item_data
                    width: {
                        var res = UtilsNumber.normalize(control.value, control.valueMin, control.valueMax) * item_bg.width
                        if (res > item_bg.width) res = item_bg.width
                        return res
                    }
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    radius: control.hhh
                    color: control.colorForeground

                    Behavior on width { NumberAnimation { duration: control.animated ? 333 : 0 } }
                }
            }

            ////////

            Rectangle {
                id: item_limit_low
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (control.limitMin > 0 && control.limitMin > control.valueMin && control.limitMin < control.valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)
                x: UtilsNumber.normalize(control.limitMin, control.valueMin, control.valueMax) * item_bg.width
                color: (control.limitMin <= control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (control.limitMin <= control.value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
            }
            Text {
                anchors.right: item_limit_low.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                visible: (control.limitMin > 0 && control.limitMin > control.valueMin && control.limitMin < control.valueMax) &&
                         (width < item_limit_low.x) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                text: qsTr("min", "short for minimum")
                textFormat: Text.PlainText

                font.pixelSize: Theme.fontSizeContentVerySmall
                color: (control.limitMin <= control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (control.limitMin <= control.value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
            }
            Rectangle {
                anchors.horizontalCenter: item_limit_low.horizontalCenter
                anchors.verticalCenter: item_limit_low.bottom
                //width: 6; height: 6; radius: 1; rotation: 45; // little triangle
                width: 6; height: 3; // little bar
                z: 2

                visible: (control.limitMin > 0 && control.limitMin > control.valueMin && control.limitMin < control.valueMax) &&
                         (!(x-2 < indicator.x || x+2 > indicator.x+indicator.width) ||
                          !(x+width-2 < indicator.x || x+width+2 > indicator.x+indicator.width))

                color: (control.limitMin < control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (control.limitMin < control.value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
            }

            ////////

            Rectangle {
                id: item_limit_high
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (control.limitMax > 0 && control.limitMax > control.valueMin && control.limitMax < control.valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                x: UtilsNumber.normalize(control.limitMax, control.valueMin, control.valueMax) * item_bg.width
                color: (control.limitMax < control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (control.limitMax < control.value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
            }
            Text {
                anchors.left: item_limit_high.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                visible: (control.limitMax > 0 && control.limitMax > control.valueMin && control.limitMax < control.valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                text: qsTr("max", "short for maximum")
                textFormat: Text.PlainText

                font.pixelSize: Theme.fontSizeContentVerySmall
                color: (control.limitMax < control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (control.limitMax < control.value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
            }
            Rectangle {
                anchors.horizontalCenter: item_limit_high.horizontalCenter
                anchors.verticalCenter: item_limit_high.bottom
                //width: 6; height: 6; radius: 1; rotation: 45; // little triangle
                width: 6; height: 3; // little bar
                z: 2

                visible: (control.limitMax > 0 && control.limitMax > control.valueMin && control.limitMax < control.valueMax) &&
                         (!(x-2 < indicator.x || x+2 > indicator.x+indicator.width) ||
                          !(x+width-2 < indicator.x || x+width+2 > indicator.x+indicator.width))

                color: (control.limitMax < control.value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (control.limitMax < control.value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: control.animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
            }

            ////////

            Rectangle {
                id: indicator
                anchors.verticalCenter: parent.verticalCenter

                width: textIndicator.width + 12
                height: control.hhh
                radius: (control.value <= 0 || item_data.width > indicator.width) ? control.hhh : 0
                color: {
                    if (control.value <= 0)
                        return "transparent"
                     else if (item_data.width > indicator.width)
                        return control.colorForeground
                    else
                        return control.colorBackground
                }

                x: {
                    if (item_data.width > indicator.width)
                        return item_data.width - indicator.width
                    else
                        return item_data.width
                }

                Text {
                    id: textIndicator
                    height: control.hhh
                    anchors.centerIn: parent

                    color: (item_data.width > indicator.width) ? "white" : Theme.colorSubText

                    text: {
                        if (control.value < -20)
                            return " ? ";
                        else {
                            if (control.value % 1 === 0)
                                return control.prefix + control.value + control.suffix
                            else
                                return control.prefix + control.value.toFixed(control.floatprecision) + control.suffix
                        }
                    }
                    textFormat: Text.PlainText
                    font.bold: true
                    font.pixelSize: isDesktop ? 12 : 13
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                IconSvg { // warningIndicator
                    width: control.hhh - 2
                    height: control.hhh - 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 4
                    anchors.left: {
                        if (item_data.width > indicator.width)
                            return parent.right
                        else
                            return textIndicator.right
                    }

                    color: Theme.colorRed
                    opacity: (control.warning && control.value > -20 && control.value < control.limitMin) ? 1 : 0
                    Behavior on opacity { OpacityAnimator { duration: control.animated ? 333 : 0 } }
                    source: "qrc:/IconLibrary/material-symbols/warning-fill.svg"

                    Rectangle {
                        width: control.hhh
                        height: control.hhh
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: -1
                        color: control.colorBackground
                        visible: (parent.opacity === 1)
                    }
                }
            }

            ////////
        }
    }

    ////////////////
}
