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

void DeviceManager::getRssiGraphData(QLineSeries *serie, int index,
                                     qint64 refTimeMs, qint64 windowMs)
{
    if (!serie) return;
    if (index < 0 || index >= m_devices_model->m_devices.size()) return;
    //qDebug() << "DeviceManager::getRssiGraphData()" << serie << index;

    QList <QPointF> points;

    DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(m_devices_model->m_devices.at(index));
    if (dd)
    {
        serie->setColor(dd->getUserColor());

        const QList <AdvertisementEntry *> & l = dd->getRssiHistory2();
        const qint64 oldestMs = refTimeMs - windowMs;

        qsizetype first = 0;
        while (first < l.size() && l.at(first)->getTimestamp().toMSecsSinceEpoch() < oldestMs) first++;
        if (first > 0) first--;

        points.reserve(l.size() - first);
        for (qsizetype i = first; i < l.size(); i++)
        {
            const AdvertisementEntry *a = l.at(i);
            points.append(QPointF((a->getTimestamp().toMSecsSinceEpoch() - refTimeMs) / 1000.0,
                                  a->getRssi()));
        }
    }

    serie->replace(points);
}

/* ************************************************************************** */
