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

#include "WaterfallGraph_QuickItem.h"
#include "ColormapFactory.h"
#include "SettingsManager.h"
#include "SpectrumSource.h"

#include <QPainter>
#include <algorithm>

/* ************************************************************************** */
/* ************************************************************************** */

WaterfallGraph_QuickItem::WaterfallGraph_QuickItem(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    m_colorScheme = SettingsManager::getInstance()->getSpectrogramGraphColors();

    ColormapFactory::fillLut(static_cast<ColormapFactory::Scheme>(m_colorScheme), m_lut, m_floorDb, m_ceilDb);
}

/* ************************************************************************** */

void WaterfallGraph_QuickItem::refresh()
{
    if (!m_dataSource) return;

    const int rawRows = m_dataSource->getFreqBinCount();
    const QList <int *> &cols = m_dataSource->getChronologicalValues(m_maxDepth, true);
    const int ncols = cols.size();

    if (rawRows <= 0 || ncols <= 0) return;

    // Frequency decimation:
    // max-pool rawRows input bins into at most m_maxFreqBins image rows,
    // so a fine (e.g. 2001-bin kHz) source doesn't build a huge image.
    const int maxF = (m_maxFreqBins > 0) ? m_maxFreqBins : rawRows;
    const int group = std::max(1, (rawRows + maxF - 1) / maxF);
    const int rows = (rawRows + group - 1) / group;

    if (m_image.width() != ncols || m_image.height() != rows)
    {
        m_image = QImage(ncols, rows, QImage::Format_RGB32);
    }

    const double range = (m_ceilDb - m_floorDb);
    const double invRange = (range != 0.0) ? (1.0 / range) : 0.0;

    // Y is flipped so the lowest frequency sits at the bottom of the image
    for (int o = 0; o < rows; o++)
    {
        QRgb *line = reinterpret_cast<QRgb *>(m_image.scanLine(rows - 1 - o));
        const int i0 = o * group;
        const int i1 = std::min(i0 + group, rawRows);
        for (int x = 0; x < ncols; x++)
        {
            const int *col = cols.at(x);
            int v = col[i0];                                  // max-pool the group
            for (int i = i0 + 1; i < i1; i++) if (col[i] > v) v = col[i];
            const double t = (v - m_floorDb) * invRange;      // normalize to 0..1
            int idx = int(t * 255.0 + 0.5);
            idx = std::clamp(idx, 0, 255);
            line[x] = m_lut[idx];
        }
    }

    update();
}

void WaterfallGraph_QuickItem::paint(QPainter *painter)
{
    if (m_image.isNull()) return;

    painter->setRenderHint(QPainter::SmoothPixmapTransform, m_smooth);
    painter->drawImage(boundingRect(), m_image);
}

/* ************************************************************************** */

void WaterfallGraph_QuickItem::setSource(QObject *source)
{
    if (m_source != source)
    {
        m_source = source;
        m_dataSource = qobject_cast<SpectrumSource *>(source);
        Q_EMIT sourceChanged();

        refresh();
    }
}

void WaterfallGraph_QuickItem::setMaxDepth(int v)
{
    if (v < 0) v = 0;

    if (m_maxDepth != v)
    {
        m_maxDepth = v;
        Q_EMIT maxDepthChanged();

        refresh();
    }
}

void WaterfallGraph_QuickItem::setMaxFreqBins(int v)
{
    if (v < 0) v = 0;

    if (m_maxFreqBins != v)
    {
        m_maxFreqBins = v;
        Q_EMIT maxFreqBinsChanged();

        refresh();
    }
}

void WaterfallGraph_QuickItem::setFloorDb(qreal value)
{
    if (!qFuzzyCompare(m_floorDb, value))
    {
        m_floorDb = value;
        Q_EMIT rangeChanged();

        ColormapFactory::fillLut(static_cast<ColormapFactory::Scheme>(m_colorScheme),
                                 m_lut, m_floorDb, m_ceilDb);

        refresh();
    }
}

void WaterfallGraph_QuickItem::setCeilDb(qreal value)
{
    if (!qFuzzyCompare(m_ceilDb, value))
    {
        m_ceilDb = value;
        Q_EMIT rangeChanged();

        ColormapFactory::fillLut(static_cast<ColormapFactory::Scheme>(m_colorScheme),
                                 m_lut, m_floorDb, m_ceilDb);

        refresh();
    }
}

void WaterfallGraph_QuickItem::setSmooth(bool value)
{
    if (m_smooth != value)
    {
        m_smooth = value;
        Q_EMIT smoothChanged();

        update();
    }
}

void WaterfallGraph_QuickItem::setColorScheme(int value)
{
    if (m_colorScheme != value)
    {
        m_colorScheme = static_cast<ColormapFactory::Scheme>(value);
        Q_EMIT colorsChanged();

        ColormapFactory::fillLut(static_cast<ColormapFactory::Scheme>(m_colorScheme),
                                 m_lut, m_floorDb, m_ceilDb);

        refresh();
    }
}

/* ************************************************************************** */
