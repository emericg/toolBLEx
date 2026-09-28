// UtilsColor.js
.pragma library

.import ComponentLibrary 1.0 as ComponentLibrary

// Color helpers, working on:
// - QML color types
// - strings ("#rrggbb", "transparent", ...)

/* ************************************************************************** */

/*!
 * Coerce a color argument to a proper QML color, so strings are accepted too.
 */
function _color(c) {
    return (typeof c === "string") ? Qt.color(c) : c
}

function luminance(c) {
    return luminance601(c)
}

/*!
 * Perceived luminance of a color, 0 (black) to 1 (white).
 * Uses the classical Rec.601 weights (0.299 / 0.587 / 0.114).
 */
function luminance601(c) {
    c = _color(c)
    return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
}

/*!
 * Perceived luminance of a color, 0 (black) to 1 (white).
 * Uses the Rec.709 weights (0.2126 / 0.7152 / 0.0722).
 */
function luminance709(c) {
    c = _color(c)
    return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
}

/*!
 * True when color c is dark enough that a light color reads better on it.
 * \param threshold: luminance cut-off (default 0.8)
 */
function isDark(c, threshold) {
    return luminance(c) < ((threshold === undefined) ? 0.8 : threshold)
}

/*!
 * True when color c is light enough that a dark color reads better on it.
 * \param threshold: luminance cut-off (default 0.8)
 */
function isLight(c, threshold) {
    return luminance(c) > ((threshold === undefined) ? 0.8 : threshold)
}

/* ************************************************************************** */

/*!
 * Blend color c toward white.
 */
function lighten(c, t) {
    c = _color(c)
    return Qt.rgba(c.r + (1.0 - c.r) * t, c.g + (1.0 - c.g) * t, c.b + (1.0 - c.b) * t, c.a)
}

/*!
 * Blend color c toward black.
 */
function darken(c, t) {
    c = _color(c)
    return Qt.rgba(c.r * (1.0 - t), c.g * (1.0 - t), c.b * (1.0 - t), c.a)
}

/*!
 * Apply alpha to color c.
 */
function opacify(c, a) {
    c = _color(c)
    return Qt.rgba(c.r, c.g, c.b, a)
}

/*!
 * Emphasize color c: lift a dark color toward white, sink a light one toward black.
 * \param lightAmount: blend toward white when c is dark (default 0.22)
 * \param darkAmount: blend toward black when c is light (default 0.15)
 */
function emphasize(c, lightAmount, darkAmount) {
    lightAmount = (lightAmount === undefined) ? 0.22 : lightAmount
    darkAmount = (darkAmount === undefined) ? 0.15 : darkAmount

    return isDark(c) ? lighten(c, lightAmount) : darken(c, darkAmount)
}

/*!
 * Choose a color for texts / icons that reads well on the given background.
 * \param threshold: luminance threshold above which dark color is chosen (default 0.8)
 * \param darkColor: color for light backgrounds (default near-black)
 * \param lightColor: color for dark backgrounds (default white)
 */
function contrastColor(c, threshold, darkColor, lightColor) {
    threshold = (threshold === undefined) ? 0.8 : threshold
    darkColor = (darkColor === undefined) ? Qt.rgba(0.12, 0.12, 0.12, 1.0) : darkColor
    lightColor = (lightColor === undefined) ? Qt.rgba(1.0, 1.0, 1.0, 1.0) : lightColor

    return (luminance(c) > threshold) ? darkColor : lightColor
}

/*!
 * Same as contrastColor() function, but using ThemeEngine "contrast" colors.
 */
function contrastColorThemed(c, threshold) {
    threshold = (threshold === undefined) ? 0.8 : threshold

    var darkColor = ComponentLibrary.Theme.isLight ? ComponentLibrary.Theme.colorHighContrast
                                                   : ComponentLibrary.Theme.colorLowContrast
    var lightColor = ComponentLibrary.Theme.isLight ? ComponentLibrary.Theme.colorLowContrast
                                                    : ComponentLibrary.Theme.colorHighContrast

    return (luminance(c) > threshold) ? darkColor : lightColor
}

/* ************************************************************************** */

/*!
 * Serialize a color to a "#rrggbb" (or "#rrggbbaa") hex string.
 * \param withAlpha: append the alpha pair when true (default false)
 */
function colorToHex(c, withAlpha) {
    c = _color(c)
    function h2(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s }
    var hex = "#" + h2(c.r) + h2(c.g) + h2(c.b)
    if (withAlpha) hex += h2(c.a)
    return hex
}

