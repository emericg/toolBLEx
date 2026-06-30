import QtQuick

import ComponentLibrary

// Based on the ProgressCircle component from ByteBau (Jörn Buchholz) @bytebau.com

Item {
    id: control
    width: 256
    height: width

    property real value: 0.5
    property real valueMin: 0
    property real valueMax: 1

    property bool isPie: false              // paint a pie instead of an arc

    property real arcOffset: 0              // rotation (0 means starts at top center)
    property real arcWidth: 16              // width of the arc

    property color arcColor: Theme.colorPrimary
    property real arcOpacity: 1
    property string arcCap: "butt"          // "butt", "round", "square" // Qt.FlatCap, Qt.RoundCap, Qt.SquareCap

    property bool background: true          // a full circle as a background of the arc
    property real backgroundOpacity: 1
    property color backgroundColor: Theme.colorForeground

    property bool animation: true
    property int animationDuration: Theme.animationSlowSpeed

    // private
    property real arcBegin: 0
    property real arcEnd: 360
    property real arcValue: UtilsNumber.mapNumber(value, valueMin, valueMax, arcBegin, arcEnd)

    ////////////////////////////////////////////////////////////////////////////

    //onValueMinChanged: canvas.requestPaint()
    //onValueMaxChanged: canvas.requestPaint()
    //onValueChanged: canvas.requestPaint()
    onArcValueChanged: canvas.requestPaint()

    onIsPieChanged: canvas.requestPaint()

    onArcBeginChanged: canvas.requestPaint()
    onArcEndChanged: canvas.requestPaint()
    onArcOffsetChanged: canvas.requestPaint()
    onArcWidthChanged: canvas.requestPaint()
    onArcCapChanged: canvas.requestPaint()
    onArcColorChanged: canvas.requestPaint()
    onArcOpacityChanged: canvas.requestPaint()

    onBackgroundChanged: canvas.requestPaint()
    onBackgroundColorChanged: canvas.requestPaint()
    onBackgroundOpacityChanged: canvas.requestPaint()

    Connections {
        target: Theme
        function onCurrentThemeChanged() { canvas.requestPaint() }
    }

    Behavior on arcBegin {
        enabled: control.animation
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on arcEnd {
        enabled: control.animation
        NumberAnimation {
            duration: control.animationDuration
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on arcValue {
        enabled: control.animation
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
            var y = (height / 2)
            var start = Math.PI * ((control.arcBegin + control.arcOffset - 90) / 180)
            var end = Math.PI * ((control.arcEnd + control.arcOffset - 90) / 180)
            var end_value = Math.PI * ((control.arcValue + control.arcOffset - 90) / 180)

            ctx.reset()
            ctx.lineCap = control.arcCap

            // draw
            if (control.isPie) {
                if (control.background) {
                    ctx.beginPath()
                    ctx.globalAlpha = control.backgroundOpacity
                    ctx.fillStyle = control.backgroundColor
                    ctx.moveTo(x, y)
                    ctx.arc(x, y, (width / 2), start, end, false)
                    ctx.lineTo(x, y)
                    ctx.fill()
                }
                ctx.beginPath()
                ctx.globalAlpha = control.arcOpacity
                ctx.fillStyle = control.arcColor
                ctx.moveTo(x, y)
                ctx.arc(x, y, (width / 2), start, end_value, false)
                ctx.lineTo(x, y)
                ctx.fill()
            } else {
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
    }

    ////////////////////////////////////////////////////////////////////////////
}
