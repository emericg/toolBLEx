// UtilsNumber.js
// Version 9
.pragma library

/* ************************************************************************** */

/*!
 * Pad a number
 * \param n: number to pad
 * \param width: width after padding (default 2)
 * \param z: character to insert (default '0')
 *
 * example: padNumber(2, 3, 'x') => xx2
 */
function padNumber(n, width, z) {
    z = z || '0';
    width = width || 2;

    n = n + '';
    return (n.length >= width) ? n : new Array(width - n.length + 1).join(z) + n;
}

/*!
 * Trim a number
 * \param n: number to trim
 * \param p: defines number of digit after coma
 *
 * example: trimNumber(154.54645698, 100000) => 154.54645
 */
function trimNumber(n, p) {
    p = p || 100000;

    return (Math.round(n * p)) / p;
}

/*!
 * Map a number from one range to another
 * \param n: number to map
 * \param a1: start of the range n is from
 * \param a2: end of the range n is from
 * \param b1: start of the range to map n to
 * \param b2: end of the range to map n to
 *
 * example: mapNumber(5, 0, 10, 100, 200) => 150
 */
function mapNumber(n, a1, a2, b1, b2) {
    if (n < a1) n = a1;
    if (n > a2) n = a2;

    return (b1 + ((n-a1) * (b2-b1)) / (a2-a1));
}

function mapNumber_nocheck(n, a1, a2, b1, b2) {
    return (b1 + ((n-a1) * (b2-b1)) / (a2-a1));
}

/*!
 * Normalize n between min and max
 */
function normalize(n, min, max) {
    if (n <= 0) return 0
    return Math.min(((n - min) / (max - min)), 1)
}

/*!
 * Align n to the closest r
 */
function alignTo(n, r) {
    return (n + (r - 1)) & ~(r - 1);
}

/*!
 * Round n to a multiple of two
 */
function round2(n) {
    return Math.ceil(n / 2) * 2;
}

/*!
 * Euclidean modulo
 */
function mod(n, modulo) {
    var m = ((n % modulo) + modulo) % modulo;
    return m < 0 ? m + Math.abs(modulo) : m;
}

/* ************************************************************************** */

/*!
 * Return true if n is an int
 */
function isInt(n) {
    return Number(n) === n && n % 1 === 0;
}

/*!
 * Return true if n is a float
 */
function isFloat(n) {
    return Number(n) === n && n % 1 !== 0;
}

/*!
 * Return true if n is an even number
 */
function isEven(n) {
    return n % 2 === 0;
}

/*!
 * Return true if n is an odd number
 */
function isOdd(n) {
    return n % 2 !== 0;
}

/* ************************************************************************** */

function radToDeg(radian) {
    return radian * (180/Math.PI);
}

function degToRad(degree) {
    return degree * (Math.PI/180);
}

/* ************************************************************************** */

/*!
 * Fahrenheit to Celsius conversion
 */
function tempFahrenheitToCelsius(temp_f) {
    return (temp_f - 32) / 1.8;
}

/*!
 * Celsius to Fahrenheit conversion
 */
function tempCelsiusToFahrenheit(temp_c) {
    return (temp_c * 1.8 + 32);
}

/*!
 * Celsius to Fahrenheit conversion, if needed
 */
function tempCelsiusOrFahrenheit(temp_c, unit) {
    if (unit === 0) return temp_c
    return (temp_c * 1.8 + 32);
}
/*!
 * Fahrenheit to Celsius conversion, if needed
 */
function tempFahrenheitOrCelsius(temp_f, unit) {
    if (unit !== 0) return temp_f
    return (temp_f - 32) / 1.8;
}

/*!
 * Kilogramme to Pound conversion
 */
function weightKiloToPound(weight_kg) {
    return (weight_kg * 2.20462262185);
}

/*!
 * Pound to Kilogramme conversion
 */
function weightPoundToKilog(weight_lb) {
    return (weight_lb / 2.20462262185);
}

/* ************************************************************************** */
