import QtQuick

/*!
 * \brief Pointer input of the color surfaces, emits dragged(x, y) on press and while dragging.
 *
 * With `outerRadius` set, presses outside of the [innerRadius, outerRadius] ring,
 * centered on the area, are left to the items below.
 * Once started, a drag keeps tracking wherever the pointer goes.
 */
MouseArea {
    property real innerRadius: 0
    property real outerRadius: -1 // negative: the whole area accepts presses

    signal dragged(real x, real y)

    preventStealing: true // keeps vertical drags when inside a Flickable

    onPressed: (mouse) => {
        if (outerRadius >= 0) {
            const r = Math.hypot(mouse.x - width / 2, mouse.y - height / 2)
            if (r < innerRadius || r > outerRadius) { mouse.accepted = false; return }
        }
        dragged(mouse.x, mouse.y)
    }
    onPositionChanged: (mouse) => dragged(mouse.x, mouse.y)
}
