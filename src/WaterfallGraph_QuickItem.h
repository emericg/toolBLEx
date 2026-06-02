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

#ifndef WATERFALL_GRAPH_QUICKITEM_H
#define WATERFALL_GRAPH_QUICKITEM_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>

#include <QQuickPaintedItem>
#include <QPointer>
#include <QImage>
#include <QRgb>

class Ubertooth;

/* ************************************************************************** */

/*!
 * \brief Live scrolling spectrogram waterfall renderer.
 *
 * Reads the rolling magnitude matrix exposed by the Ubertooth class and paints
 * it as a viridis-colored heatmap (X = time, Y = frequency, color = magnitude).
 *
 * Call refresh() from a QML Timer to rebuild the image from the latest data.
 */
class WaterfallGraph_QuickItem: public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QObject *dataSource READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(qreal floorDb READ floorDb WRITE setFloorDb NOTIFY rangeChanged)
    Q_PROPERTY(qreal ceilDb READ ceilDb WRITE setCeilDb NOTIFY rangeChanged)
    Q_PROPERTY(bool smooth READ smooth WRITE setSmooth NOTIFY smoothChanged)

    QPointer <QObject> m_source;
    Ubertooth *m_ubertooth = nullptr;

    qreal m_floorDb = -100.0;   //!< magnitude mapped to the low end of the colormap
    qreal m_ceilDb = -20.0;     //!< magnitude mapped to the high end of the colormap
    bool m_smooth = false;      //!< bilinear scaling vs crisp pixel blocks

    QImage m_image;
    QRgb m_lut[256];

    void buildLut();

Q_SIGNALS:
    void sourceChanged();
    void rangeChanged();
    void smoothChanged();

public:
    explicit WaterfallGraph_QuickItem(QQuickItem *parent = nullptr);

    void paint(QPainter *painter) override;

    QObject *source() const { return m_source; }
    void setSource(QObject *source);

    qreal floorDb() const { return m_floorDb; }
    void setFloorDb(qreal v);

    qreal ceilDb() const { return m_ceilDb; }
    void setCeilDb(qreal v);

    bool smooth() const { return m_smooth; }
    void setSmooth(bool v);

    //! Rebuild the image from the source's latest data and request a repaint.
    Q_INVOKABLE void refresh();
};

/* ************************************************************************** */
#endif // WATERFALL_GRAPH_QUICKITEM_H
