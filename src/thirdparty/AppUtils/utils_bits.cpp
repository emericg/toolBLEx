/*!
 * Copyright (c) 2022 Emeric Grange
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
