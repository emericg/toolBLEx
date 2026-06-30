// UtilsNumber.js
.pragma library

/* ************************************************************************** */

/*!
 * Map a number from range [srcMin, srcMax] to [dstMin, dstMax]
 * \param n: number to map
 * \param srcMin: start of the range n is from
 * \param srcMax: end of the range n is from
 * \param dstMin: start of the range to map n to
 * \param dstMax: end of the range to map n to
 * \param checks: clamp n to [srcMin, srcMax] before mapping (default true)
 *
 * example: mapNumber(5, 0, 10, 100, 200) => 150
 */
function mapNumber(n, srcMin, srcMax, dstMin, dstMax, checks = true) {
    if (srcMax === srcMin) return dstMin
    if (checks) {
        var lo = Math.min(srcMin, srcMax)
        var hi = Math.max(srcMin, srcMax)
        if (n < lo) n = lo
        if (n > hi) n = hi
    }
    return (dstMin + ((n - srcMin) * (dstMax - dstMin)) / (srcMax - srcMin))
}

/*!
 * Normalize n into [0, 1] relative to [min, max]
 * \param n: number to normalize
 * \param min: start of the range
 * \param max: end of the range
 *
 * example: normalize(5, 0, 10) => 0.5
 */
function normalize(n, min, max) {
    if (n <= min) return 0
    if (n >= max) return 1
    return ((n - min) / (max - min))
}

/*!
 * Clamp n between min and max
 *
 * example: clamp(15, 0, 10) => 10
 */
function clamp(n, min, max) {
    return Math.max(min, Math.min(n, max));
}

/*!
 * Round a number to a given count of decimals
 * \param n: number to round
 * \param decimals: number of decimals to keep (default 0)
 *
 * example: roundTo(154.54645698, 3) => 154.546
 */
function roundTo(n, decimals = 0) {
    const p = Math.pow(10, decimals);
    return Math.round(n * p) / p;
}

/*!
 * Align n up to the next multiple of r
 * \param n: value to align
 * \param r: alignment step (any positive number)
 *
 * example: alignTo(13, 2) => 14 / alignTo(13, 8) => 16 / alignTo(16, 8) => 16
 */
function alignTo(n, r) {
    if (r <= 0) return n;
    return Math.ceil(n / r) * r;
}

/*!
 * Align n up to the next even number (multiple of two)
 */
function alignToEven(n) {
    return Math.ceil(n / 2) * 2;
}

/*!
 * Align n up to the next multiple of r, faster than alignTo(), BUT:
 * - 'r' MUST be a power of two
 * - 'n' will be truncated to 32 bits (because of bitwise ops)
 *
 * example: alignToPow2(13, 8) => 16 / alignToPow2(16, 8) => 16
 */
function alignToPow2(n, r) {
    return (n + (r - 1)) & ~(r - 1);
}

/*!
 * Linear interpolation between a and b, with t usually in [0, 1]
 *
 * example: lerp(100, 200, 0.5) => 150
 */
function lerp(a, b, t) {
    return a + (b - a) * t;
}

/*!
 * Euclidean modulo
 */
function mod(n, modulo) {
    return ((n % modulo) + modulo) % modulo;
}

/*!
 * Random integer in [min, max]
 *
 * example: randomInt(1, 6) => 4
 */
function randomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
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

/*!
 * Haversine distance between two coordinates, as a linear distance in kilometers.
 */
function haversine_km(lat1, long1, lat2, long2) {
    var dlong = degToRad(long2 - long1);
    var dlat = degToRad(lat2 - lat1);
    var a = Math.pow(Math.sin(dlat / 2.0), 2) +
            Math.cos(degToRad(lat1)) * Math.cos(degToRad(lat2)) * Math.pow(Math.sin(dlong / 2.0), 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return (6367 * c);
}

/*!
 * Haversine distance between two coordinates, as a linear distance in miles.
 */
function haversine_mi(lat1, long1, lat2, long2) {
    var dlong = degToRad(long2 - long1);
    var dlat = degToRad(lat2 - lat1);
    var a = Math.pow(Math.sin(dlat / 2.0), 2) +
            Math.cos(degToRad(lat1)) * Math.cos(degToRad(lat2)) * Math.pow(Math.sin(dlong / 2.0), 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return (3956 * c);
}

/* ************************************************************************** */
