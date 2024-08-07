import QtQuick

import ThemeEngine

// Based on the ProgressCircle component from ByteBau (Jörn Buchholz) @bytebau.com

Item {
    id: control
    width: 256
    height: width

    property real value: 0.5
    property real valueMin: 0
    property real valueMax: 1

    property real arcOffset: 0              // rotation (0 means starts at bottom center)
    property real arcSpan: 270              // arc span (in degree)
    property real arcWidth: 16              // width of the arc (in pixel)

    property color arcColor: Theme.colorPrimary
    property real arcOpacity: 1
    property string arcCap: "butt"          // "butt", "round", "square" // Qt.FlatCap, Qt.RoundCap, Qt.SquareCap

    property bool background: true          // draw a background arc (full arc span)
    property real backgroundOpacity: 1
    property color backgroundColor: Theme.colorForeground

    property alias animation: animationArcValue.enabled
    property int animationDuration: 333

    // private
    property real arcBegin: ((360 - arcSpan) / 2)
    property real arcEnd: (360 - arcBegin)
    property real arcValue: mapNumber(value, valueMin, valueMax, arcBegin, arcEnd)

    function mapNumber(n, srcMin, srcMax, dstMin, dstMax) {
        if (n < srcMin) n = srcMin
        if (n > srcMax) n = srcMax
        return (dstMin + ((n - srcMin) * (dstMax - dstMin)) / (srcMax - srcMin))
    }

    ////////////////////////////////////////////////////////////////////////////

    //onValueMinChanged: canvas.requestPaint()
    //onValueMaxChanged: canvas.requestPaint()
    //onValueChanged: canvas.requestPaint()
    onArcValueChanged: canvas.requestPaint()

    onArcSpanChanged: canvas.requestPaint()
    onArcWidthChanged: canvas.requestPaint()
    onArcColorChanged: canvas.requestPaint()
    onArcOpacityChanged: canvas.requestPaint()

    onBackgroundChanged: canvas.requestPaint()
    onBackgroundColorChanged: canvas.requestPaint()
    onBackgroundOpacityChanged: canvas.requestPaint()

    Connections {
        target: ThemeEngine
        function onCurrentThemeChanged() { canvas.requestPaint() }
    }

    Behavior on arcBegin {
        id: animationArcBegin
        enabled: true
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on arcEnd {
        id: animationArcEnd
        enabled: true
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on arcValue {
        id: animationArcValue
        enabled: true
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.InOutCubic
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            var x = (width / 2)
            var y = (width / 2)
            var start = Math.PI * ((control.arcBegin + control.arcOffset + 90) / 180)
            var end = Math.PI * ((control.arcEnd + control.arcOffset + 90) / 180)
            var end_value = Math.PI * ((control.arcValue + control.arcOffset + 90) / 180)

            ctx.reset()
            ctx.lineCap = control.arcCap

            // draw
            if (control.background) {
                ctx.beginPath()
                ctx.globalAlpha = control.backgroundOpacity
                ctx.arc(x, y, (width / 2) - (control.arcWidth / 2), start, end, false)
                ctx.lineWidth = control.arcWidth
                ctx.strokeStyle = control.backgroundColor
                ctx.stroke()
            }
            ctx.beginPath()
            ctx.globalAlpha = control.arcOpacity
            ctx.arc(x, y, (width / 2) - (control.arcWidth / 2), start, end_value, false)
            ctx.lineWidth = control.arcWidth
            ctx.strokeStyle = control.arcColor
            ctx.stroke()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
