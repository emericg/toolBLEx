import QtQuick

/*!
 * \brief Light / dark checkerboard, shown behind translucent colors so alpha reads.
 *
 * Cells are only built while `active`, set it to false when the color on top is opaque.
 */
Item {
    id: root

    property int cell: 8
    property bool active: true

    readonly property int _cols: Math.max(1, Math.ceil(width / cell) + 1)
    readonly property int _rows: Math.max(1, Math.ceil(height / cell) + 1)

    clip: true

    Grid {
        columns: root._cols

        Repeater {
            model: root.active ? (root._cols * root._rows) : 0

            Rectangle {
                required property int index
                width: root.cell
                height: root.cell
                color: ((Math.floor(index / root._cols) + (index % root._cols)) % 2 === 0) ? "#ffffff" : "#cccccc"
            }
        }
    }
}
