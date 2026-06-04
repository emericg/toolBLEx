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

#include "PhosphorPersistenceGraph_QuickItem.h"
#include "ubertooth.h"

#include <QPainter>
#include <QPainterPath>
#include <QMap>
#include <algorithm>

/* ************************************************************************** */

PhosphorPersistenceGraph_QuickItem::PhosphorPersistenceGraph_QuickItem(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
    setFillColor(Qt::transparent);
}

/* ************************************************************************** */
/* ************************************************************************** */

void PhosphorPersistenceGraph_QuickItem::ensureImage()
{
    const int w = std::max(1, static_cast<int>(width()));
    const int h = std::max(1, static_cast<int>(height()));

    if (m_accum.width() != w || m_accum.height() != h)
    {
        m_accum = QImage(w, h, QImage::Format_ARGB32_Premultiplied);
        m_accum.fill(Qt::transparent);
    }
}

/* ************************************************************************** */

void PhosphorPersistenceGraph_QuickItem::clear()
{
    if (!m_accum.isNull())
    {
        m_accum.fill(Qt::transparent);
        update();
    }
}

/* ************************************************************************** */

void PhosphorPersistenceGraph_QuickItem::paint(QPainter *painter)
{
    if (m_accum.isNull()) return;

    painter->drawImage(boundingRect(), m_accum);
}

/* ************************************************************************** */
/* ************************************************************************** */

void PhosphorPersistenceGraph_QuickItem::refresh()
{
    if (!m_ubertooth) return;

    const int bins = m_ubertooth->getFreqBinCount();
    if (bins <= 0) return;

    const QMap <int, int> &latest = m_ubertooth->getLatestValues();
    if (latest.isEmpty()) return;

    ensureImage();
    if (m_accum.isNull()) return;

    const int W = m_accum.width();
    const int H = m_accum.height();
    const int fmin = m_ubertooth->getFreqMin();

    QPainter p(&m_accum);

    // Fade the whole buffer towards transparent: DestinationIn multiplies the
    // existing alpha by (255 - decay) / 255, so old traces gradually vanish
    p.setCompositionMode(QPainter::CompositionMode_DestinationIn);
    p.fillRect(m_accum.rect(), QColor(0, 0, 0, 255 - std::clamp(m_decay, 1, 255)));

    // Draw the current sweep as a fresh, opaque trace on top
    p.setCompositionMode(QPainter::CompositionMode_SourceOver);
    p.setRenderHint(QPainter::Antialiasing, true);

    QPen pen(m_traceColor);
    pen.setWidthF(1.25);
    p.setPen(pen);

    const double range = (m_ceilDb - m_floorDb);
    const double invRange = (range != 0.0) ? (1.0 / range) : 0.0;

    QPainterPath path;
    for (int i = 0; i < bins; i++)
    {
        const int v = latest.value(fmin + i, static_cast<int>(m_floorDb));

        const double x = (bins > 1) ? (static_cast<double>(i) / (bins - 1)) * (W - 1) : 0.0;

        double t = (v - m_floorDb) * invRange; // normalize to 0..1
        t = std::clamp(t, 0.0, 1.0);

        const double y = (1.0 - t) * (H - 1); // ceilDb at top, floorDb at bottom

        if (i == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
    }
    p.drawPath(path);
    p.end();

    update();
}

/* ************************************************************************** */
/* ************************************************************************** */

void PhosphorPersistenceGraph_QuickItem::setSource(QObject *source)
{
    if (m_source != source)
    {
        m_source = source;
        m_ubertooth = qobject_cast<Ubertooth *>(source);
        Q_EMIT sourceChanged();
    }
}

void PhosphorPersistenceGraph_QuickItem::setFloorDb(qreal v)
{
    if (!qFuzzyCompare(m_floorDb, v))
    {
        m_floorDb = v;
        Q_EMIT rangeChanged();
    }
}

void PhosphorPersistenceGraph_QuickItem::setCeilDb(qreal v)
{
    if (!qFuzzyCompare(m_ceilDb, v))
    {
        m_ceilDb = v;
        Q_EMIT rangeChanged();
    }
}

void PhosphorPersistenceGraph_QuickItem::setTraceColor(const QColor &v)
{
    if (m_traceColor != v)
    {
        m_traceColor = v;
        Q_EMIT traceColorChanged();
    }
}

void PhosphorPersistenceGraph_QuickItem::setDecay(int v)
{
    v = std::clamp(v, 1, 255);
    if (m_decay != v)
    {
        m_decay = v;
        Q_EMIT decayChanged();
    }
}

/* ************************************************************************** */
