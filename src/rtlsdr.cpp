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

#include "rtlsdr.h"
#include "SettingsManager.h"

#include <QStandardPaths>
#include <QStringList>
#include <QProcess>
#include <QFile>
#include <QDebug>

#include <algorithm>
#include <cmath>

/* ************************************************************************** */
/* ************************************************************************** */

RtlSdr::RtlSdr(QObject *parent) : SpectrumSource(parent)
{
    m_floorDb = -100.0;
    m_ceilDb = -30.0;

    m_unit = kHz;
    m_bin_hz = 500;

    configureForStart();

    checkPaths();
}

/* ************************************************************************** */
/* ************************************************************************** */

void RtlSdr::setBackend(int backend)
{
    if (backend < SoapyPower || backend > RtlPower) return;

    if (m_backend != static_cast<Backend>(backend))
    {
        m_backend = static_cast<Backend>(backend);
        Q_EMIT backendChanged();

        applyBackendDbRange();
    }
}

/* ************************************************************************** */

void RtlSdr::applyBackendDbRange()
{
    // Each backend reports power against a different (uncalibrated) reference,
    // so the colormap range must follow.
    // Rough, hardware-measured defaults:
    // - rtl_power      peak ~-3,  noise ~-20   -> -30 .. 0
    // - soapy_power    peak ~-85, noise ~-100  -> -100 .. -55
    // - rtl_power_fftw raw noise ~-62, shifted by s_fftw_rssi_offset (-38) to ~-100 dBm,
    //                  so the raw -60..-30 window becomes -98..-68 (same 30 dB span).

    switch (m_backend)
    {
        case RtlPower:     setFloorDb(-30.0);  setCeilDb(0.0);    break;
        case RtlPowerFftw: setFloorDb(-60.0 + s_fftw_rssi_offset); setCeilDb(-30.0 + s_fftw_rssi_offset); break;
        case SoapyPower:   setFloorDb(-100.0); setCeilDb(-55.0);  break;
    }
}

/* ************************************************************************** */

void RtlSdr::applyFreqRange()
{
    // Single window: [center - bw/2, center + bw/2], expressed in the current unit.

    const double halfBwHz = (m_bandwidthMHz * 1000000.0) / 2.0;
    const double centerHz = m_centerMHz * 1000000.0;
    const double hzPerUnit = (m_unit == FrequencyUnit::kHz) ? 1000.0 : 1000000.0;

    m_freq_min = static_cast<int>(std::lround((centerHz - halfBwHz) / hzPerUnit));
    m_freq_max = static_cast<int>(std::lround((centerHz + halfBwHz) / hzPerUnit));
    Q_EMIT freqChanged();
}

/* ************************************************************************** */

void RtlSdr::setCenterFrequency(double freqMHz)
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

void RtlSdr::setBandwidth(double bwMHz)
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

void RtlSdr::setFrequencyUnit(int unit)
{
    if (unit != FrequencyUnit::MHz && unit != FrequencyUnit::kHz) return;
    if (m_unit == static_cast<FrequencyUnit>(unit)) return;

    // The band is defined by center/bandwidth, so just re-derive freqMin/freqMax in
    // the new unit and pick a default SDR step finer than the new bucket.

    m_unit = static_cast<FrequencyUnit>(unit);
    m_bin_hz = (m_unit == FrequencyUnit::kHz) ? 500 : 250000;
    applyFreqRange();
}

/* ************************************************************************** */

void RtlSdr::setIntegrationTime(double seconds)
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

bool RtlSdr::autodetectPaths()
{
    if (m_path_selectedtool.isEmpty())
    {
        QString soapypower   = QStandardPaths::findExecutable("soapy_power");
        if (!soapypower.isEmpty()) m_path_selectedtool = soapypower;
    }

    if (m_path_selectedtool.isEmpty())
    {
        QString rtlpowerfftw = QStandardPaths::findExecutable("rtl_power_fftw");
        if (!rtlpowerfftw.isEmpty()) m_path_selectedtool = rtlpowerfftw;
    }

    //QString rtlpower = QStandardPaths::findExecutable("rtl_power");
    m_path_rtltest = QStandardPaths::findExecutable("rtl_test");

    if (m_path_selectedtool.isEmpty() || m_path_rtltest.isEmpty()) return false;

    SettingsManager *sm = SettingsManager::getInstance();
    sm->setRtlSdrPath(m_path_selectedtool);

    return true;
}

/* ************************************************************************** */

