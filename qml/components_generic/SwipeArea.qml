import QtQuick 2.15

MouseArea {
    preventStealing: false
    propagateComposedEvents: false

    property real prevX: 0
    property real prevY: 0
    property real velocityX: 0.0
    property real velocityY: 0.0
    property int startX: 0
    property int startY: 0
    property bool tracing: false

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

        if (velocityX > 15 && mouse.x > width * 0.25) {
            tracing = false
            swipeRight()
        } else if (velocityX < -15 && mouse.x < width * 0.75) {
            tracing = false
            swipeLeft()
        } else if (velocityY > 15 && mouse.y > height * 0.25) {
            tracing = false
            swipeDown()
        } else if (velocityY < -15 && mouse.y < height * 0.75) {
            tracing = false
            swipeUp()
        }
    }
}
