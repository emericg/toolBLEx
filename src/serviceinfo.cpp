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

#include "serviceinfo.h"
#include "characteristicinfo.h"

#include <QBluetoothServiceInfo>
#include <QLowEnergyCharacteristic>

#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

ServiceInfo::ServiceInfo(QLowEnergyService *service):
    m_service(service)
{
    m_service->setParent(this);

    connectToService();
}

ServiceInfo::~ServiceInfo()
{
    qDeleteAll(m_characteristics);
    m_characteristics.clear();
}

/* ************************************************************************** */

const QLowEnergyService *ServiceInfo::service() const
{
    return m_service;
}

const QList <QObject *> ServiceInfo::characteristics() const
{
    return m_characteristics;
}

QString ServiceInfo::getName() const
{
    if (!m_service) return QString();

    return m_service->serviceName();
}

QString ServiceInfo::getType() const
{
    if (!m_service) return QString();

    QString result;
    if (m_service->type() & QLowEnergyService::PrimaryService)
        result += QStringLiteral("primary");
    else
        result += QStringLiteral("secondary");

    if (m_service->type() & QLowEnergyService::IncludedService)
        result += QStringLiteral(" included");

    result.prepend('<').append('>');

    return result;
}

QString ServiceInfo::getUuid() const
{
    if (!m_service) return QString();

    const QBluetoothUuid uuid = m_service->serviceUuid();
    bool success = false;

    quint16 result16 = uuid.toUInt16(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = uuid.toUInt32(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return uuid.toString().toUpper().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}

QString ServiceInfo::getUuidFull() const
{
    if (!m_service) return QString();
    return m_service->serviceUuid().toString().toUpper();
}

/* ************************************************************************** */

void ServiceInfo::connectToService()
{
    QLowEnergyService *service = m_service;

    qDeleteAll(m_characteristics);
    m_characteristics.clear();

    if (service->state() == QLowEnergyService::RemoteService)
    {
        connect(service, &QLowEnergyService::stateChanged, this, &ServiceInfo::serviceDetailsDiscovered);
        QTimer::singleShot(0, [=] () { service->discoverDetails(); });

        return;
    }

    // discovery already done
    const QList<QLowEnergyCharacteristic> chars = service->characteristics();
    for (const QLowEnergyCharacteristic &ch : chars)
    {
        auto cInfo = new CharacteristicInfo(ch);
        m_characteristics.append(cInfo);
    }

    QTimer::singleShot(0, this, &ServiceInfo::characteristicsUpdated);
}

void ServiceInfo::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    //qDebug() << "ServiceInfo::serviceDetailsDiscovered()";

    if (newState != QLowEnergyService::RemoteServiceDiscovered)
    {
/*
        // QT6 // do not hang in "Scanning for characteristics" mode forever
        // in case the service discovery failed
        // We have to queue the signal up to give UI time to even enter the above mode
        if (newState != QLowEnergyService::DiscoveringServices)
        {
            QMetaObject::invokeMethod(this, "characteristicsUpdated", Qt::QueuedConnection);
        }
*/
        return;
    }

    auto service = qobject_cast<QLowEnergyService *>(sender());
    if (!service)
        return;

    const QList<QLowEnergyCharacteristic> chars = service->characteristics();
    for (const QLowEnergyCharacteristic &ch : chars)
    {
        auto cInfo = new CharacteristicInfo(ch);
        m_characteristics.append(cInfo);
    }

    Q_EMIT characteristicsUpdated();
}

/* ************************************************************************** */
