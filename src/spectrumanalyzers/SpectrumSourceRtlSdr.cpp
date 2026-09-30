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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "SpectrumSourceRtlSdr.h"
#include "SettingsManager.h"

#if defined(TOOLBLEX_RTLSDR_LIB)
#include "RtlSdrDriver_lib.h"
#elif defined(TOOLBLEX_RTLSDR_BIN)
#include "RtlSdrDriver_bin.h"
#endif

#include <algorithm>
#include <cmath>

/* ************************************************************************** */

SpectrumSourceRtlSdr::SpectrumSourceRtlSdr(QObject *parent) : SpectrumSource(parent)
{
    m_unit = kHz;

#if defined(TOOLBLEX_RTLSDR_LIB)
    setActiveDriver(new RtlSdrDriver_lib(this));
#elif defined(TOOLBLEX_RTLSDR_BIN)
    setActiveDriver(new RtlSdrDriver_bin(this));
#endif

    configureForStart();

    checkPaths();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumSourceRtlSdr::applyFreqRange()
{
    // Single window: [center - bw/2, center + bw/2], expressed in the current unit.

    const double halfBwHz = (m_bandwidthMHz * 1000000.0) / 2.0;
    const double centerHz = m_centerMHz * 1000000.0;

    m_freq_min = hzToUnit(centerHz - halfBwHz);
    m_freq_max = hzToUnit(centerHz + halfBwHz);
    Q_EMIT freqChanged();
}

/* ************************************************************************** */

void SpectrumSourceRtlSdr::setCenterFrequency(double freqMHz)
{
    if (freqMHz <= 0.0) return;

    if (!qFuzzyCompare(m_centerMHz, freqMHz))
    {
        m_centerMHz = freqMHz;
        Q_EMIT centerFrequencyChanged();

        applyFreqRange();
    }
}

/* ************************************************************************** */

void SpectrumSourceRtlSdr::setBandwidth(double bwMHz)
{
    bwMHz = std::clamp(bwMHz, 0.1, 3.2); // RTL2832U: ~2.4 reliable, ~3.2 lossy

    if (!qFuzzyCompare(m_bandwidthMHz, bwMHz))
    {
        m_bandwidthMHz = bwMHz;
        Q_EMIT bandwidthChanged();

        applyFreqRange();
    }
}

/* ************************************************************************** */

void SpectrumSourceRtlSdr::setIntegrationTime(double seconds)
{
    // Clamp to a sane band; takes effect on the next startWork()/restartWork()
    seconds = std::clamp(seconds, 0.001, 10.0);

    if (!qFuzzyCompare(m_interval, seconds))
    {
        m_interval = seconds;
        Q_EMIT integrationTimeChanged();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumSourceRtlSdr::configureForStart()
{
    SettingsManager *sm = SettingsManager::getInstance();
    m_centerMHz = sm->getRtlSdrFreqTarget();
    m_bandwidthMHz = sm->getRtlSdrFreqBandwidth() / 1000.0;

    // dB range must match the active driver / tool, not be hard-coded
    if (m_driver)
    {
        setFloorDb(m_driver->defaultFloorDb());
        setCeilDb(m_driver->defaultCeilDb());
    }

    applyFreqRange(); // derive freqMin/freqMax from center +/- bandwidth/2
}

/* ************************************************************************** */

SpectrumDriver::Config SpectrumSourceRtlSdr::driverConfig() const
{
    SpectrumDriver::Config cfg;
    cfg.deviceIndex = m_deviceIndex;
    cfg.freqMinHz = (m_centerMHz - m_bandwidthMHz / 2.0) * 1000000.0;
    cfg.freqMaxHz = (m_centerMHz + m_bandwidthMHz / 2.0) * 1000000.0;
    cfg.gainDb = m_gain;
    cfg.integrationTime = m_interval;
    return cfg;
}

/* ************************************************************************** */
