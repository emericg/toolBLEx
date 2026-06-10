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

#ifndef SPECTRUM_GRAPH_3D_SURFACEHANDLER_H
#define SPECTRUM_GRAPH_3D_SURFACEHANDLER_H
/* ************************************************************************** */

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QPointer>
#include <QSurface3DSeries>

class SpectrumSource;

/* ************************************************************************** */

/*!
 * \brief Fills a Qt Graphs Surface3D series from the Ubertooth data.
 *
 * Bridges the rolling sweep stack exposed by the Ubertooth class to a
 * QSurface3DSeries data proxy (X = frequency MHz, Y = magnitude, Z = time).
 */
class SpectrumGraph3D_SurfaceHandler: public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QObject *dataSource READ source WRITE setSource NOTIFY sourceChanged)

    Q_PROPERTY(int maxDepth READ maxDepth WRITE setMaxDepth NOTIFY maxDepthChanged)
    Q_PROPERTY(int maxFreqBins READ maxFreqBins WRITE setMaxFreqBins NOTIFY maxFreqBinsChanged)
    Q_PROPERTY(qreal floorDb READ floorDb WRITE setFloorDb NOTIFY floorDbChanged)
    Q_PROPERTY(int timeSmoothing READ timeSmoothing WRITE setTimeSmoothing NOTIFY smoothingChanged)
    Q_PROPERTY(int freqSmoothing READ freqSmoothing WRITE setFreqSmoothing NOTIFY smoothingChanged)

    QPointer <QObject> m_source;
    SpectrumSource *m_ubertooth = nullptr;

    qreal m_floorDb = -100.0;   //!< value used for holes / hard floor (match axisY.min)
    int m_maxDepth = 256;       //!< only plot the most-recent N sweeps along Z (0 = all)
    int m_maxFreqBins = 300;    //!< cap frequency points along X; >this is max-pooled down (0 = all)
    int m_timeSmoothing = 0;    //!< box-blur radius along time (sweeps), 0 = off
    int m_freqSmoothing = 0;    //!< box-blur radius along frequency (bins), 0 = off

Q_SIGNALS:
    void sourceChanged();
    void maxDepthChanged();
    void maxFreqBinsChanged();
    void floorDbChanged();
    void smoothingChanged();

public:
    explicit SpectrumGraph3D_SurfaceHandler(QObject *parent = nullptr);

    QObject *source() const { return m_source; }
    void setSource(QObject *source);

    int maxDepth() const { return m_maxDepth; }
    void setMaxDepth(int v);

    int maxFreqBins() const { return m_maxFreqBins; }
    void setMaxFreqBins(int v);

    qreal floorDb() const { return m_floorDb; }
    void setFloorDb(qreal v);

    int timeSmoothing() const { return m_timeSmoothing; }
    void setTimeSmoothing(int v);

    int freqSmoothing() const { return m_freqSmoothing; }
    void setFreqSmoothing(int v);

    //! Rebuild the given QSurface3DSeries surface mesh from the source's latest data.
    Q_INVOKABLE void refresh(QSurface3DSeries *series);
};

/* ************************************************************************** */
#endif // SPECTRUM_GRAPH_3D_SURFACEHANDLER_H
