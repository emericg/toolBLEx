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

void DeviceManager::getRssiGraphData(QLineSeries *serie, int index)
{
    if (!serie) return;
    if (m_devices_model->m_devices.size() < index) return;
    //qDebug() << "DeviceManager::getRssiGraphData()" << serie << index;

    serie->clear();

    DeviceToolBLEx *dd = qobject_cast<DeviceToolBLEx *>(m_devices_model->m_devices.at(index));
    if (dd)
    {
        serie->setColor(dd->getUserColor());

        const QList <AdvertisementEntry *> & l = dd->getRssiHistory2();
        for (auto a: l)
        {
            serie->append(a->getTimestamp().toMSecsSinceEpoch(), a->getRssi());
            //qDebug() << "point:" << a->getTimestamp().toMSecsSinceEpoch() << a->getRssi();
        }
    }
}

void DeviceManager::getRssiGraphAxis(QDateTimeAxis *axis)
{
    if (!axis) return;
    //qDebug() << "DeviceManager::getRssiGraphAxis()";

    axis->setFormat("mm ss");
    axis->setMin(QDateTime::currentDateTime().addSecs(-60));
    axis->setMax(QDateTime::currentDateTime());
}

/* ************************************************************************** */
