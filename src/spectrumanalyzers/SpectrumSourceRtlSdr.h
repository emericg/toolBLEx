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

#ifndef SPECTRUM_SOURCE_RTLSDR_H
#define SPECTRUM_SOURCE_RTLSDR_H
/* ************************************************************************** */

#include "SpectrumSource.h"

/* ************************************************************************** */

/*!
 * \brief Spectrum source backed by RTL-SDR compatible USB tuners.
 *
 * Good for sub-GHz ISM bands (315 / 433 / 868 / 915 MHz),
 * on the common RTL2832U + R820T2 / E4000 chips.
 *
 * The capture is a SINGLE instantaneous window:
 * - User sets a center frequency (52 MHz to 2200 Mhz),
 * - And a bandwidth (the device sample rate, for a RTL2832U ~2.4 MHz is reliable, up to ~3.2 MHz but lossy),
 * > And the scan will covers [center - bw/2, center + bw/2].
 *
 * - The base freqMin/freqMax (in kHz) are derived from that and remain the interface to the UI/graphs.
 * - The dB values are uncalibrated and may differ per driver / tool / hardware...
 *
 * Its driver is selected at build time (TOOLBLEX_SPECTRUM_RTLSDR in CMakeLists.txt):
 * - RtlSdrDriver_lib: librtlsdr,
 * - RtlSdrDriver_bin: soapy_power / rtl_power_fftw binaries,
 * - or none at all.
 */
class SpectrumSourceRtlSdr: public SpectrumSource
{
    Q_OBJECT

    Q_PROPERTY(double centerFrequency READ centerFrequency WRITE setCenterFrequency NOTIFY centerFrequencyChanged)
    Q_PROPERTY(double bandwidth READ bandwidth WRITE setBandwidth NOTIFY bandwidthChanged)
    Q_PROPERTY(double integrationTime READ integrationTime WRITE setIntegrationTime NOTIFY integrationTimeChanged)

    double m_centerMHz = 433.0;     //!< tuner center frequency (MHz)
    double m_bandwidthMHz = 2.4;    //!< capture bandwidth / device sample rate (MHz); single window; ~2.4 reliable default.

    double m_gain = -1.0;           //!< tuner gain in dB; < 0 = automatic
    double m_interval = 0.05;       //!< integration time, seconds.
                                    //!< Lower = faster but noisier. soapy_power plateaus ~10 Hz at
                                    //!< 0.05 on a single ~2 MHz window (per-report overhead floor);
                                    //!< going lower only adds noise. rtl_power stays ~1 Hz regardless.

    //! Recompute the base freqMin/freqMax (in the current unit) from the center frequency +/- bandwidth/2, and emit freqChanged().
    void applyFreqRange();

protected:
    void configureForStart() override;
    SpectrumDriver::Config driverConfig() const override;

Q_SIGNALS:
    void centerFrequencyChanged();
    void bandwidthChanged();
    void integrationTimeChanged();

public:
    explicit SpectrumSourceRtlSdr(QObject *parent = nullptr);

    double centerFrequency() const { return m_centerMHz; }
    Q_INVOKABLE void setCenterFrequency(double freqMHz);

    double bandwidth() const { return m_bandwidthMHz; }
    Q_INVOKABLE void setBandwidth(double bwMHz);

    double integrationTime() const { return m_interval; }
    Q_INVOKABLE void setIntegrationTime(double seconds);
};

/* ************************************************************************** */
#endif // SPECTRUM_SOURCE_RTLSDR_H
