import QtQuick

Item {
    id: control

    clip: true

    ////////

    property color colorBackground: "#1a1a1a"
    property color colorStripe: "#f2c21a"

    property real stripeAngle: 45
    property real stripeWidth: 40
    property real stripeSpacing: 40

    property bool animated: false
    property int animationDuration: 2000

    property bool antialiasing: false

    ////////

    readonly property real pitch: control.stripeWidth + control.stripeSpacing

    readonly property real stripeThickness: Math.max(1, control.stripeWidth * Math.cos(Math.min(Math.abs(control.stripeAngle), 80) * Math.PI / 180))

    readonly property real overhang: control.height * 2

    readonly property int stripeCount: Math.ceil((control.width + 2 * control.overhang) / control.pitch) + 1

    property real stripeOffset: 0

    NumberAnimation on stripeOffset {
        running: control.animated && control.visible
        loops: Animation.Infinite

        from: 0
        to: control.pitch
        duration: control.animationDuration
    }

    ////////

    Rectangle {
        anchors.fill: parent
        color: control.colorBackground
    }

    Repeater {
        model: control.stripeCount

        Rectangle {
            x: index * control.pitch - control.overhang + control.stripeOffset
            y: (control.height - height) / 2

            width: control.stripeThickness
            height: control.height * 3

            color: control.colorStripe
            rotation: control.stripeAngle
            antialiasing: control.antialiasing
        }
    }

    ////////
}
