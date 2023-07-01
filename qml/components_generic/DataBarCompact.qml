import QtQuick 2.15

//import QtGraphicalEffects 1.15 // Qt5
import Qt5Compat.GraphicalEffects // Qt6

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: dataBarCompact
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
    property string colorText: Theme.colorText
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
            anchors.verticalCenter: item_bg.verticalCenter

            visible: (legend.length)

            text: legend
            textFormat: Text.PlainText
            font.bold: true
            font.pixelSize: Theme.fontSizeContentVerySmall
            font.capitalization: Font.AllUppercase
            color: Theme.colorSubText
            horizontalAlignment: Text.AlignRight
        }

        ////////////////

        Item {
            id: item_bg
            width: dataBarCompact.width - (item_legend.visible ? (item_legend.width + parent.spacing) : 0)
            height: hhh
            anchors.bottom: parent.bottom

            ////////

            Rectangle {
                id: rect_bg
                anchors.fill: parent

                radius: 4
                clip: isDesktop
                color: dataBarCompact.colorBackground

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
                    id: rect_data
                    width: {
                        var res = UtilsNumber.normalize(value, valueMin, valueMax) * rect_bg.width

                        if (value <= valueMin || value >= valueMax)
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
                    color: dataBarCompact.colorForeground

                    Behavior on width { NumberAnimation { duration: animated ? 333 : 0 } }
                }

                Rectangle {
                    id: item_limit_low
                    width: 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    visible: (limitMin > 0 && limitMin > valueMin && limitMin < valueMax)
                    x: UtilsNumber.normalize(limitMin, valueMin, valueMax) * rect_bg.width
                    color: (limitMin < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                    opacity: (limitMin < value) ? 0.66 : 0.33

                    Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
                    Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                    Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
                }
                Rectangle {
                    id: item_limit_high
                    width: 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    visible: (limitMax > 0 && limitMax > valueMin && limitMax < valueMax)
                    x: UtilsNumber.normalize(limitMax, valueMin, valueMax) * rect_bg.width
                    color: (limitMax < value) ? Theme.colorLowContrast : Theme.colorHighContrast
                    opacity: (limitMax < value) ? 0.66 : 0.33

                    Behavior on x { NumberAnimation { duration: animated ? 333 : 0 } }
                    Behavior on color { ColorAnimation { duration: animated ? 333 : 0 } }
                    Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
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
                    color: dataBarCompact.colorForeground

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
                        color: dataBarCompact.colorForeground
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
                opacity: (warning && value > -20 && value < limitMin) ? 1 : 0
                Behavior on opacity { OpacityAnimator { duration: animated ? 333 : 0 } }
                source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
            }

            ////////
        }

        ////////////////
    }
}
