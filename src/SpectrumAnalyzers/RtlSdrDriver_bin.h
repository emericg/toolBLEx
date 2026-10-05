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

#ifndef RTLSDR_DRIVER_BIN_H
#define RTLSDR_DRIVER_BIN_H
/* ************************************************************************** */

#include "SpectrumDriver_bin.h"

#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief RTL-SDR spectrum analyzer driver, using a command-line scanner.
 *
 * Drives one of three tools (soapy_power / rtl_power_fftw / rtl_power), and parses its output.
 * The tool is selected by the path set in the settings.
 *
 * The capture should be a SINGLE instantaneous window (multi-hop sweeping at your own risks):
 * the sample rate is the band width.
 */
class RtlSdrDriver_bin: public SpectrumDriver_bin
{
    Q_OBJECT

public:
    //! The command-line scanner to drive. SoapySDR preferred.
    enum Tool {
        SoapyPower = 0,     //!< 'soapy_power'    (SoapySDR) - rtl_power CSV, multi-SDR
        RtlPowerFftw,       //!< 'rtl_power_fftw' (FFTW)     - fastest, continuous
        RtlPower,           //!< 'rtl_power'      (rtl-sdr)  - simplest, ~1 Hz, slow per-report, should NOT be used
    };
    Q_ENUM(Tool)

private:
    static constexpr int s_fftw_rssi_offset = -30; //!< raw RSSI -> dBm offset (from my experience) (rtl_power_fftw)

    Tool m_tool = SoapyPower;

    QString m_path_selectedtool;    //!< 'soapy_power' or 'rtl_power_fftw' binary
    QString m_path_rtltest;         //!< 'rtl_test' binary (device presence probe)

    int m_bin_hz = 500;             //!< bin/step size in Hz (rtl_power, soapy_power).
                                    //!< MUST be finer than the display bucket (1 kHz),
                                    //!< otherwise the lowest buckets are never filled.
    int m_fftw_bins = 512;          //!< FFT bins per hop (rtl_power_fftw)

    //! Per-tool line parsers.
    void parseCsvLine(const QString &line, std::vector <Sample> &out);  //!< rtl_power / soapy_power
    void parseFftwLine(const QString &line, std::vector <Sample> &out); //!< rtl_power_fftw

protected:
    QString binaryPath() const override { return m_path_selectedtool; }
    QStringList buildArguments(const Config &cfg) const override;
    void parseLine(const QString &line, std::vector <Sample> &out) override;

public:
    explicit RtlSdrDriver_bin(QObject *parent = nullptr);

    Tool tool() const { return m_tool; }

    /*!
     * \brief Find the tools using QStandardPaths::findExecutable(), and save them to the settings.
     * \return true if tools found.
     */
    bool autodetect() override;

    /*!
     * \brief Validate the tool path from the settings, and select the matching tool.
     * \return true if tools found.
     */
    bool detect() override;

    /*!
     * \brief Run 'rtl_test' to check for a device.
     */
    bool checkHardware(int deviceIndex) override;

    /*!
     * \brief Each tool reports power against a different (uncalibrated) reference.
     */
    double defaultFloorDb() const override;
    double defaultCeilDb() const override;
};

/* ************************************************************************** */
#endif // RTLSDR_DRIVER_BIN_H
