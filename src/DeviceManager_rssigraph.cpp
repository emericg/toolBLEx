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

#include "DeviceManager.h"
#include "device_toolblex.h"

#include <QList>
#include <QDateTime>
#include <QRandomGenerator>
#include <QDebug>

#include <algorithm>

/* ************************************************************************** */

QString DeviceManager::getAvailableColor()
{
    QString clr_str;

    if (m_colorsLeft.size())
    {
        // unique colors
        int clr_id = QRandomGenerator::global()->bounded(m_colorsLeft.size());
        clr_str = m_colorsLeft.at(clr_id);
        m_colorsLeft.remove(clr_id);
    }
    else
    {
        // start reusing colors
        clr_str = m_colorsAvailable.at(QRandomGenerator::global()->bounded(m_colorsAvailable.size()));
    }

    return clr_str;
}

/* ************************************************************************** */

void DeviceManager::setRssiGraphFilter()
{
    if (m_filterRssiGraph != true)
    {
        m_filterRssiGraph = true;
        Q_EMIT filterRssiGraphChanged();
    }
}

/* ************************************************************************** */

void DeviceManager::clearRssiGraphFilter()
{
    if (m_filterRssiGraph != false)
    {
        // per device flag cleanups
        for (auto d: std::as_const(m_devices_model->m_devices))
        {
            DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(d);
            dd->setShownInGraph(false);
        }

        m_filterRssiGraph = false;
        Q_EMIT filterRssiGraphChanged();
    }
}

/* ************************************************************************** */

QList <QObject *> DeviceManager::getRssiGraphDevices(qint64 refTimeMs, qint64 windowMs) const
{
    QList <QObject *> devices;
    const qint64 oldestMs = refTimeMs - windowMs;

    for (int row = 0; row < m_devices_filter->rowCount(); row++)
    {
        const QModelIndex srcIndex = m_devices_filter->mapToSource(m_devices_filter->index(row, 0));
        DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(m_devices_model->device(srcIndex));
        if (!dd) continue;
        if (m_filterRssiGraph && !dd->getShownInGraph()) continue;

        const QList <AdvertisementEntry *> &l = dd->getRssiHistory2();
        if (l.isEmpty() || l.last()->getTimestamp().toMSecsSinceEpoch() < oldestMs) continue;

        devices.append(dd);
    }

    return devices;
}

void DeviceManager::getRssiGraphData(QLineSeries *serie, Device *device, qint64 refTimeMs, qint64 windowMs)
{
    if (!serie) return;
    //qDebug() << "DeviceManager::getRssiGraphData()" << serie << device;

    QList <QPointF> points;

    DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(device);
    if (dd)
    {
        serie->setColor(dd->getUserColor());

        const QList <AdvertisementEntry *> &l = dd->getRssiHistory2();
        const qint64 oldestMs = refTimeMs - windowMs;

        auto first = std::lower_bound(l.cbegin(), l.cend(), oldestMs,
                                      [](const AdvertisementEntry *a, qint64 ms) {
                                          return a->getTimestamp().toMSecsSinceEpoch() < ms;
                                      });
        if (first != l.cbegin()) --first;

        points.reserve(std::distance(first, l.cend()));
        for (auto it = first; it != l.cend(); ++it)
        {
            const AdvertisementEntry *a = *it;
            points.append(QPointF((a->getTimestamp().toMSecsSinceEpoch() - refTimeMs) / 1000.0, a->getRssi()));
        }
    }

    serie->replace(points);
}

/* ************************************************************************** */
