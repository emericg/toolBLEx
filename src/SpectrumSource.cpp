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

#include "SpectrumSource.h"

#include <QTimer>
#include <QDebug>

#include <algorithm>
#include <vector>

/* ************************************************************************** */
/* ************************************************************************** */

SpectrumSource::SpectrumSource(QObject *parent) : QObject(parent)
{
    //
}

SpectrumSource::~SpectrumSource()
{
    if (m_childProcess)
    {
        m_childProcess->kill();
        m_childProcess->waitForFinished(333);
    }

    m_ring_buffer.clear();
    m_blank_column.clear();
    m_ring_head = 0;
    m_ring_count = 0;
    m_ring_bins = 0;
    m_values_latest.clear();
    m_max_max = s_rssi_raw_default;
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumSource::setDeviceIndex(int index)
{
    if (index < 0) index = 0;

    if (m_deviceIndex != index)
    {
        m_deviceIndex = index;
        Q_EMIT deviceIndexChanged();
    }
}

void SpectrumSource::setFloorDb(double v)
{
    if (!qFuzzyCompare(m_floorDb, v))
    {
        m_floorDb = v;
        Q_EMIT rangeChanged();
    }
}

void SpectrumSource::setCeilDb(double v)
{
    if (!qFuzzyCompare(m_ceilDb, v))
    {
        m_ceilDb = v;
        Q_EMIT rangeChanged();
    }
}

/* ************************************************************************** */

void SpectrumSource::requestStop(QProcess *process)
{
    if (process) process->terminate();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumSource::allocateRing()
{
    m_ring_bins = getFreqBinCount();

    if (m_ring_bins > s_max_bins)
    {
        // Too many bins (e.g. a wide band in kHz units): refuse rather than allocate hundreds of MB.
        // Capture stays disabled until the band/unit is sane again.
        qWarning() << "SpectrumSource::allocateRing() bin count" << m_ring_bins
                   << "exceeds" << s_max_bins << "- band too wide for this unit; use MHz for wide spans.";
        m_ring_bins = 0;
    }

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
}

/* ************************************************************************** */

void SpectrumSource::startWork()
{
    if (m_childProcess) return;

#if defined(Q_OS_WINDOWS)
    return;
#endif

    // Let the subclass refresh its frequency range / unit before we size the ring.
    configureForStart();

    const QString binary = binaryPath();
    if (binary.isEmpty()) return;

    const QStringList args = buildArguments();

    // Reset the rolling state.
    m_ring_head = 0;
    m_ring_count = 0;
    m_buffer.clear();
    m_last_bin = -1;
    m_values_latest.clear();
    m_max_max = s_rssi_raw_default;
    m_capture_rate = 0.0;
    m_capture_rate_emit = -1;
    m_sweeps_in_window = 0;
    m_sweep_timer.invalidate(); // first completed sweep just primes the timer

    allocateRing();

    m_childProcess = new QProcess();
    if (m_childProcess)
    {
        connect(m_childProcess, SIGNAL(started()), this, SLOT(processStarted()));
        connect(m_childProcess, SIGNAL(finished(int)), this, SLOT(processFinished()));
        connect(m_childProcess, &QProcess::readyReadStandardOutput, this, &SpectrumSource::processOutput);
        connect(m_childProcess, &QProcess::readyReadStandardError, this, &SpectrumSource::processError);

        qDebug() << "SpectrumSource::startWork()" << binary << args;
        m_childProcess->start(binary, args);
    }
}

/* ************************************************************************** */

void SpectrumSource::stopWork()
{
    if (m_childProcess)
    {
        requestStop(m_childProcess);

        if (!m_childProcess->waitForFinished(333))
        {
            m_childProcess->kill();
        }
    }
}

/* ************************************************************************** */

void SpectrumSource::restartWork()
{
    if (m_childProcess)
    {
        stopWork();
        QTimer::singleShot(333, this, &SpectrumSource::startWork);
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumSource::processStarted()
{
    if (m_childProcess)
    {
        qDebug() << "SpectrumSource::processStarted()";
        Q_EMIT runningChanged();

        if (!m_hardwareAvailable)
        {
            m_hardwareAvailable = true; // obviously...
            Q_EMIT availableChanged();
        }
    }
}

/* ************************************************************************** */

void SpectrumSource::processFinished()
{
    if (m_childProcess)
    {
        int exitStatus = m_childProcess->exitStatus();
        int exitCode = m_childProcess->exitCode();

        m_childProcess->waitForFinished();
        m_childProcess->deleteLater();
        m_childProcess = nullptr;

        qDebug() << "SpectrumSource::processFinished(status:" << exitStatus << "/ code:" << exitCode << ")";
        Q_EMIT runningChanged();
    }
}

/* ************************************************************************** */

void SpectrumSource::processError()
{
    if (!m_childProcess) return;

    const QString err = m_childProcess->readAllStandardError();
    if (!err.isEmpty())
    {
        if (err.contains("No supported devices", Qt::CaseInsensitive) ||
            err.contains("No devices found", Qt::CaseInsensitive) ||
            err.contains("usb_claim_interface error", Qt::CaseInsensitive))
        {
            qWarning() << "SpectrumSource::processError()" << err.trimmed();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumSource::advanceSweep(int *&current_values, bool &sweepCompleted)
{
    m_ring_head = (m_ring_head + 1) % s_max_stack;
    if (m_ring_count < s_max_stack) m_ring_count++;
    current_values = ringSlot(m_ring_head);
    std::fill_n(current_values, m_ring_bins, s_rssi_raw_default);

    sweepCompleted = true;
    m_sweeps_in_window++; // counted here; the rate is computed over a time window in processOutput()
}

/* ************************************************************************** */

void SpectrumSource::recordBin(int unitFreq, int dB, int *&current_values, bool &sweepCompleted)
{
    if (unitFreq < m_freq_min || unitFreq > m_freq_max) return;

    // Sweep-wrap detection: within a sweep the frequency only ever increases,
    // so a strictly lower bin means a new sweep has begun. Close the previous one
    // (advance the ring) *before* writing this bin into the fresh slot.
    // This is backend-agnostic, working for any output format.
    if (m_last_bin >= 0 && unitFreq < m_last_bin)
    {
        advanceSweep(current_values, sweepCompleted);
    }
    m_last_bin = unitFreq;

    int &cell = current_values[unitFreq - m_freq_min];
    if (dB > cell) cell = dB;           // within-sweep max for this bucket
    m_values_latest[unitFreq] = cell;
}

/* ************************************************************************** */

void SpectrumSource::processOutput()
{
    if (!m_childProcess) return;
    if (m_ring_bins <= 0 || m_ring_buffer.empty()) return;

    m_buffer += QString(m_childProcess->readAllStandardOutput());

    // Make sure we have an in-progress slot to write the incoming sweep into.
    if (m_ring_count == 0)
    {
        m_ring_count = 1;
        std::fill_n(ringSlot(m_ring_head), m_ring_bins, s_rssi_raw_default);
    }
    int *current_values = ringSlot(m_ring_head);

    bool sweepCompleted = false; // becomes true once this batch finishes a sweep

    // Consume only complete lines; keep any trailing partial line for next time.
    int nl;
    while ((nl = m_buffer.indexOf('\n')) >= 0)
    {
        const QString line = m_buffer.left(nl).trimmed();
        m_buffer.remove(0, nl + 1);

        if (line.isEmpty() || line.startsWith('#')) continue; // blanks / comments

        parseLine(line, current_values, sweepCompleted);
    }

    if (sweepCompleted)
    {
        // Capture rate: count completed sweeps over a wall-clock window, then
        // rate = sweeps / elapsed. Counting across the whole batch (rather than
        // timing consecutive sweeps) is robust to a fast source that delivers
        // several sweeps per read -- which otherwise makes the rate read low.
        if (!m_sweep_timer.isValid())
        {
            m_sweep_timer.start();
            m_sweeps_in_window = 0;
        }
        else if (m_sweep_timer.elapsed() >= 250) // refresh the figure ~4x/second
        {
            const qint64 ms = m_sweep_timer.elapsed();
            const double inst = (m_sweeps_in_window * 1000.0) / static_cast<double>(ms);
            m_capture_rate = (m_capture_rate > 0.0) ? (m_capture_rate * 0.6 + inst * 0.4) : inst;
            m_sweeps_in_window = 0;
            m_sweep_timer.restart();

            const int r = qRound(m_capture_rate);
            if (r != m_capture_rate_emit)
            {
                m_capture_rate_emit = r;
                Q_EMIT captureRateChanged();
            }
        }

        Q_EMIT newDataAvailable();
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

QList <int *> SpectrumSource::getChronologicalValues(const int maxColumns, const bool padHistory)
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

    // Get the data (ring indices are always laid out modulo s_max_stack)
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

void SpectrumSource::getFrequencyGraphAxis(QValueAxis *axis)
{
    if (!axis) return;

    if (m_unit == FrequencyUnit::kHz)
    {
        axis->setMin(m_freq_min / 1000.0);
        axis->setMax(m_freq_max / 1000.0);
    }
    else
    {
        axis->setMin(m_freq_min);
        axis->setMax(m_freq_max);
    }
}

/* ************************************************************************** */

void SpectrumSource::getFrequencyGraphMax(QLineSeries *serie)
{
    if (!serie) return;
    serie->clear();

    const int freqBinCount = getFreqBinCount();
    if (freqBinCount <= 0) return;

    // Hard max-hold over the most-recent s_max_average_window sweeps, walked
    // chronologically backward from the head so it survives a ring wrap.
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

    // Locate the strongest bin (the "peak marker") of the window.
    int peak_idx = -1;
    int peak_val = s_rssi_raw_default;

    for (int i = 0; i < freqBinCount; i++)
    {
        if (max[i] > peak_val) { peak_val = max[i]; peak_idx = i; }

        if (m_unit == FrequencyUnit::kHz) {
            serie->append((m_freq_min + i) / 1000.0, max[i]);
        } else {
            serie->append(m_freq_min + i, max[i]);
        }
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

void SpectrumSource::getFrequencyGraphAverage(QLineSeries *serie)
{
    if (!serie) return;
    serie->clear();

    const int freqBinCount = getFreqBinCount();
    if (freqBinCount <= 0) return;

    std::vector <qint64> sum(freqBinCount, 0);
    std::vector <int> cnt(freqBinCount, 0);

    // Average over the most-recent s_max_average_window sweeps.
    const int bins = std::min(freqBinCount, m_ring_bins);
    const int window = std::min(m_ring_count, s_max_average_window);

    for (int j = 0; j < window; j++)
    {
        const int idx = ((m_ring_head - j) % s_max_stack + s_max_stack) % s_max_stack;
        const int *table = ringSlot(idx);
        for (int i = 0; i < bins; i++)
        {
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

        if (m_unit == FrequencyUnit::kHz) {
            serie->append((m_freq_min + i) / 1000.0, avg);
        } else {
            serie->append(m_freq_min + i, avg);
        }
    }
}

/* ************************************************************************** */

void SpectrumSource::getFrequencyGraphCurrent(QLineSeries *serie)
{
    if (!serie) return;
    serie->clear();

    for (int i = m_freq_min; i <= m_freq_max; i++)
    {
        if (m_unit == FrequencyUnit::kHz) {
            serie->append(i / 1000.0, m_values_latest[i]);
        } else {
            serie->append(i, m_values_latest[i]);
        }
    }
}

/* ************************************************************************** */

void SpectrumSource::getFrequencyGraphData(QLineSeries *serie, int index)
{
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
        if (m_unit == FrequencyUnit::kHz) {
            serie->append((m_freq_min + i) / 1000.0, current[i]);
        } else {
            serie->append(m_freq_min + i, current[i]);
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */
