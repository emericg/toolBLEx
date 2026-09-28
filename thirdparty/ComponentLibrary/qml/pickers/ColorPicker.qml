import QtQuick
import QtQuick.Effects
import QtQuick.Controls

import ComponentLibrary

/*!
 * \brief An inline HSV(A) color picker, usable in any layout or inside PopupColors.
 *
 * A swappable picker surface (see pickerStyle), a value / alpha slider,
 * live hex + RGB/HSV/HSL inputs, and optional contrast, harmony, preset and recent swatches.
 * HSV(A) is the source of truth, selectedColor is derived from it.
 * Set a color with loadColor() or setColor(), and read it back with selectedColor.
 */
Column {
    id: colorPicker

    width: 480 // default, Column owns implicitWidth
    spacing: Theme.componentMarginXL

    ////////////////////////////////////////////////////////////////////////////

    // Picker styles: wheel / square / ring / sliders
    property string pickerStyle: "wheel"

    property bool enableAlpha: false
    property bool enablePresets: false
    property bool enableRecents: false
    property bool enableHarmonies: false
    property bool enableContrasts: false

    property var presets: [
        "#F44336", "#9C27B0", "#3F51B5", "#03A9F4",
        "#009688", "#8BC34A", "#FFEB3B", "#FF9800",
        "#795548", "#607D8B",
    ]
    property var presetsFull: [
        "#F44336", "#E91E63", "#9C27B0", "#673AB7",
        "#3F51B5", "#2196F3", "#03A9F4", "#00BCD4",
        "#009688", "#4CAF50", "#8BC34A", "#CDDC39",
        "#FFEB3B", "#FFC107", "#FF9800", "#FF5722",
        "#795548", "#9E9E9E", "#607D8B", "#000000"
    ]
    property var recentColors: []
    property int maxRecents: 8

    // Live color-harmony suggestions derived from the current hue (same S/V/A):
    // complementary, two analogous (±30°) and two triadic (±120°).
    readonly property var harmonies: UtilsColor.harmonies(hue, sat, val, alpha)

    // HSV(A) is the source of truth; the wheel, sliders and fields all read/write it.
    property real hue: 0.0      // 0..1
    property real sat: 0.0      // 0..1
    property real val: 1.0      // 0..1
    property real alpha: 1.0    // 0..1

    property color initialColor: "white"
    readonly property color selectedColor: Qt.hsva(hue, sat, val, alpha)

    ////////////////////////////////////////////////////////////////////////////

    // Guards the field<->state sync so editing a field doesn't loop back onto itself.
    property bool _syncing: false

    // Numeric field mode: "rgb", "hsv" or "hsl". Only the active set is ever built
    // and computed — the other two modes cost nothing until selected.
    property string fieldMode: "rgb"

    // Channel descriptors for the active mode (+ alpha). Re-evaluated only when the
    // mode or the alpha toggle changes; this is the only set the Repeater builds.
    readonly property var channelFields: {
        var base
        if (fieldMode === "hsv")
            base = [ { id: "h", label: qsTr("Hue"), max: 360 },
                     { id: "s", label: qsTr("Sat."), max: 100 },
                     { id: "v", label: qsTr("Value"), max: 100 } ]
        else if (fieldMode === "hsl")
            base = [ { id: "h", label: qsTr("Hue"), max: 360 },
                     { id: "s", label: qsTr("Sat."), max: 100 },
                     { id: "l", label: qsTr("Light"), max: 100 } ]
        else
            base = [ { id: "r", label: qsTr("Red"), max: 255 },
                     { id: "g", label: qsTr("Green"), max: 255 },
                     { id: "b", label: qsTr("Blue"), max: 255 } ]
        if (enableAlpha) base.push({ id: "a", label: qsTr("Alpha"), max: 255 })
        return base
    }

    // id -> TextField registry, populated by the channel Repeater's delegates.
    property var _fields: ({})

    ////////////////////////////////////////////////////////////////////////////

    /*!
     * \brief Loads a color as both the initial (reset target) and the selected color.
     * \param color: a color, or a hex / CSS color name string.
     */
    function loadColor(color) {
        initialColor = color
        setColor(color)
    }

    // Decompose a color into HSV. hsvHue is -1 for greys: keep the current hue
    // so the wheel handle doesn't jump when picking a pure black/white/grey.
    function setColor(color) {
        if (typeof color === "string") color = Qt.color(color) // preset chips pass hex
        if (color.hsvHue >= 0) hue = color.hsvHue
        sat = color.hsvSaturation
        val = color.hsvValue
        alpha = colorPicker.enableAlpha ? color.a : 1.0
        syncFields()
    }

    // reset to the color we opened with
    function resetColor() {
        setColor(initialColor)
    }

    // Prepend a color to the recent list, de-duplicated by hex and capped. The
    // color is snapshotted with Qt.rgba(): reading the selectedColor *property*
    // yields a live reference, so storing it directly would alias every entry to
    // the current color (and the dedup below would then collapse them to one).
    function addRecent(color) {
        if (typeof color === "string") color = Qt.color(color)
        var snap = Qt.rgba(color.r, color.g, color.b, color.a)
        var hex = UtilsColor.colorToHex(snap, colorPicker.enableAlpha)
        var list = []
        for (var i = 0; i < recentColors.length; i++) {
            if (UtilsColor.colorToHex(recentColors[i], colorPicker.enableAlpha) !== hex) list.push(recentColors[i])
        }
        list.unshift(snap)
        if (list.length > maxRecents) list = list.slice(0, maxRecents)
        recentColors = list
    }

    // Push the current color into the text fields (imperative: a plain `text:`
    // binding would be severed the first time the user edits a field).
    // Only the active mode's channels are touched.
    function syncFields() {
        _syncing = true
        fieldHex.text = UtilsColor.colorToHex(selectedColor, colorPicker.enableAlpha)
        for (var i = 0; i < channelFields.length; i++) {
            var id = channelFields[i].id
            if (_fields[id]) _fields[id].text = channelValue(id)
        }
        _syncing = false
    }

    // The integer shown for a channel id, in the units of the active mode. HSL is
    // only read when the HSL fields are actually present.
    function channelValue(id) {
        var c = selectedColor
        switch (id) {
        case "r": return Math.round(c.r * 255)
        case "g": return Math.round(c.g * 255)
        case "b": return Math.round(c.b * 255)
        case "h": return Math.round((fieldMode === "hsl" ? (c.hslHue >= 0 ? c.hslHue : hue) : hue) * 360)
        case "s": return Math.round((fieldMode === "hsl" ? c.hslSaturation : sat) * 100)
        case "v": return Math.round(val * 100)
        case "l": return Math.round(c.hslLightness * 100)
        case "a": return Math.round(alpha * 255)
        }
        return 0
    }

    // Apply an edited channel value (raw integer) back onto the color.
    function applyChannel(id, raw) {
        var c = selectedColor
        if (id === "a") {
            alpha = Math.max(0, Math.min(255, raw)) / 255
            syncFields()
            return
        }
        if (id === "r" || id === "g" || id === "b") {
            var v = Math.max(0, Math.min(255, raw)) / 255
            setColor(Qt.rgba(id === "r" ? v : c.r,
                             id === "g" ? v : c.g,
                             id === "b" ? v : c.b, alpha))
        } else if (fieldMode === "hsl") {
            var lh = (id === "h") ? Math.max(0, Math.min(360, raw)) / 360 : (c.hslHue >= 0 ? c.hslHue : hue)
            var ls = (id === "s") ? Math.max(0, Math.min(100, raw)) / 100 : c.hslSaturation
            var ll = (id === "l") ? Math.max(0, Math.min(100, raw)) / 100 : c.hslLightness
            setColor(Qt.hsla(lh, ls, ll, alpha))
        } else {
            var vh = (id === "h") ? Math.max(0, Math.min(360, raw)) / 360 : hue
            var vs = (id === "s") ? Math.max(0, Math.min(100, raw)) / 100 : sat
            var vv = (id === "v") ? Math.max(0, Math.min(100, raw)) / 100 : val
            setColor(Qt.hsva(vh, vs, vv, alpha))
        }
    }

    onHueChanged: if (!_syncing) syncFields()
    onSatChanged: if (!_syncing) syncFields()
    onValChanged: if (!_syncing) syncFields()
    onAlphaChanged: if (!_syncing) syncFields()

    ////////////////////////////////////////////////////////////////////////////

    Item { // wheel + preview swatch
        anchors.left: parent.left
        anchors.right: parent.right
        height: 240

        Loader { // the active picker surface, see ColorSurface for the contract
            id: surfaceLoader
            width: height
            height: parent.height
            anchors.left: parent.left

            sourceComponent: {
                switch (colorPicker.pickerStyle) {
                case "square":  return squareSurface
                case "ring":    return ringSurface
                case "sliders": return slidersSurface
                default:        return wheelSurface
                }
            }
            onLoaded: {
                item.hue = Qt.binding(() => colorPicker.hue)
                item.sat = Qt.binding(() => colorPicker.sat)
                item.val = Qt.binding(() => colorPicker.val)
            }
        }
        Connections {
            target: surfaceLoader.item
            function onPicked(h, s, v) { colorPicker.hue = h; colorPicker.sat = s; colorPicker.val = v }
        }

        Component { id: wheelSurface; ColorSurfaceWheel { } }
        Component { id: squareSurface; ColorSurfaceSquare { } }
        Component { id: ringSurface; ColorSurfaceRingSquare { } }
        Component { id: slidersSurface; ColorSurfaceSliders { } }

        Column { // before / after preview: opening color over live selection
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: parent.height
            spacing: Theme.componentMarginS

            AlphaSwatch { // color we opened with
                width: parent.width
                height: (parent.height - parent.spacing) / 2
                swatchColor: colorPicker.initialColor
            }
            AlphaSwatch { // live selection
                width: parent.width
                height: (parent.height - parent.spacing) / 2
                swatchColor: colorPicker.selectedColor
            }
        }
    }

    ////////

    ColorSurfaceSlider { // value (brightness): black -> full value
        anchors.left: parent.left
        anchors.right: parent.right

        Accessible.name: qsTr("Brightness")
        value: colorPicker.val
        barGradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: Qt.hsva(colorPicker.hue, colorPicker.sat, 1.0, 1.0) }
        }
        onMoved: colorPicker.val = value
    }

    ////////

    ColorSurfaceSlider { // alpha (opacity): transparent -> opaque
        anchors.left: parent.left
        anchors.right: parent.right
        visible: colorPicker.enableAlpha

        Accessible.name: qsTr("Opacity")
        checkered: true
        value: colorPicker.alpha
        barGradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.hsva(colorPicker.hue, colorPicker.sat, colorPicker.val, 0.0) }
            GradientStop { position: 1.0; color: Qt.hsva(colorPicker.hue, colorPicker.sat, colorPicker.val, 1.0) }
        }
        onMoved: colorPicker.alpha = value
    }

    ////////////////

    Row { // hex + channel inputs
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMarginXL
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMarginXL
        spacing: Theme.componentMargin

        property int fieldCount: 1 + colorPicker.channelFields.length // hex + channels
        property int fieldW: (width - spacing * (fieldCount - 1)) / fieldCount

        Column {
            spacing: 2

            TextFieldThemed {
                id: fieldHex
                width: parent.parent.fieldW
                height: Theme.componentHeight
                maximumLength: 22 // fits #RRGGBBAA and long CSS names
                onEditingFinished: {
                    if (colorPicker._syncing) return
                    var col = UtilsColor.parseColor(text, colorPicker.enableAlpha) // hex or CSS name
                    if (col) colorPicker.setColor(col)
                    else colorPicker.syncFields() // malformed -> revert to canonical
                }

                RoundButtonClear { // copy the hex value to the clipboard
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 6
                    height: parent.height - 6

                    visible: Theme.isDesktop
                    color: Theme.colorSubText
                    source: "qrc:/IconLibrary/material-symbols/content_copy.svg"

                    TextEdit {
                        id: clipboardHelper
                        visible: false
                        function copyText(t) { text = t; selectAll(); copy() }
                    }

                    onClicked: clipboardHelper.copyText(fieldHex.text)
                }
            }
            Text {
                text: qsTr("Hex")
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorSubText
            }
        }

        Repeater {
            model: colorPicker.channelFields

            Column {
                spacing: 2
                required property var modelData

                TextFieldThemed {
                    width: parent.parent.fieldW
                    height: Theme.componentHeight
                    maximumLength: 3
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0; top: modelData.max }

                    // Register and self-initialise, so switching mode fills the
                    // freshly built fields without recomputing the other modes.
                    Component.onCompleted: {
                        colorPicker._fields[modelData.id] = this
                        text = colorPicker.channelValue(modelData.id)
                    }

                    onEditingFinished: {
                        if (colorPicker._syncing) return
                        colorPicker.applyChannel(modelData.id, parseInt(text) || 0)
                    }
                }
                Text {
                    text: modelData.label
                    font.pixelSize: Theme.fontSizeContentSmall
                    color: Theme.colorSubText
                }
            }
        }
    }

    ////////////////

    Row { // WCAG contrast readout: selected color as text over white / black
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Theme.componentMarginXL

        visible: colorPicker.enableContrasts

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Contrast")
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorSubText
        }
        ContrastBadge { background: "#ffffff"; foreground: colorPicker.selectedColor }
        ContrastBadge { background: "#000000"; foreground: colorPicker.selectedColor }
    }

    ////////////////

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Theme.componentMarginXS

        ////////

        Column { // Harmony
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginXS

            visible: colorPicker.enableHarmonies

            Text {
                text: qsTr("Harmony")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Flow {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXS

                Repeater {
                    model: colorPicker.harmonies
                    ColorChip {
                        chipColor: modelData
                        onClicked: colorPicker.setColor(modelData)
                    }
                }
            }
        }

        ////////

        Column { // Presets
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginXS

            visible: colorPicker.enablePresets

            Text {
                text: qsTr("Presets")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
            }
            Flow {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginXS

                Repeater {
                    model: colorPicker.presets
                    ColorChip {
                        chipColor: modelData
                        onClicked: colorPicker.setColor(modelData)
                    }
                }
            }
        }

        ////////

        Column { // Recents
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.componentMarginS

            visible: colorPicker.enableRecents

            Text {
                text: qsTr("Recent(s)")
                textFormat: Text.PlainText
                font.pixelSize: Theme.fontSizeContent
                color: Theme.colorSubText
                visible: (colorPicker.recentColors.length > 0)
            }
            Flow {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.componentMarginS
                visible: (colorPicker.recentColors.length > 0)

                Repeater {
                    model: colorPicker.recentColors
                    ColorChip {
                        chipColor: modelData
                        onClicked: colorPicker.setColor(modelData)
                    }
                }
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    // A rounded color swatch over a checkerboard, so translucent colors read right.
    component AlphaSwatch : Item {
        id: swRoot
        property color swatchColor: "black"
        property real radius: Theme.componentRadius

        Item {
            id: swInner
            anchors.fill: parent

            ColorCheckerBoard { anchors.fill: parent; active: swRoot.swatchColor.a < 1.0 }
            Rectangle { anchors.fill: parent; color: swRoot.swatchColor }

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: swInner.width
                        height: swInner.height
                        radius: swRoot.radius
                    }
                }
            }
        }

        Rectangle { // border
            anchors.fill: parent
            radius: swRoot.radius
            color: "transparent"
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    // A small clickable color chip used in the presets / recent rows.
    component ColorChip : Rectangle {
        id: chipRoot
        property color chipColor: "white"
        signal clicked()

        implicitWidth: 32
        implicitHeight: 32
        radius: Theme.componentRadius
        color: chipColor
        border.color: chipMouse.containsMouse ? Theme.colorPrimary : Theme.colorSeparator
        border.width: chipMouse.containsMouse ? 2 : Theme.componentBorderWidth

        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: chipRoot.clicked()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    // A WCAG contrast sample: the selected color as text over a reference background,
    // with the contrast ratio and its rating (AAA / AA / AA Large / Fail).
    component ContrastBadge : Row {
        id: cbRoot
        property color background: "white"
        property color foreground: "black"
        readonly property real ratio: UtilsColor.wcagContrastRatio(foreground, background)

        spacing: Theme.componentMarginS

        Rectangle {
            width: 40
            height: Theme.componentHeight
            radius: Theme.componentRadius
            color: cbRoot.background
            border.color: Theme.colorSeparator
            border.width: Theme.componentBorderWidth

            Text {
                anchors.centerIn: parent
                text: "Aa"
                font.pixelSize: Theme.fontSizeContentBig
                font.bold: true
                color: cbRoot.foreground
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: cbRoot.ratio.toFixed(2) + " : 1"
                font.pixelSize: Theme.fontSizeContentSmall
                color: Theme.colorText
            }
            Text {
                text: UtilsColor.wcagRating(cbRoot.ratio)
                font.pixelSize: Theme.fontSizeContentSmall
                font.bold: true
                color: (cbRoot.ratio >= 4.5) ? Theme.colorSuccess
                                             : (cbRoot.ratio >= 3.0) ? Theme.colorWarning
                                                                     : Theme.colorError
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
