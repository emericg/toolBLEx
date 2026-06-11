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

#ifndef RTLSDR_H
#define RTLSDR_H
/* ************************************************************************** */

#include "SpectrumSource.h"

#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief Spectrum source backed by RTL-SDR compatible USB tuners.
 *
 * Drives one of three command-line scanners (soapy_power / rtl_power_fftw / rtl_power)
 * and parses its output into the shared ring buffer. Good for sub-GHz ISM bands
 * (315 / 433 / 868 / 915 MHz) on the common RTL2832U + R820T2 / E4000 chips.
 *
 * The capture should be a SINGLE instantaneous window (multi-hop sweeping at your own risks):
 * - User sets a center frequency (52 MHz to 2200 Mhz),
 * - And a bandwidth (the device sample rate, for a RTL2832U ~2.4 MHz is reliable, up to ~3.2 MHz but lossy),
 * > And the scan will covers [center - bw/2, center + bw/2].
 *
 * - The base freqMin/freqMax are derived from that and remain the interface to the UI/graphs.
 * - The dB values are uncalibrated and may differ per backend / hardware...
 */
class RtlSdr: public SpectrumSource
{
    Q_OBJECT

    Q_PROPERTY(int backend READ backend WRITE setBackend NOTIFY backendChanged)
    Q_PROPERTY(double centerFrequency READ centerFrequency WRITE setCenterFrequency NOTIFY centerFrequencyChanged)
    Q_PROPERTY(double bandwidth READ bandwidth WRITE setBandwidth NOTIFY bandwidthChanged)
    Q_PROPERTY(double integrationTime READ integrationTime WRITE setIntegrationTime NOTIFY integrationTimeChanged)

public:
    //! The command-line scanner backend to drive. SoapySDR preferred.
    enum Backend {
        SoapyPower = 0,     //!< 'soapy_power'    (SoapySDR) - rtl_power CSV, multi-SDR
        RtlPowerFftw,       //!< 'rtl_power_fftw' (FFTW)     - fastest, continuous
        RtlPower,           //!< 'rtl_power'      (rtl-sdr)  - simplest, ~1 Hz, slow per-report, should NOT be used
    };
    Q_ENUM(Backend)

private:
    Backend m_backend = SoapyPower;

    QString m_path_selectedtool;    //!< 'soapy_power' or 'rtl_power_fftw' binary
    QString m_path_rtltest;         //!< 'rtl_test' binary (device presence probe)

    double m_centerMHz = 433.0;     //!< tuner center frequency (MHz)
    double m_bandwidthMHz = 2.4;    //!< capture bandwidth / device sample rate (MHz); single window; ~2.4 reliable default.

    int m_bin_hz = 500;             //!< bin/step size in Hz (rtl_power, soapy_power).
                                    //!< MUST be finer than the 1 MHz display bucket, otherwise a
                                    //!< 2 MHz span yields only 2 values for 3 integer-MHz buckets and
                                    //!< the lowest bucket is never filled. 250 kHz -> ~4 bins/MHz.
    int m_fftw_bins = 512;          //!< FFT bins per hop (rtl_power_fftw)

    static constexpr int s_fftw_rssi_offset = -30; //!< raw RSSI -> dBm offset (from my experience) (rtl_power_fftw)

    double m_gain = -1.0;           //!< tuner gain in dB; < 0 = automatic
    double m_interval = 0.05;       //!< integration time, seconds (rtl_power -i / soapy_power -t).
                                    //!< Lower = faster but noisier. soapy_power plateaus ~10 Hz at
                                    //!< 0.05 on a single ~2 MHz window (per-report overhead floor);
                                    //!< going lower only adds noise. rtl_power stays ~1 Hz regardless.

    //! Apply the per-backend (uncalibrated) dB range to floorDb/ceilDb.
    void applyBackendDbRange();

    //! Recompute the base freqMin/freqMax (in the current unit) from the center frequency +/- bandwidth/2, and emit freqChanged().
    void applyFreqRange();

    //! Divide a Hz frequency into the current bin unit (MHz or kHz).
    int hzToUnit(double hz) const;

    //! Per-backend line parsers (both feed recordBin()).
    void parseCsvLine(const QString &line, int *&current_values, bool &sweepCompleted);   //!< rtl_power / soapy_power
    void parseFftwLine(const QString &line, int *&current_values, bool &sweepCompleted);  //!< rtl_power_fftw

    /*!
     * \brief Switch the bin unit (SpectrumSource::MHz / kHz).
     * \param unit: See SpectrumSource::FrequencyUnit.
     *
     * kHz gives fine (1 kHz) resolution; MHz is coarse.
     * Resets the SDR step and re-derives the range.
     *
     * REMOVE ? only used by the rtl_power, wich should in fact, not be used.
     */
    void setFrequencyUnit(int unit);

protected:
    QString binaryPath() const override { return m_path_selectedtool; }
    QStringList buildArguments() const override;

    void parseLine(const QString &line, int *&current_values, bool &sweepCompleted) override;
    //void requestStop(QProcess *process) override; // Use default SIGTERM.
    void configureForStart() override;

Q_SIGNALS:
    void backendChanged();
    void centerFrequencyChanged();
    void bandwidthChanged();
    void integrationTimeChanged();

public:
    RtlSdr(QObject *parent = nullptr);

    Q_INVOKABLE bool autodetectPaths() override;
    Q_INVOKABLE bool checkPaths() override;
    Q_INVOKABLE bool checkRtlSdr();

    int backend() const { return m_backend; }
    Q_INVOKABLE void setBackend(int backend);

    double centerFrequency() const { return m_centerMHz; }
    Q_INVOKABLE void setCenterFrequency(double freqMHz);

    double bandwidth() const { return m_bandwidthMHz; }
    Q_INVOKABLE void setBandwidth(double bwMHz);

    double integrationTime() const { return m_interval; }
    Q_INVOKABLE void setIntegrationTime(double seconds);
};

/* ************************************************************************** */
#endif // RTLSDR_H
