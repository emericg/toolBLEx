/*!
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
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