/*!
 * Parse "#rgb" / "#rgba" / "#rrggbb" / "#rrggbbaa" (with or without a leading '#').
 * \param withAlpha: honour the trailing alpha pair when true (default false)
 * \return Returns null on a malformed string
 */
function parseHex(s, withAlpha) {
    s = ("" + s).trim()
    if (s.length && s[0] === "#") s = s.substring(1)
    if (s.length === 3 || s.length === 4) {
        var d = ""
        for (var i = 0; i < s.length; i++) d += s[i] + s[i]
        s = d
    }
    if (!/^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(s)) return null
    var a = (s.length === 8 && withAlpha) ? parseInt(s.substring(6, 8), 16) / 255 : 1.0
    return Qt.rgba(parseInt(s.substring(0, 2), 16) / 255,
                   parseInt(s.substring(2, 4), 16) / 255,
                   parseInt(s.substring(4, 6), 16) / 255, a)
}

/*!
 * Parse a hex string (see parseHex) or a CSS/SVG color name ("teal", "rebeccapurple").
 * Named colors come back opaque: Qt returns a transparent color for unknown names, which is how failure is detected.
 * \param withAlpha: forwarded to parseHex for the hex form (default false)
 * \return Returns null when neither matches
 */
function parseColor(s, withAlpha) {
    s = ("" + s).trim()
    var hex = parseHex(s, withAlpha)
    if (hex) return hex
    if (/^[a-zA-Z]+$/.test(s)) {
        var c = Qt.color(s.toLowerCase())
        if (c.a > 0) return Qt.rgba(c.r, c.g, c.b, 1.0)
    }
    return null
}

/* ************************************************************************** */

/*!
 * WCAG 2.x relative luminance (0..1), computed on linearized sRGB channels.
 * Unlike luminance601() / luminance709(), the channels are gamma-expanded first,
 * so this is the value the WCAG contrast-ratio formula expects.
 */
function wcagLuminance(c) {
    c = _color(c)
    function lin(v) { return (v <= 0.03928) ? (v / 12.92) : Math.pow((v + 0.055) / 1.055, 2.4) }
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b)
}

/*!
 * WCAG contrast ratio between two colors, from 1 (identical) to 21 (black/white).
 */
function wcagContrastRatio(c1, c2) {
    var hi = Math.max(wcagLuminance(c1), wcagLuminance(c2))
    var lo = Math.min(wcagLuminance(c1), wcagLuminance(c2))
    return (hi + 0.05) / (lo + 0.05)
}

/*!
 * WCAG conformance label for a contrast ratio: "AAA", "AA", "AA Large" or "Fail".
 */
function wcagRating(ratio) {
    if (ratio >= 7.0) return "AAA"
    if (ratio >= 4.5) return "AA"
    if (ratio >= 3.0) return "AA Large"
    return "Fail"
}

/* ************************************************************************** */

/*!
 * color-harmony suggestions around an HSV(A) color, keeping S/V/A constant:
 * [ complementary, analogous -30°, analogous +30°, triadic +120°, triadic +240° ].
 */
function harmonies(hue, sat, val, alpha) {
    function at(dh) { return Qt.hsva((hue + dh + 1.0) % 1.0, sat, val, alpha) }
    return [ at(0.5), at(-1/12), at(1/12), at(1/3), at(2/3) ]
}

/* ************************************************************************** */

/*!
 * Map an HSV hue/saturation to a point on a color wheel: hue is the angle, sat the radius.
 * Returns the wheel-space centre { x, y } (no handle-size offset applied).
 */
function hueSatToPoint(hue, sat, cx, cy, radius) {
    var a = hue * 2 * Math.PI
    return { x: cx + Math.cos(a) * sat * radius, y: cy + Math.sin(a) * sat * radius }
}

/*!
 * Inverse of hueSatToPoint: map a wheel-space point back to { hue, sat }.
 * hue is normalized to 0..1 and sat is clamped to 1.0 at the rim.
 */
function pointToHueSat(px, py, cx, cy, radius) {
    var dx = px - cx, dy = py - cy
    var h = Math.atan2(dy, dx) / (2 * Math.PI)
    if (h < 0) h += 1
    return { hue: h, sat: Math.min(1.0, Math.sqrt(dx * dx + dy * dy) / radius) }
}

/* ************************************************************************** */
