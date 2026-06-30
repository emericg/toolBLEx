/*!
 * Copyright (c) 2018 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef UTILS_MATHS_H
#define UTILS_MATHS_H
/* ************************************************************************** */

#include <algorithm>
#include <cmath>
#include <random>
#include <type_traits>

/* ************************************************************************** */

/*!
 * \brief Map a number from range [srcMin, srcMax] to [dstMin, dstMax]
 * \param n: number to map
 * \param srcMin: start of the range n is from
 * \param srcMax: end of the range n is from
 * \param dstMin: start of the range to map n to
 * \param dstMax: end of the range to map n to
 * \param checks: clamp n to [srcMin, srcMax] before mapping (default true)
 *
 * Note: for integral T the division truncates (use a floating T for exact results)
 *
 * example: mapNumber(5, 0, 10, 100, 200) => 150
 */
template<typename T>
T mapNumber(T n, T srcMin, T srcMax, T dstMin, T dstMax, bool checks = true)
{
    if (srcMax == srcMin) return dstMin;
    if (checks)
    {
        const T lo = std::min(srcMin, srcMax);
        const T hi = std::max(srcMin, srcMax);
        if (n < lo) n = lo;
        if (n > hi) n = hi;
    }
    return dstMin + ((n - srcMin) * (dstMax - dstMin)) / (srcMax - srcMin);
}

/*!
 * \brief Normalize n into [0, 1] relative to [min, max]
 * \param n: number to normalize
 * \param min: start of the range
 * \param max: end of the range
 *
 * example: normalize(5, 0, 10) => 0.5
 */
template<typename T>
double normalize(T n, T min, T max)
{
    if (n <= min) return 0.0;
    if (n >= max) return 1.0;
    return static_cast<double>(n - min) / static_cast<double>(max - min);
}

//! Clamp n between min and max
//! example: clamp(15, 0, 10) => 10
template<typename T>
T clamp(T n, T min, T max)
{
    if (n < min) return min;
    if (n > max) return max;
    return n;
}

//! Round a number to a given count of decimals (default 0)
//! example: roundTo(154.54645698, 3) => 154.546
template<typename T>
T roundTo(T n, int decimals = 0)
{
    const T p = std::pow(static_cast<T>(10), decimals);
    return std::round(n * p) / p;
}

//! Align n up to the next multiple of r (any positive r)
//! example: alignTo(13, 2) => 14 / alignTo(13, 8) => 16
template<typename T>
T alignTo(T n, T r)
{
    if (r <= static_cast<T>(0)) return n;
    return static_cast<T>(std::ceil(static_cast<double>(n) / static_cast<double>(r)) * static_cast<double>(r));
}

//! Align n up to the next even number (multiple of two)
template<typename T>
T alignToEven(T n)
{
    return static_cast<T>(std::ceil(static_cast<double>(n) / 2.0) * 2.0);
}

//! Align n up to the next multiple of r, faster than alignTo() BUT 'r' MUST be a power of two
//! example: alignToPow2(13, 8) => 16 / alignToPow2(16, 8) => 16
template<typename T>
T alignToPow2(T n, T r)
{
    static_assert(std::is_integral_v<T>, "alignToPow2() expects an integral type");
    return (n + (r - 1)) & ~(r - 1);
}

//! Linear interpolation between a and b, with t usually in [0, 1]
//! example: lerp(100, 200, 0.5) => 150
template<typename T>
T lerp(T a, T b, T t)
{
    return a + (b - a) * t;
}

//! Euclidean modulo
template<typename T>
T mod(T n, T modulo)
{
    if constexpr (std::is_integral_v<T>)
        return ((n % modulo) + modulo) % modulo;
    else
        return std::fmod(std::fmod(n, modulo) + modulo, modulo);
}

/* ************************************************************************** */

template<typename T>
T radToDeg(T radian)
{
    return radian * (static_cast<T>(180) / static_cast<T>(M_PI));
}

template<typename T>
T degToRad(T degree)
{
    return degree * (static_cast<T>(M_PI) / static_cast<T>(180));
}

/* ************************************************************************** */

//! Fahrenheit to Celsius conversion
template<typename T>
T tempFahrenheitToCelsius(T temp_f)
{
    return (temp_f - static_cast<T>(32)) / static_cast<T>(1.8);
}

//! Celsius to Fahrenheit conversion
template<typename T>
T tempCelsiusToFahrenheit(T temp_c)
{
    return temp_c * static_cast<T>(1.8) + static_cast<T>(32);
}

//! Kilogram to Pound conversion
template<typename T>
T weightKiloToPound(T weight_kg)
{
    return weight_kg * static_cast<T>(2.20462262185);
}

//! Pound to Kilogram conversion
template<typename T>
T weightPoundToKilog(T weight_lb)
{
    return weight_lb / static_cast<T>(2.20462262185);
}

/* ************************************************************************** */

//! Random integer in [min, max]
//! example: randomInt(1, 6) => 4
inline int randomInt(int min, int max)
{
    static thread_local std::mt19937 generator{std::random_device{}()};
    std::uniform_int_distribution<int> distribution(min, max);
    return distribution(generator);
}

/* ************************************************************************** */

//! Haversine great-circle distance, scaled by the given sphere 'radius'
inline double haversine(double lat1, double long1, double lat2, double long2, double radius)
{
    const double dlong = degToRad(long2 - long1);
    const double dlat = degToRad(lat2 - lat1);
    const double a = std::pow(std::sin(dlat / 2.0), 2) +
                     std::cos(degToRad(lat1)) * std::cos(degToRad(lat2)) * std::pow(std::sin(dlong / 2.0), 2);
    const double c = 2.0 * std::atan2(std::sqrt(a), std::sqrt(1.0 - a));
    return radius * c;
}

//! Calculate haversine distance for linear distance (km)
inline double haversine_km(double lat1, double long1, double lat2, double long2)
{
    return haversine(lat1, long1, lat2, long2, 6367.0);
}

//! Calculate haversine distance for linear distance (miles)
inline double haversine_mi(double lat1, double long1, double lat2, double long2)
{
    return haversine(lat1, long1, lat2, long2, 3956.0);
}

/* ************************************************************************** */
#endif // UTILS_MATHS_H
