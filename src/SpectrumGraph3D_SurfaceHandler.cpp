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

#include "SpectrumGraph3D_SurfaceHandler.h"
#include "SpectrumSource.h"

#include <QSurfaceDataProxy>
#include <QSurface3DSeries>
#include <QVector3D>

#include <algorithm>
#include <utility>
#include <vector>

/* ************************************************************************** */

SpectrumGraph3D_SurfaceHandler::SpectrumGraph3D_SurfaceHandler(QObject *parent) : QObject(parent)
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumGraph3D_SurfaceHandler::refresh(QSurface3DSeries *series)
{
    if (!m_dataSource || !series) return;

    QSurfaceDataProxy *proxy = series->dataProxy();
    if (!proxy) return;

    const int rawRows = m_dataSource->getFreqBinCount();
    const QList <int *> &cols = m_dataSource->getChronologicalValues(m_maxDepth, true);
    const int available = cols.size();

    if (rawRows <= 0 || available <= 0) return;

    // Frequency decimation: max-pool rawRows input bins into at most m_maxFreqBins
    // output points, so a fine (e.g. 2001-bin kHz) source doesn't build an absurd
    // mesh. Max-pooling keeps peaks; `group` input bins collapse to one output bin.
    const int maxF = (m_maxFreqBins > 0) ? m_maxFreqBins : rawRows;
    const int group = std::max(1, (rawRows + maxF - 1) / maxF);
    const int rows = (rawRows + group - 1) / group;

    const int ncols = (m_maxDepth > 0) ? std::min(available, m_maxDepth) : available;
    const int startCol = available - ncols;

    const float fmin = static_cast<float>(m_dataSource->getFreqMin());
    const float floor = static_cast<float>(m_floorDb);
    const float holeThreshold = -125.0f; // any value below this threshold is a hole in the data

    // Max-pool into floats, then gap-fill holes with the nearest valid value along
    // the frequency axis (sample-and-hold), so missing bins don't punch spikes
    // through the floor like they do with the raw sentinel.
    std::vector<float> m(static_cast<size_t>(ncols) * rows);
    for (int t = 0; t < ncols; t++)
    {
        const int *col = cols.at(startCol + t);
        float *dst = m.data() + static_cast<size_t>(t) * rows;

        // max-pool: each output bin o takes the strongest valid input bin in its group
        for (int o = 0; o < rows; o++)
        {
            const int i0 = o * group;
            const int i1 = std::min(i0 + group, rawRows);
            float best = floor; bool any = false;
            for (int i = i0; i < i1; i++)
            {
                const float v = static_cast<float>(col[i]);
                if (v < holeThreshold) continue; // skip holes
                if (!any || v > best) { best = v; any = true; }
            }
            dst[o] = any ? best : static_cast<float>(-128); // hole sentinel for gap-fill below
        }

        float last = floor;
        bool seen = false;
        for (int o = 0; o < rows; o++) // forward fill
        {
            if (dst[o] < holeThreshold) { dst[o] = last; }
            else { last = dst[o]; seen = true; }
        }
        if (seen) // backward fill leading holes
        {
            float next = floor;
            for (int o = rows - 1; o >= 0; o--)
            {
                if (dst[o] <= floor) dst[o] = next;
                else next = dst[o];
            }
        }
    }

    // Separable box blur (frequency then time) to turn stacked noisy rows into
    // a coherent surface. Radii are tunable; 0 disables a pass.
    const int rf = m_freqSmoothing;
    const int rt = m_timeSmoothing;

    if (rf > 0)
    {
        std::vector<float> tmp(m.size());
        for (int t = 0; t < ncols; t++)
        {
            const float *src = m.data() + static_cast<size_t>(t) * rows;
            float *dst = tmp.data() + static_cast<size_t>(t) * rows;
            for (int i = 0; i < rows; i++)
            {
                float sum = 0.0f; int cnt = 0;
                for (int k = -rf; k <= rf; k++)
                {
                    const int j = i + k;
                    if (j >= 0 && j < rows)
                    {
                        sum += src[j]; cnt++;
                    }
                }
                dst[i] = sum / cnt;
            }
        }
        m.swap(tmp);
    }

    if (rt > 0)
    {
        std::vector<float> tmp(m.size());
        for (int i = 0; i < rows; i++)
        {
            for (int t = 0; t < ncols; t++)
            {
                float sum = 0.0f; int cnt = 0;
                for (int k = -rt; k <= rt; k++)
                {
                    const int u = t + k;
                    if (u >= 0 && u < ncols)
                    {
                        sum += m[static_cast<size_t>(u) * rows + i]; cnt++;
                    }
                }
                tmp[static_cast<size_t>(t) * rows + i] = sum / cnt;
            }
        }
        m.swap(tmp);
    }

    // Emit one surface row per sweep: X = frequency, Y = magnitude, Z = age (0 = newest sweep, ncols-1 = oldest).
    // Rows are emitted newest-first so the proxy still receives them in ascending Z order;
    // the QML axisZ is reversed so the newest (0) renders on the right, like the 2D waterfall.
    QSurfaceDataArray array;
    array.reserve(ncols);

    for (int age = 0; age < ncols; age++)
    {
        const float *src = m.data() + static_cast<size_t>(ncols - 1 - age) * rows; // newest first

        QSurfaceDataRow row;
        row.reserve(rows);
        for (int i = 0; i < rows; i++)
        {
            float y = src[i];
            if (y < floor) y = floor;

            // output bin i back to a real frequency (group input bins per output bin)
            float freq = fmin + (i + 0.5f) * static_cast<float>(group);
            if (m_dataSource->frequencyUnit() == 1) freq /= 1000.f; // FrequencyUnit::kHz

            row.append(QSurfaceDataItem(QVector3D(freq, y, static_cast<float>(age))));
        }
        array.append(std::move(row));
    }

    proxy->resetArray(std::move(array));
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumGraph3D_SurfaceHandler::setSource(QObject *source)
{
    if (m_source != source)
    {
        m_source = source;
        m_dataSource = qobject_cast<SpectrumSource *>(source);
        Q_EMIT sourceChanged();
    }
}

void SpectrumGraph3D_SurfaceHandler::setMaxDepth(int v)
{
    if (v < 0) v = 0;

    if (m_maxDepth != v)
    {
        m_maxDepth = v;
        Q_EMIT maxDepthChanged();
    }
}

void SpectrumGraph3D_SurfaceHandler::setMaxFreqBins(int v)
{
    if (v < 0) v = 0;

    if (m_maxFreqBins != v)
    {
        m_maxFreqBins = v;
        Q_EMIT maxFreqBinsChanged();
    }
}

void SpectrumGraph3D_SurfaceHandler::setFloorDb(qreal v)
{
    if (!qFuzzyCompare(m_floorDb, v))
    {
        m_floorDb = v;
        Q_EMIT floorDbChanged();
    }
}

void SpectrumGraph3D_SurfaceHandler::setTimeSmoothing(int v)
{
    if (v < 0) v = 0;

    if (m_timeSmoothing != v)
    {
        m_timeSmoothing = v;
        Q_EMIT smoothingChanged();
    }
}

void SpectrumGraph3D_SurfaceHandler::setFreqSmoothing(int v)
{
    if (v < 0) v = 0;

    if (m_freqSmoothing != v)
    {
        m_freqSmoothing = v;
        Q_EMIT smoothingChanged();
    }
}

/* ************************************************************************** */
