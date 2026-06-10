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

#include "ubertooth.h"
#include "SettingsManager.h"

#include <QProcess>
#include <QTimer>
#include <QStringList>
#include <QFileInfo>
#include <QFile>
#include <QDir>
#include <QDebug>

#include <algorithm>
#include <vector>

/* ************************************************************************** */
/* ************************************************************************** */

Ubertooth::Ubertooth(QObject *parent) : QObject(parent)
{
    SettingsManager *sm = SettingsManager::getInstance();
    m_freq_min = sm->getUbertoothFreqMin();
    m_freq_max = sm->getUbertoothFreqMax();

    checkPath();
}

Ubertooth::~Ubertooth()
{
    m_ring_buffer.clear();
    m_blank_column.clear();
    m_ring_head = 0;
    m_ring_count = 0;
    m_ring_bins = 0;
    m_values_latest.clear();
    m_max_max = s_rssi_offset;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Ubertooth::checkPath()
{
    bool status = false;

#if defined(Q_OS_WINDOWS)
    return status;
#endif

    SettingsManager *sm = SettingsManager::getInstance();
    QString path_specscan = sm->getUbertoothPath();

    // Just check if the path points to a file
    if (path_specscan.contains("ubertooth-specan") && QFile::exists(path_specscan))
    {
        status = true;
    }
    else
    {
        QString path_util = "";
        if (path_specscan.contains("ubertooth-specan"))
        {
            path_util = path_specscan;
            path_util.replace("ubertooth-specan", "ubertooth-util");
        }

        QProcess process;
        process.start(path_util, QStringList("-v"), QIODevice::ReadOnly);
        process.waitForFinished(8000);

        //QString out(process.readAllStandardOutput());
        QString err(process.readAllStandardError());
        QProcess::ProcessError error = process.error();

        if (error >= QProcess::FailedToStart && err.isEmpty())
        {
            qDebug() << "QProcess::FailedToStart for process '" << path_util << "' with error:" << error;
        }
        else
        {
            status = true;
        }
    }

    if (status)
    {
        m_path_specan = path_specscan;
        m_path_util = path_specscan;
        m_path_util.replace("ubertooth-specan", "ubertooth-util");
    }
    else
    {
        qDebug() << "Ubertooth::checkPath() Unable to detect Ubertooth tools at: '" << path_specscan << "'";
    }

    if (m_toolsAvailable != status)
    {
        m_toolsAvailable = status;
        Q_EMIT availableChanged();
    }

    return status;
}

/* ************************************************************************** */

bool Ubertooth::checkUbertooth()
{
    if (m_childProcess) return true;

    bool status = false;

#if defined(Q_OS_WINDOWS)
    return status;
#endif

    QProcess process;
    process.start(m_path_util, QStringList("-v"), QIODevice::ReadOnly);
    process.waitForFinished(8000);

    QString output(process.readAllStandardOutput());
    //QString err(process.readAllStandardError());
    //QProcess::ProcessError error = process.error();

    if (!output.isEmpty())
    {
        QStringList output_split = output.split('\n');
        QString l1 = output_split.first();

        if (l1.contains("could not open Ubertooth device", Qt::CaseInsensitive) ||
            l1.contains("usb_claim_interface error", Qt::CaseInsensitive) ||
            l1.contains("failed to run:", Qt::CaseInsensitive))
        {
            qDebug() << "Ubertooth::checkUbertooth() Unable to detect an Ubertooth device";
        }
        else
        {
            // ubertooth-util -v: "Firmware version: 2020-12-R1 (API:1.07)\n"
            // ubertooth-util -N: "0" or "1"

            status = true;
        }
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

void Ubertooth::startWork()
{
    //qDebug() << "Ubertooth::startWork(?)";

    if (m_path_specan.isEmpty()) return;
    if (m_childProcess) return;

#if defined(Q_OS_WINDOWS)
    return;
#endif

    m_ring_head = 0;
    m_ring_count = 0;
    m_values_latest.clear();
    m_max_max = s_rssi_offset;

    m_last_sweep_time = -1.0f;
    m_capture_rate = 0.0;
    m_capture_rate_emit = -1;
    m_emit_timer.invalidate(); // first sweep after start redraws immediately

    if (m_childProcess == nullptr)
    {
        m_childProcess = new QProcess();
    }

    if (m_childProcess)
    {
        connect(m_childProcess, SIGNAL(started()), this, SLOT(processStarted()));
        connect(m_childProcess, SIGNAL(finished(int)), this, SLOT(processFinished()));
        connect(m_childProcess, &QProcess::readyReadStandardOutput, this, &Ubertooth::processOutput);
        connect(m_childProcess, &QProcess::readyReadStandardError, this, &Ubertooth::processOutput);

        SettingsManager *sm = SettingsManager::getInstance();
        m_freq_min = sm->getUbertoothFreqMin();
        m_freq_max = sm->getUbertoothFreqMax();
        Q_EMIT freqChanged();

        // (Re)allocate the ring buffer now that the frequency range is known
        // Fill everything with the our default RSSI value
        m_ring_bins = getFreqBinCount();
        if (m_ring_bins > 0)
        {
            m_ring_buffer.assign(static_cast<size_t>(s_max_stack) * m_ring_bins, s_rssi_raw_default);
            m_blank_column.assign(m_ring_bins, s_rssi_raw_default);
        }
        else
        {
            m_ring_buffer.clear();
            m_blank_column.clear();
        }

        QStringList args;
        args << "-l" + QString::number(m_freq_min);
        args << "-u" + QString::number(m_freq_max);

        qDebug() << "Ubertooth::startWork()" << m_path_specan << args;
        m_childProcess->start(m_path_specan, args);
    }
}

/* ************************************************************************** */

void Ubertooth::stopWork()
{
    if (m_childProcess)
    {
        m_childProcess->write("q\n");

        if (m_childProcess->waitForFinished(333))
        {
            //qDebug() << "Ubertooth::stopWork()";
        }
        else
        {
            //qWarning() << "Ubertooth::stopWork() current process won't die...";
            m_childProcess->kill();
        }
    }
}

/* ************************************************************************** */

void Ubertooth::restartWork()
{
    //qDebug() << "Ubertooth::restartWork()";

    stopWork();
    QTimer::singleShot(333, this, &Ubertooth::startWork);
}

/* ************************************************************************** */
/* ************************************************************************** */

void Ubertooth::processStarted()
{
    if (m_childProcess)
    {
        qDebug() << "Ubertooth::processStarted()";
        Q_EMIT runningChanged();

        // Update ready?
        if (!m_hardwareAvailable)
        {
            m_hardwareAvailable = true;
            Q_EMIT availableChanged();
        }
    }
}

/* ************************************************************************** */

void Ubertooth::processFinished()
{
    if (m_childProcess)
    {
        int exitStatus = m_childProcess->exitStatus();
        int exitCode = m_childProcess->exitCode();

        m_childProcess->waitForFinished();
        m_childProcess->deleteLater();
        m_childProcess = nullptr;

        qDebug() << "Ubertooth::processFinished(status:" << exitStatus << "/ code:" << exitCode << ")";
        Q_EMIT runningChanged();
    }
}

/* ************************************************************************** */

void Ubertooth::processOutput()
{
    if (m_childProcess)
    {
        m_childProcess->waitForBytesWritten(33);

        QString output(m_childProcess_lastLineSplit);
        m_childProcess_lastLineSplit.clear();
        output += m_childProcess->readAllStandardOutput();

        //qDebug() << "Ubertooth::processOutput(" << output.size() << "bytes)" << output;

        bool sweepCompleted = false; // becomes true once this batch finishes at least one sweep

        // Make sure we have an in-progress slot to write the incoming sweep into
        if (m_ring_bins <= 0 || m_ring_buffer.empty()) return;
        if (m_ring_count == 0)
        {
            m_ring_count = 1;
            std::fill_n(ringSlot(m_ring_head), m_ring_bins, s_rssi_raw_default);
        }
        int *current_values = ringSlot(m_ring_head);

        // Parsing
        const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
        for (const auto &line: lines)
        {
            //qDebug() << "line (" << line.size() << ")" << line;

            const QStringList linesplit = line.split(',');
            if (line.size() >= 19 && !line.endsWith('-') && linesplit.size() == 3)
            {
                int freq = linesplit.at(1).toInt();
                int rssi = linesplit.at(2).toInt();

                if (freq < m_freq_min || freq > m_freq_max)
                {
                    qDebug() << "> warning > frequency" << freq << "not in range > [" << m_freq_min << "/" << m_freq_max << "]    ( rssi " << rssi << ")";
                    continue;
                }

                m_values_latest[freq] = rssi + s_rssi_offset;
                current_values[freq - m_freq_min] = rssi + s_rssi_offset;

                if (freq == m_freq_max)
                {
                    // Sweep complete: advance to the next ring slot (overwriting the
                    // oldest once full) and clear it to the sentinel for the next sweep.
                    m_ring_head = (m_ring_head + 1) % s_max_stack;
                    if (m_ring_count < s_max_stack) m_ring_count++;
                    current_values = ringSlot(m_ring_head);
                    std::fill_n(current_values, m_ring_bins, s_rssi_raw_default);

                    sweepCompleted = true;

                    // Capture rate: the first CSV field is the device timestamp in
                    // seconds. Turn the interval between consecutive completed sweeps
                    // into a Hz figure and smooth it (EMA) to tame the per-sweep jitter.
                    const float t = linesplit.at(0).toFloat();
                    if (m_last_sweep_time >= 0.0f)
                    {
                        const float dt = t - m_last_sweep_time;
                        if (dt > 0.001f && dt < 0.2f) // sane band: 1 Hz .. 200 Hz
                        {
                            const double inst = 1.0 / dt;
                            m_capture_rate = (m_capture_rate > 0.0) ? (m_capture_rate * 0.9 + inst * 0.1)
                                                                    : inst;
                        }
                    }
                    m_last_sweep_time = t;
                }
            }
            else
            {
                m_childProcess_lastLineSplit = line; // store unfinished line for next round
                //qDebug() << "> beware > data break at << " << line;
            }
        }

        // Drive the graphs once per data batch (event-driven, replaces the QML
        // polling timers) and refresh the capture-rate readout when it shifts.
        if (sweepCompleted)
        {
            // Capture-rate readout: not throttled, only emitted when it changes.
            const int r = qRound(m_capture_rate);
            if (r != m_capture_rate_emit)
            {
                m_capture_rate_emit = r;
                Q_EMIT captureRateChanged();
            }

            // Frame-rate cap: redraw at most ubertooth_samplingFreq times/second so
            // a fast capture can't overdraw the GUI. 0 (or less) means uncapped.
            const int fps = SettingsManager::getInstance()->getSpectrogramSamplingFreq();
            const qint64 minIntervalMs = (fps > 0) ? (1000 / fps) : 0;

            if (!m_emit_timer.isValid())
            {
                m_emit_timer.start();
                Q_EMIT newDataAvailable();
            }
            else if (m_emit_timer.elapsed() >= minIntervalMs)
            {
                m_emit_timer.restart();
                Q_EMIT newDataAvailable();
            }
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

QList <int *> Ubertooth::getChronologicalValues(const int maxColumns, const bool padHistory)
{
    QList <int *> out;

    if (m_ring_count <= 0 || m_ring_bins <= 0) return out;

    int dataColumnRequested = maxColumns;
    if (dataColumnRequested <= 0 || dataColumnRequested > s_max_stack) dataColumnRequested = s_max_stack;

    const int dataColumnsAvailable = std::min(m_ring_count, dataColumnRequested);

    const int dataColumsToPad = (padHistory && !m_blank_column.empty()) ? (dataColumnRequested - dataColumnsAvailable) : 0;

    out.reserve(dataColumsToPad + dataColumnsAvailable);

    // Optional left-padding
    for (int k = 0; k < dataColumsToPad; k++)
    {
        out.push_back(m_blank_column.data());
    }

    // Get the data
    int oldest = (m_ring_head - (dataColumnsAvailable - 1)) % s_max_stack;
    oldest = (oldest + s_max_stack) % s_max_stack;

    for (int k = 0; k < dataColumnsAvailable; k++)
    {
        out.push_back(ringSlot((oldest + k) % s_max_stack));
    }

    return out;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Ubertooth::getFrequencyGraphAxis(QValueAxis *axis)
{
    //qDebug() << "Ubertooth::getFrequencyGraphAxis()";

    if (!axis) return;

    axis->setMin(m_freq_min);
    axis->setMax(m_freq_max);
}

/* ************************************************************************** */

void Ubertooth::getFrequencyGraphMax(QLineSeries *serie)
{
    //qDebug() << "Ubertooth::getFrequencyGraphMax()" << serie;

    if (!serie) return;
    serie->clear();

    const int freqBinCount = getFreqBinCount();
    if (freqBinCount <= 0) return;

    // Hard max-hold: the per-bin maximum over the most-recent s_max_average_window
    // sweeps (NOT the whole ring), walked chronologically backward from the head
    // so it picks the right slots even after the ring has wrapped
    const int bins = std::min(freqBinCount, m_ring_bins);
    const int window = std::min(m_ring_count, s_max_average_window);

    std::vector <int> max(freqBinCount, s_rssi_raw_default);
    m_max_max = s_rssi_raw_default;

    for (int j = 0; j < window; j++)
    {
        const int idx = ((m_ring_head - j) % s_max_stack + s_max_stack) % s_max_stack;
        const int *table = ringSlot(idx);
        for (int i = 0; i < bins; i++)
        {
            if (table[i] > max[i]) max[i] = table[i];
            if (table[i] > m_max_max) m_max_max = table[i];
        }
    }

    // Locate the strongest bin (the "peak marker") of the s_max_average_window
    int peak_idx = -1;
    int peak_val = s_rssi_raw_default;

    for (int i = 0; i < freqBinCount; i++)
    {
        if (max[i] > peak_val) { peak_val = max[i]; peak_idx = i; }
        serie->append(m_freq_min + i, max[i]);
    }

    const int peak_freq = (peak_idx >= 0) ? (m_freq_min + peak_idx) : 0;
    if (peak_freq != m_peak_freq || peak_val != m_peak_dbm)
    {
        m_peak_freq = peak_freq;
        m_peak_dbm = peak_val;
        Q_EMIT peakChanged();
    }
}

/* ************************************************************************** */

void Ubertooth::getFrequencyGraphAverage(QLineSeries *serie)
{
    //qDebug() << "Ubertooth::getFrequencyGraphAverage()" << serie;

    if (!serie) return;
    serie->clear();

    const int freqBinCount = getFreqBinCount();
    if (freqBinCount <= 0) return;

    std::vector <qint64> sum(freqBinCount, 0);
    std::vector <int> cnt(freqBinCount, 0);

    // Average over the most-recent s_max_average_window sweeps
    // (same window as the max-hold line), walked chronologically backward from the head
    const int bins = std::min(freqBinCount, m_ring_bins);
    const int window = std::min(m_ring_count, s_max_average_window);

    for (int j = 0; j < window; j++)
    {
        const int idx = ((m_ring_head - j) % s_max_stack + s_max_stack) % s_max_stack;
        const int *table = ringSlot(idx);
        for (int i = 0; i < bins; i++)
        {
            // Some cells values are never reported by a sweep,
            // their values will be below the s_rssi_hole_threshold
            if (table[i] > s_rssi_hole_threshold)
            {
                sum[i] += table[i];
                cnt[i]++;
            }
        }
    }

    for (int i = 0; i < freqBinCount; i++)
    {
        const int avg = cnt[i] ? static_cast<int>(sum[i] / cnt[i]) : s_rssi_raw_default;
        serie->append(m_freq_min + i, avg);
    }
}

/* ************************************************************************** */

void Ubertooth::getFrequencyGraphCurrent(QLineSeries *serie)
{
    //qDebug() << "Ubertooth::getFrequencyGraphCurrent()" << serie;

    if (!serie) return;
    serie->clear();

    for (int i = m_freq_min; i <= m_freq_max; i++)
    {
        serie->append(i, m_values_latest[i]);
    }
}

/* ************************************************************************** */

void Ubertooth::getFrequencyGraphData(QLineSeries *serie, int index)
{
    //qDebug() << "Ubertooth::getFrequencyGraphData()" << serie << index;

    if (!serie) return;
    serie->clear();

    if (index < 0 || index >= m_ring_count) return;

    const int freqBinCount = getFreqBinCount();
    if (freqBinCount <= 0) return;

    // index 0 = newest (the in-progress head), counting back through the ring
    int idx = (m_ring_head - index) % s_max_stack;
    idx = (idx + s_max_stack) % s_max_stack;
    const int *current = ringSlot(idx);

    const int bins = std::min(freqBinCount, m_ring_bins);
    for (int i = 0; i < bins; i++)
    {
        serie->append(m_freq_min + i, current[i]);
    }
}

/* ************************************************************************** */
/* ************************************************************************** */
