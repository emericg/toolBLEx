import QtQuick

MouseArea {
    preventStealing: false
    propagateComposedEvents: false

    property real prevX: 0
    property real prevY: 0
    property real velocityX: 0.0
    property real velocityY: 0.0
    property real startX: 0
    property real startY: 0
    property bool tracing: false

    property real velocityThreshold: 15
    property real edgeGuard: 0.25

    signal swipeLeft()
    signal swipeRight()
    signal swipeUp()
    signal swipeDown()

    onPressed: (mouse) => {
        startX = mouse.x
        startY = mouse.y
        prevX = mouse.x
        prevY = mouse.y
        velocityX = 0
        velocityY = 0
        tracing = true
    }

    onPositionChanged: (mouse) => {
        if (!tracing) return
        var currVelX = (mouse.x - prevX)
        var currVelY = (mouse.y - prevY)

        velocityX = (velocityX + currVelX) / 2.0
        velocityY = (velocityY + currVelY) / 2.0

        prevX = mouse.x
        prevY = mouse.y

        if (velocityX > velocityThreshold && mouse.x > width * edgeGuard) {
            tracing = false
            swipeRight()
        } else if (velocityX < -velocityThreshold && mouse.x < width * (1 - edgeGuard)) {
            tracing = false
            swipeLeft()
        } else if (velocityY > velocityThreshold && mouse.y > height * edgeGuard) {
            tracing = false
            swipeDown()
        } else if (velocityY < -velocityThreshold && mouse.y < height * (1 - edgeGuard)) {
            tracing = false
            swipeUp()
        }
    }

    onReleased: { tracing = false }
    onCanceled: { tracing = false }
}