bool RtlSdr::checkPaths()
{
#if defined(Q_OS_WINDOWS)
    return false; // We just don't support Windows
#endif

    bool status = false;

    // User defined tool will drive what backend we use
    SettingsManager *sm = SettingsManager::getInstance();
    QString path_selectedtool = sm->getRtlSdrPath();

    if (path_selectedtool.isEmpty()) return false;
    if (!(path_selectedtool.contains("soapy_power") || path_selectedtool.contains("rtl_power_fftw"))) return false;

    if (QFile::exists(path_selectedtool))
    {
        // If the path points directly to a file
        status = true;
    }
    else if (path_selectedtool == "soapy_power" || path_selectedtool =="rtl_power_fftw")
    {
        // If the path is the executable name, and we can find it
        path_selectedtool = QStandardPaths::findExecutable(path_selectedtool);
        if (!path_selectedtool.isEmpty())
        {
            status = true;

            // And save it... QStandardPaths::findExecutable() is expensive
            sm->setRtlSdrPath(path_selectedtool);
        }
    }

    if (status)
    {
        m_path_selectedtool = path_selectedtool;
        if (m_path_rtltest.isEmpty()) m_path_rtltest = QStandardPaths::findExecutable("rtl_test");

        if (path_selectedtool.contains("soapy_power")) setBackend(SoapyPower);
        else if (path_selectedtool.contains("rtl_power_fftw")) setBackend(RtlPowerFftw);
    }
    else
    {
        qDebug() << "RtlSdr::checkPaths() Unable to detect compatible tools at: '" << path_selectedtool << "'";
    }

    if (m_toolsAvailable != status)
    {
        m_toolsAvailable = status;
        Q_EMIT availableChanged();
    }

    return status;
}

/* ************************************************************************** */

