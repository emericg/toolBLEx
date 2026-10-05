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

#include "RtlSdrDriver_bin.h"
#include "SettingsManager.h"

#include <QStandardPaths>
#include <QStringList>
#include <QProcess>
#include <QFile>
#include <QDebug>

#include <cmath>

/* ************************************************************************** */
/* ************************************************************************** */

RtlSdrDriver_bin::RtlSdrDriver_bin(QObject *parent) : SpectrumDriver_bin(parent)
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

double RtlSdrDriver_bin::defaultFloorDb() const
{
    // Rough, hardware-measured defaults:
    // - rtl_power      peak ~-3,  noise ~-20   -> -30 .. 0
    // - soapy_power    peak ~-85, noise ~-100  -> -100 .. -55
    // - rtl_power_fftw raw noise ~-62, shifted by s_fftw_rssi_offset,
    //                  so the raw -60..-30 window becomes -90..-60 (same 30 dB span).

    switch (m_tool)
    {
        case RtlPower:     return -30.0;
        case RtlPowerFftw: return -60.0 + s_fftw_rssi_offset;
        case SoapyPower:   return -100.0;
    }
    return -100.0;
}

double RtlSdrDriver_bin::defaultCeilDb() const
{
    switch (m_tool)
    {
        case RtlPower:     return 0.0;
        case RtlPowerFftw: return -30.0 + s_fftw_rssi_offset;
        case SoapyPower:   return -55.0;
    }
    return -55.0;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool RtlSdrDriver_bin::autodetect()
{
    if (m_path_selectedtool.isEmpty())
    {
        QString soapypower = QStandardPaths::findExecutable("soapy_power");
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

bool RtlSdrDriver_bin::detect()
{
    bool status = false;

    // User defined tool will drive what backend we use
    SettingsManager *sm = SettingsManager::getInstance();
    QString path_selectedtool = sm->getRtlSdrPath();

    if (path_selectedtool.isEmpty() ||
        !(path_selectedtool.contains("soapy_power") || path_selectedtool.contains("rtl_power_fftw")))
    {
        m_available = false;
        return false;
    }

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

        if (path_selectedtool.contains("soapy_power")) m_tool = SoapyPower;
        else if (path_selectedtool.contains("rtl_power_fftw")) m_tool = RtlPowerFftw;
    }
    else
    {
        qDebug() << "RtlSdrDriver_bin::detect() Unable to detect compatible tools at: '" << path_selectedtool << "'";
    }

    m_available = status;
    return status;
}

/* ************************************************************************** */

bool RtlSdrDriver_bin::checkHardware(int deviceIndex)
{
    Q_UNUSED(deviceIndex)

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
        qWarning() << "RtlSdrDriver_bin::checkHardware() Unable to detect an RTL-SDR device";
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

QStringList RtlSdrDriver_bin::buildArguments(const Config &cfg) const
{
    // Single instantaneous window: sample rate = band width.
    const qint64 lowHz  = std::llround(cfg.freqMinHz);
    const qint64 highHz = std::llround(cfg.freqMaxHz);
    const qint64 rateHz = highHz - lowHz;

    QStringList args;
    switch (m_tool)
    {
        case RtlPower:
            // rtl_power -f <low>:<high>:<step> -i <interval> [-g <gain>] -
            //   frequencies in Hz; '-' writes the CSV to stdout; no -1 = run continuously.
            //   (rtl_power has no sample-rate flag; the <=bandwidth span is one hop anyway.)
            args << "-f" << QString("%1:%2:%3").arg(lowHz).arg(highHz).arg(m_bin_hz);
            args << "-i" << QString::number(cfg.integrationTime);
            args << "-d" << QString::number(cfg.deviceIndex);
            if (cfg.gainDb >= 0.0) args << "-g" << QString::number(cfg.gainDb);
            args << "-";
            break;

        case RtlPowerFftw:
            // rtl_power_fftw: single window via -f low:high with -r = bandwidth (one hop),
            //   -b FFT bins, -c continuous. Output to stdout. Gain is in tenths of a dB.
            //   -t sets the integration time per spectrum.
            args << "-f" << QString("%1:%2").arg(lowHz).arg(highHz);
            args << "-r" << QString::number(rateHz);
            args << "-b" << QString::number(m_fftw_bins);
            args << "-t" << QString::number(cfg.integrationTime);
            args << "-d" << QString::number(cfg.deviceIndex);
            args << "-c";
            if (cfg.gainDb >= 0.0) args << "-g" << QString::number(static_cast<int>(cfg.gainDb * 10));
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
            args << "-t" << QString::number(cfg.integrationTime);
            args << "-d" << QString("driver=rtlsdr,rtl=%1").arg(cfg.deviceIndex);
            args << "-F" << "rtl_power";
            args << "-c";
            if (cfg.gainDb >= 0.0) args << "-g" << QString::number(cfg.gainDb);
            break;
    }

    return args;
}

/* ************************************************************************** */
/* ************************************************************************** */

void RtlSdrDriver_bin::parseLine(const QString &line, std::vector <Sample> &out)
{
    if (m_tool == RtlPowerFftw) parseFftwLine(line, out);
    else parseCsvLine(line, out);
}

/* ************************************************************************** */

void RtlSdrDriver_bin::parseCsvLine(const QString &line, std::vector <Sample> &out)
{
    // rtl_power / soapy_power: "date, time, Hz_low, Hz_high, Hz_step, n_samples, dB, dB, ..."

    const QStringList f = line.split(',');
    if (f.size() < 7) return;

    bool ok_low = false, ok_high = false;
    const double hz_low  = f.at(2).trimmed().toDouble(&ok_low);
    const double hz_high = f.at(3).trimmed().toDouble(&ok_high);
    if (!ok_low || !ok_high || hz_high <= hz_low) return;

    // NOTE: the Hz_step field is the hop step, not the per-value spacing (several FFT bins
    // can be emitted per hop), so derive the real spacing from the span and the value count.
    const int binValues = f.size() - 6;
    const double spacing = (hz_high - hz_low) / static_cast<double>(binValues);

    for (int j = 0; j < binValues; j++)
    {
        bool ok_db = false;
        const double db = f.at(6 + j).trimmed().toDouble(&ok_db);
        if (!ok_db) continue;

        out.push_back({ hz_low + (j + 0.5) * spacing, static_cast<float>(db) }); // bin center
    }
}

/* ************************************************************************** */

void RtlSdrDriver_bin::parseFftwLine(const QString &line, std::vector <Sample> &out)
{
    // rtl_power_fftw: "<frequency_hz> <power_db>" (whitespace separated, freq in scientific notation)

    const QStringList f = line.split(' ', Qt::SkipEmptyParts);
    if (f.size() < 2) return;

    bool ok_hz = false, ok_db = false;
    const double hz = f.at(0).toDouble(&ok_hz);
    const double db = f.at(1).toDouble(&ok_db);
    if (!ok_hz || !ok_db) return;

    out.push_back({ hz, static_cast<float>(db + s_fftw_rssi_offset) });
}

/* ************************************************************************** */
/* ************************************************************************** */
