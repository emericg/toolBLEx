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
#include "ubertooth.h"

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
    if (!m_ubertooth || !series) return;

    QSurfaceDataProxy *proxy = series->dataProxy();
    if (!proxy) return;

    const int rows = m_ubertooth->getFreqBinCount();
    const QList <int *> &cols = m_ubertooth->getChronologicalValues(m_maxDepth, true);
    const int available = cols.size();

    if (rows <= 0 || available <= 0) return;

    const int ncols = (m_maxDepth > 0) ? std::min(available, m_maxDepth) : available;
    const int startCol = available - ncols;

    const float fmin = static_cast<float>(m_ubertooth->getFreqMin());
    const float floor = static_cast<float>(m_floorDb);
    const float holeThreshold = -125.0f; // any value below this threshold is a hole in the data

    // Copy the matrix to floats, gap-filling holes with the nearest valid value
    // along the frequency axis (sample-and-hold), so missing bins don't punch
    // spikes through the floor like they do with the raw sentinel.
    std::vector<float> m(static_cast<size_t>(ncols) * rows);
    for (int t = 0; t < ncols; t++)
    {
        const int *col = cols.at(startCol + t);
        float *dst = m.data() + static_cast<size_t>(t) * rows;

        float last = floor;
        bool seen = false;
        for (int i = 0; i < rows; i++) // forward fill
        {
            const float v = static_cast<float>(col[i]);
            if (v < holeThreshold) { dst[i] = last; }
            else { dst[i] = v; last = v; seen = true; }
        }
        if (seen) // backward fill leading holes
        {
            float next = floor;
            for (int i = rows - 1; i >= 0; i--)
            {
                if (static_cast<float>(col[i]) < holeThreshold && dst[i] <= floor) dst[i] = next;
                else next = dst[i];
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
            row.append(QSurfaceDataItem(QVector3D(fmin + i, y, static_cast<float>(age))));
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
        m_ubertooth = qobject_cast<Ubertooth *>(source);
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
