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

#include "SpectrumSourceUbertooth.h"
#include "SettingsManager.h"

#include <QCoreApplication>
#include <QJSEngine>

#if defined(TOOLBLEX_UBERTOOTH_LIB)
#include "UbertoothDriver_lib.h"
#elif defined(TOOLBLEX_UBERTOOTH_BIN)
#include "UbertoothDriver_bin.h"
#endif

/* ************************************************************************** */

SpectrumSourceUbertooth *SpectrumSourceUbertooth::getInstance()
{
    static SpectrumSourceUbertooth *instance = new SpectrumSourceUbertooth(QCoreApplication::instance());
    return instance;
}

SpectrumSourceUbertooth *SpectrumSourceUbertooth::create(QQmlEngine *, QJSEngine *)
{
    SpectrumSourceUbertooth *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

/* ************************************************************************** */

SpectrumSourceUbertooth::SpectrumSourceUbertooth(QObject *parent) : SpectrumSource(parent)
{
    m_unit = MHz;

#if defined(TOOLBLEX_UBERTOOTH_LIB)
    setActiveDriver(new UbertoothDriver_lib(this));
#elif defined(TOOLBLEX_UBERTOOTH_BIN)
    setActiveDriver(new UbertoothDriver_bin(this));
#endif

    configureForStart();

    checkPaths();
}

/* ************************************************************************** */

void SpectrumSourceUbertooth::configureForStart()
{
    SettingsManager *sm = SettingsManager::getInstance();
    m_freq_min = sm->getUbertoothFreqMin();
    m_freq_max = sm->getUbertoothFreqMax();
    Q_EMIT freqChanged();
}

/* ************************************************************************** */
