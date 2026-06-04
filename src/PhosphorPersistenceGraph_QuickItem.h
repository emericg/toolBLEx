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

#ifndef PHOSPHOR_PERSISTENCE_GRAPH_QUICKITEM_H
#define PHOSPHOR_PERSISTENCE_GRAPH_QUICKITEM_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>

#include <QQuickPaintedItem>
#include <QPointer>
#include <QImage>
#include <QColor>

class Ubertooth;

/* ************************************************************************** */

/*!
 * \brief Analog-scope style "phosphor persistence" spectrum history renderer.
 *
 * Designed to sit as an underlay below the FrequencyGraph axes/lines: it maps
 * frequency across its width and magnitude (floorDb..ceilDb) across its height,
 * matching the GraphsView plot area, and fades towards transparent so the
 * themed background and channel-band guides show through.
 *
 * Each refresh() draws the latest sweep as a bright trace into an accumulation
 * image, then fades the whole image a little towards transparent. Bins the
 * signal visits often stay bright, transient hits leave a fading trail, which
 * visually encodes the statistical distribution of the spectrum over time.
 *
 * The persistence buffer should be clear()ed when the capture (re)starts,
 * so a stale spectrum history doesn't linger on screen.
 */
class PhosphorPersistenceGraph_QuickItem: public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QObject *dataSource READ source WRITE setSource NOTIFY sourceChanged)

    Q_PROPERTY(qreal floorDb READ floorDb WRITE setFloorDb NOTIFY rangeChanged)
    Q_PROPERTY(qreal ceilDb READ ceilDb WRITE setCeilDb NOTIFY rangeChanged)
    Q_PROPERTY(QColor traceColor READ traceColor WRITE setTraceColor NOTIFY traceColorChanged)
    Q_PROPERTY(int decay READ decay WRITE setDecay NOTIFY decayChanged)

    QPointer <QObject> m_source;
    Ubertooth *m_ubertooth = nullptr;

    qreal m_floorDb = -100.0;       //!< magnitude mapped to the bottom edge
    qreal m_ceilDb = -20.0;         //!< magnitude mapped to the top edge
    QColor m_traceColor = QColor(128, 128, 128); //!< colour of the live trace
    int m_decay = 28;               //!< per-frame fade amount (1..255), higher = shorter trails

    QImage m_accum;                 //!< ARGB persistence buffer (item-pixel sized)

    void ensureImage();

Q_SIGNALS:
    void sourceChanged();
    void rangeChanged();
    void traceColorChanged();
    void decayChanged();

public:
    explicit PhosphorPersistenceGraph_QuickItem(QQuickItem *parent = nullptr);

    QObject *source() const { return m_source; }
    void setSource(QObject *source);

    qreal floorDb() const { return m_floorDb; }
    void setFloorDb(qreal v);

    qreal ceilDb() const { return m_ceilDb; }
    void setCeilDb(qreal v);

    QColor traceColor() const { return m_traceColor; }
    void setTraceColor(const QColor &v);

    int decay() const { return m_decay; }
    void setDecay(int v);

    void paint(QPainter *painter) override;

    //! Draw the latest sweep into the persistence buffer and request a repaint.
    Q_INVOKABLE void refresh();

    //! Wipe the persistence buffer (e.g. on retune or manual clear).
    Q_INVOKABLE void clear();
};

/* ************************************************************************** */
#endif // PHOSPHOR_PERSISTENCE_GRAPH_QUICKITEM_H
