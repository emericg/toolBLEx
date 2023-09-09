import QtQuick 2.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: dataBarSolid
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
    property string colorForeground: Theme.colorPrimary
    property string colorBackground: Theme.colorForeground

    ////////////////////////////////////////////////////////////////////////////

    Row {
        anchors.fill: parent
        spacing: 12

        ////////////////

        Text {
            id: item_legend
            width: legendWidth
            anchors.verticalCenter: parent.verticalCenter

            visible: (legend.length)

            text: legend
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.bold: true
            font.capitalization: Font.AllUppercase
            color: Theme.colorSubText
            horizontalAlignment: Text.AlignRight
        }

        ////////////////

        Item {
            id: item_bg
            width: dataBarSolid.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            height: hhh
            anchors.verticalCenter: parent.verticalCenter

            clip: true

            Rectangle {
                id: rect_bg
                anchors.fill: parent

                radius: hhh
                color: dataBarSolid.colorBackground

                layer.enabled: !isDesktop
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        x: rect_bg.x
                        y: rect_bg.y
                        width: rect_bg.width
                        height: rect_bg.height
                        radius: rect_bg.radius
                    }
                }

                Rectangle {
                    id: item_data
                    width: {
                        var res = UtilsNumber.normalize(value, valueMin, valueMax) * item_bg.width
                        if (res > item_bg.width) res = item_bg.width
                        return res
                    }
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    radius: hhh
                    color: dataBarSolid.colorForeground

                    Behavior on width { NumberAnimation { duration: animated ? 333 : 0 } }
                }
            }

            ////////

            Rectangle {
                id: item_limit_low
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)
                x: UtilsNumber.normalize(limitMin, valueMin, valueMax) * item_bg.width
                color: (limitMin <= value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin <= value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Text {
                anchors.right: item_limit_low.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax) &&
                         (width < item_limit_low.x) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                //: Short for minimum
                text: qsTr("min")
                textFormat: Text.PlainText

                font.pixelSize: Theme.fontSizeContentVerySmall
                color: (limitMin <= value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin <= value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Rectangle {
                anchors.horizontalCenter: item_limit_low.horizontalCenter
                anchors.verticalCenter: item_limit_low.bottom
                //width: 6; height: 6; radius: 1; rotation: 45; // little triangle
                width: 6; height: 3; // little bar
                z: 2

                visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax) &&
                         (!(x-2 < indicator.x || x+2 > indicator.x+indicator.width) ||
                          !(x+width-2 < indicator.x || x+width+2 > indicator.x+indicator.width))

                color: (limitMin < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMin < value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }

            ////////

            Rectangle {
                id: item_limit_high
                width: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                x: UtilsNumber.normalize(limitMax, valueMin, valueMax) * item_bg.width
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25

                Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Text {
                anchors.left: item_limit_high.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax) &&
                         (x < indicator.x || x > indicator.x+indicator.width) &&
                         (x+width < indicator.x || x+width > indicator.x+indicator.width)

                //: Short for maximum
                text: qsTr("max")
                textFormat: Text.PlainText

                font.pixelSize: Theme.fontSizeContentVerySmall
                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }
            Rectangle {
                anchors.horizontalCenter: item_limit_high.horizontalCenter
                anchors.verticalCenter: item_limit_high.bottom
                //width: 6; height: 6; radius: 1; rotation: 45; // little triangle
                width: 6; height: 3; // little bar
                z: 2

                visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax) &&
                         (!(x-2 < indicator.x || x+2 > indicator.x+indicator.width) ||
                          !(x+width-2 < indicator.x || x+width+2 > indicator.x+indicator.width))

                color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                opacity: (limitMax < value) ? 0.75 : 0.25
                Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
            }

            ////////

            Rectangle {
                id: indicator
                anchors.verticalCenter: parent.verticalCenter

                width: textIndicator.width + 12
                height: hhh
                radius: (value <= 0 || item_data.width > indicator.width) ? hhh : 0
                color: {
                    if (value <= 0)
                        return "transparent"
                     else if (item_data.width > indicator.width)
                        return dataBarSolid.colorForeground
                    else
                        return dataBarSolid.colorBackground
                }

                x: {
                    if (item_data.width > indicator.width)
                        return item_data.width - indicator.width
                    else
                        return item_data.width
                }

                Text {
                    id: textIndicator
                    height: hhh
                    anchors.centerIn: parent

                    color: (item_data.width > indicator.width) ? "white" : Theme.colorSubText

                    text: {
                        if (value < -20)
                            return " ? ";
                        else {
                            if (value % 1 === 0)
                                return prefix + value + suffix
                            else
                                return prefix + value.toFixed(floatprecision) + suffix
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

                IconSvg {
                    id: warningIndicator
                    width: hhh - 2
                    height: hhh - 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 4
                    anchors.left: {
                        if (item_data.width > indicator.width)
                            return parent.right
                        else
                            return textIndicator.right
                    }

                    color: Theme.colorRed
                    opacity: (warning && value > -20 && value < limitMin) ? 1 : 0
                    Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
                    source: "qrc:/assets/icons_material/baseline-warning-24px.svg"

                    Rectangle {
                        width: hhh
                        height: hhh
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: -1
                        color: dataBarSolid.colorBackground
                        visible: (parent.opacity === 1)
                    }
                }
            }

            ////////
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