bool RtlSdr::checkRtlSdr()
{
#if defined(Q_OS_WINDOWS)
    return false; // We just don't support Windows
#endif

    if (m_childProcess) return true; // A running capture already implies a working device

    if (m_path_rtltest.isEmpty()) return false;

    bool status = false;

    // rtl_test enumerates devices then runs a continuous benchmark, so it never
    // exits on its own: give it a moment to print the device banner, then kill it.
    QProcess process;
    process.start(m_path_rtltest, QStringList(), QIODevice::ReadOnly);
    process.waitForStarted(333);
    process.waitForFinished(333);

    const QString out = QString(process.readAllStandardError()) + QString(process.readAllStandardOutput());

    process.kill();
    process.waitForFinished(333);

    if (out.contains("Found", Qt::CaseInsensitive) &&
        !out.contains("No supported devices", Qt::CaseInsensitive))
    {
        status = true;
    }
    else
    {
        qWarning() << "RtlSdr::checkRtlSdr() Unable to detect an RTL-SDR device";
    }

    if (m_hardwareAvailable != status)
    {
        m_hardwareAvailable = status;
        Q_EMIT availableChanged();
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void RtlSdr::configureForStart()
{
    SettingsManager *sm = SettingsManager::getInstance();
    m_centerMHz = sm->getRtlSdrFreqTarget();
    m_bandwidthMHz = sm->getRtlSdrFreqBandwidth() / 1000.0;

    applyBackendDbRange();    // dB range must match the (default) backend, not be hard-coded
    applyFreqRange();          // derive freqMin/freqMax from center +/- bandwidth/2
}

/* ************************************************************************** */

QStringList RtlSdr::buildArguments() const
{
    // Single instantaneous window: band = center +/- bandwidth/2, sample rate = bandwidth.
    const qint64 rateHz = static_cast<qint64>(std::llround(m_bandwidthMHz * 1000000));
    const qint64 lowHz  = static_cast<qint64>(std::llround((m_centerMHz - m_bandwidthMHz / 2.0) * 1000000));
    const qint64 highHz = static_cast<qint64>(std::llround((m_centerMHz + m_bandwidthMHz / 2.0) * 1000000));

    QStringList args;
    switch (m_backend)
    {
        case RtlPower:
            // rtl_power -f <low>:<high>:<step> -i <interval> [-g <gain>] -
            //   frequencies in Hz; '-' writes the CSV to stdout; no -1 = run continuously.
            //   (rtl_power has no sample-rate flag; the <=bandwidth span is one hop anyway.)
            args << "-f" << QString("%1:%2:%3").arg(lowHz).arg(highHz).arg(m_bin_hz);
            args << "-i" << QString::number(m_interval);
            args << "-d" << QString::number(m_deviceIndex);
            if (m_gain >= 0.0) args << "-g" << QString::number(m_gain);
            args << "-";
            break;

        case RtlPowerFftw:
            // rtl_power_fftw: single window via -f low:high with -r = bandwidth (one hop),
            //   -b FFT bins, -c continuous. Output to stdout. Gain is in tenths of a dB.
            //   -t sets the integration time per spectrum.
            args << "-f" << QString("%1:%2").arg(lowHz).arg(highHz);
            args << "-r" << QString::number(rateHz);
            args << "-b" << QString::number(m_fftw_bins);
            args << "-t" << QString::number(m_interval);
            args << "-d" << QString::number(m_deviceIndex);
            args << "-c";
            if (m_gain >= 0.0) args << "-g" << QString::number(static_cast<int>(m_gain * 10));
            break;

        case SoapyPower:
        default:
            // soapy_power: rtl_power-compatible CSV by default. Continuous (-c),
            // bin size in Hz (-B), integration time in seconds (-t, NOT -i), and
            // sample rate (-r) = bandwidth so it captures the band in one window.
            // Requires the SoapySDR rtlsdr module (e.g. soapysdr-module-rtlsdr).
            args << "-f" << QString("%1:%2").arg(lowHz).arg(highHz);
            args << "-r" << QString::number(rateHz);
            args << "-B" << QString::number(m_bin_hz);
            args << "-t" << QString::number(m_interval);
            args << "-d" << QString("driver=rtlsdr,rtl=%1").arg(m_deviceIndex);
            args << "-F" << "rtl_power";
            args << "-c";
            if (m_gain >= 0.0) args << "-g" << QString::number(m_gain);
            break;
    }

    return args;
}

/* ************************************************************************** */
/* ************************************************************************** */

int RtlSdr::hzToUnit(double hz) const
{
    const double div = (m_unit == FrequencyUnit::kHz) ? 1000.0 : 1000000.0;
    return static_cast<int>(std::lround(hz / div));
}

/* ************************************************************************** */

void RtlSdr::parseLine(const QString &line, int *&current_values, bool &sweepCompleted)
{
    if (m_backend == RtlPowerFftw) parseFftwLine(line, current_values, sweepCompleted);
    else parseCsvLine(line, current_values, sweepCompleted);
}

/* ************************************************************************** */

void RtlSdr::parseCsvLine(const QString &line, int *&current_values, bool &sweepCompleted)
{
    // rtl_power / soapy_power: "date, time, Hz_low, Hz_high, Hz_step, n_samples, dB, dB, ..."

    const QStringList f = line.split(',');
    if (f.size() < 7) return;

    bool ok_low = false, ok_high = false;
    const double hz_low  = f.at(2).trimmed().toDouble(&ok_low);
    const double hz_high = f.at(3).trimmed().toDouble(&ok_high);
    if (!ok_low || !ok_high || hz_high <= hz_low) return;

    // Aggregate this segment's bins into buckets.
    // NOTE: the Hz_step field is the hop step, not the per-value spacing (several FFT bins
    // can be emitted per hop), so derive the real spacing from the span and the value count.
    const int binValues = f.size() - 6;
    if (binValues <= 0) return;
    const double spacing = (hz_high - hz_low) / static_cast<double>(binValues);

    for (int j = 0; j < binValues; j++)
    {
        bool ok_db = false;
        const double db = f.at(6 + j).trimmed().toDouble(&ok_db);
        if (!ok_db) continue;

        const double hz = hz_low + (j + 0.5) * spacing; // bin center
        recordBin(hzToUnit(hz), static_cast<int>(std::lround(db)), current_values, sweepCompleted);
    }
}

/* ************************************************************************** */

void RtlSdr::parseFftwLine(const QString &line, int *&current_values, bool &sweepCompleted)
{
    // rtl_power_fftw: "<frequency_hz> <power_db>" (whitespace separated, freq in scientific notation)

    const QStringList f = line.split(' ', Qt::SkipEmptyParts);
    if (f.size() < 2) return;

    bool ok_hz = false, ok_db = false;
    const double hz = f.at(0).toDouble(&ok_hz);
    const double db = f.at(1).toDouble(&ok_db);
    if (!ok_hz || !ok_db) return;

    recordBin(hzToUnit(hz), static_cast<int>(std::lround(db)) + s_fftw_rssi_offset, current_values, sweepCompleted);
}

/* ************************************************************************** */
/* ************************************************************************** */
