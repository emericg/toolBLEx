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
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2022
 */

#include "utils_bits.h"

/* ************************************************************************** */

uint16_t endian_flip_16(uint16_t src)
{
    return ( ((src & 0x00FF) << 8) | ((src & 0xFF00) >> 8) );
}

uint32_t endian_flip_32(uint32_t src)
{
    return ( ((src & 0x000000FF) << 24)
           | ((src & 0x0000FF00) <<  8)
           | ((src & 0x00FF0000) >>  8)
           | ((src & 0xFF000000) >> 24) );
}

uint64_t endian_flip_64(uint64_t src)
{
    return ( ((src & 0x00000000000000FFULL) << 56)
           | ((src & 0x000000000000FF00ULL) << 40)
           | ((src & 0x0000000000FF0000ULL) << 24)
           | ((src & 0x00000000FF000000ULL) <<  8)
           | ((src & 0x000000FF00000000ULL) >>  8)
           | ((src & 0x0000FF0000000000ULL) >> 24)
           | ((src & 0x00FF000000000000ULL) >> 40)
           | ((src & 0xFF00000000000000ULL) >> 56) );
}

/* ************************************************************************** */
