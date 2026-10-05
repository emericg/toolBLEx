/*!
 * This file is part of toolBLEx.
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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef SPECTRUM_SOURCE_UBERTOOTH_H
#define SPECTRUM_SOURCE_UBERTOOTH_H
/* ************************************************************************** */

#include "SpectrumSource.h"

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief Spectrum source backed by an Ubertooth One USB device.
 *
 * Frequencies are integer MHz (1 bin == 1 MHz).
 * Ubertooth One is great from 2.3 GHz to 2.6 GHz, maybe even more at a reduced precision.
 *
 * Its driver is selected at build time (TOOLBLEX_SPECTRUM_UBERTOOTH in CMakeLists.txt):
 * - UbertoothDriver_lib: libusb,
 * - UbertoothDriver_bin: 'ubertooth-specan' binary,
 * - or none at all.
 */
class SpectrumSourceUbertooth: public SpectrumSource
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(Ubertooth)

    // Singleton
    explicit SpectrumSourceUbertooth(QObject *parent = nullptr);

protected:
    void configureForStart() override;

public:
    static SpectrumSourceUbertooth *getInstance();
    static SpectrumSourceUbertooth *create(QQmlEngine *engine, QJSEngine *scriptEngine);
};

/* ************************************************************************** */
#endif // SPECTRUM_SOURCE_UBERTOOTH_H
