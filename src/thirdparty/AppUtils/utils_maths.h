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

//! Align buffer sizes to multiples of 'roundTo'
int roundTo(const int value, const int roundTo);

//! Map a number from range [a1-a2] to [b1:b2]
int mapNumber(const int value, const int a1, const int a2, const int b1, const int b2, bool checks = true);

/* ************************************************************************** */

//! Calculate haversine distance for linear distance (km)
double haversine_km(double lat1, double long1, double lat2, double long2);

//! Calculate haversine distance for linear distance (miles)
double haversine_mi(double lat1, double long1, double lat2, double long2);

/* ************************************************************************** */
#endif // UTILS_MATHS_H
