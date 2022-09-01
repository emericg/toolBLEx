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

#ifndef UTILS_BITS_H
#define UTILS_BITS_H
/* ************************************************************************** */

#include <cstdint>

uint16_t endian_flip_16(uint16_t src);

uint32_t endian_flip_32(uint32_t src);

uint64_t endian_flip_64(uint64_t src);

/* ************************************************************************** */
#endif // UTILS_BITS_H
