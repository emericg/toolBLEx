/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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

#ifndef RTLSDR_DRIVER_LIB_H
#define RTLSDR_DRIVER_LIB_H
/* ************************************************************************** */

#include "SpectrumDriver_lib.h"

#include <QString>

/* ************************************************************************** */

/*!
 * \brief RTL-SDR spectrum analyzer driver, using librtlsdr and an in-process FFT.
 *
 * Replaces the 'rtl_power' / 'rtl_power_fftw' / 'soapy_power' binaries with a single dependency (librtlsdr),
 * available on Linux, macOS and Windows (with a WinUSB driver).
 *
 * The capture is a single instantaneous window (no hopping):
 * the tuner is set on the center of the band, and the sample rate is the band width.
 * RTL2832U valid rates are 225001..300000 Hz and 900001..3200000 Hz, others are snapped.
 *
 * Processing, on the worker thread:
 * - synchronous reads of unsigned 8 bits interleaved IQ samples,
 * - optional DC offset removal (mean of each read buffer), and center (DC) bin patching,
 * - Hann window, radix-2 FFT of fftSize points, non-overlapping,
 * - power averaging over the integration time, then conversion to dB.
 *
 * Each averaged spectrum is pushed as one sweep, by increasing frequency.
 * Values are uncalibrated dBFS (a full-scale complex tone reads ~0 dB).
 * Samples dropped between two synchronous reads are irrelevant for an averaged power spectrum.
 */
class RtlSdrDriver_lib: public SpectrumDriver_lib
{
    Q_OBJECT

    std::atomic_int m_fftSize { 1024 };
    std::atomic_int m_ppm { 0 };
    std::atomic_bool m_dcRemoval { true };

protected:
    void workerLoop(const Config cfg) override;

public:
    explicit RtlSdrDriver_lib(QObject *parent = nullptr);
    ~RtlSdrDriver_lib() override;

    /*!
     * \brief Available if at least one RTL-SDR is connected (does not open it).
     */
    bool detect() override;

    /*!
     * \brief Open the device, and read its tuner type.
     */
    bool checkHardware(int deviceIndex) override;

    double defaultFloorDb() const override { return -90.0; }
    double defaultCeilDb() const override { return -40.0; }

    /*!
     * \brief FFT size, rounded up to a power of two in 64..16384. Applied on the next start().
     */
    int fftSize() const { return m_fftSize; }
    void setFftSize(int size);

    /*!
     * \brief Crystal frequency correction, in ppm. Applied on the next start().
     */
    int ppm() const { return m_ppm; }
    void setPpm(int ppm) { m_ppm = ppm; }

    /*!
     * \brief Remove the IQ DC offset, and patch the center (DC) bin. Applied on the next start().
     */
    bool dcRemoval() const { return m_dcRemoval; }
    void setDcRemoval(bool enabled) { m_dcRemoval = enabled; }

    /*!
     * \brief Count connected RTL-SDR devices (does not open them).
     */
    static int deviceCount();

    /*!
     * \brief Get the name of a device (ex: "Generic RTL2832U OEM"), without opening it.
     */
    static QString deviceName(int deviceIndex);

    /*!
     * \brief Open a device and read its tuner type.
     * \param deviceIndex: Index of the RTL-SDR among the connected ones.
     * \param tuner: Optional, receives the tuner name (ex: "R820T").
     * \param error: Optional, receives a user-facing reason on failure.
     * \return true if the device could be opened.
     */
    static bool probeDevice(int deviceIndex, QString *tuner = nullptr, QString *error = nullptr);
};

/* ************************************************************************** */
#endif // RTLSDR_DRIVER_LIB_H
