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
#include "ubertooth.h"

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
    if (!m_ubertooth) return;

    const int rows = m_ubertooth->getFreqBinCount();
    const QList <int *> &cols = m_ubertooth->getChronologicalValues(m_maxDepth, true);
    const int ncols = cols.size();

    if (rows <= 0 || ncols <= 0) return;

    if (m_image.width() != ncols || m_image.height() != rows)
    {
        m_image = QImage(ncols, rows, QImage::Format_RGB32);
    }

    const double range = (m_ceilDb - m_floorDb);
    const double invRange = (range != 0.0) ? (1.0 / range) : 0.0;

    // Y is flipped so the lowest frequency sits at the bottom of the image
    for (int i = 0; i < rows; i++)
    {
        QRgb *line = reinterpret_cast<QRgb *>(m_image.scanLine(rows - 1 - i));
        for (int x = 0; x < ncols; x++)
        {
            const int *col = cols.at(x);
            const double t = (col[i] - m_floorDb) * invRange; // normalize to 0..1
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
        m_ubertooth = qobject_cast<Ubertooth *>(source);
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
