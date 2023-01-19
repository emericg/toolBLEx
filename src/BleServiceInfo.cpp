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

#include "BleServiceInfo.h"
#include "BleCharacteristicInfo.h"

#include "device_toolblex.h"

#include <QBluetoothServiceInfo>
#include <QLowEnergyCharacteristic>
#include <QJsonArray>

#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

ServiceInfo::ServiceInfo(QLowEnergyService *service,
                         QLowEnergyService::DiscoveryMode scanmode,
                         QObject *parent) : QObject(parent)
{
    if (service)
    {
        // Make sure we won't use the cache
        m_service_cache.empty();
        qDeleteAll(m_characteristics);
        m_characteristics.clear();

        // Set and connect to the BLE service
        m_ble_service = service;
        m_ble_service->setParent(this);
        connectToService(scanmode);
    }
}

ServiceInfo::ServiceInfo(const QJsonObject &servicecache,
                         QObject *parent) : QObject(parent)
{
    if (!m_ble_service)
    {
        m_service_cache = servicecache;

        QJsonArray characteristicsArray = m_service_cache["characteristics"].toArray();
        for (const auto &car: characteristicsArray)
        {
            QJsonObject obj = car.toObject();
            qDebug() << "+ CHARACTERISTIC >" << obj["name"].toString() << obj["uuid"].toString();

            auto cInfo = new CharacteristicInfo(obj, this);
            m_characteristics.append(cInfo);
        }
    }
}

ServiceInfo::~ServiceInfo()
{
    qDeleteAll(m_characteristics);
    m_characteristics.clear();
}

/* ************************************************************************** */

QLowEnergyService *ServiceInfo::getService()
{
    return m_ble_service;
}

QList <QObject *> ServiceInfo::getCharacteristicsInfos()
{
    return m_characteristics;
}

bool ServiceInfo::containsCharacteristic(const QString &uuid)
{
    for (auto c: m_characteristics)
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
        if (cst && cst->getUuidFull() == uuid)
        {
            return true;
        }
    }

    return false;
}

/* ************************************************************************** */

void ServiceInfo::connectToService(QLowEnergyService::DiscoveryMode scanmode)
{
    //qDebug() << "ServiceInfo::connectToService()";

    if (!m_ble_service) return;

    qDeleteAll(m_characteristics);
    m_characteristics.clear();

    if (m_ble_service->state() == QLowEnergyService::RemoteService)
    {
        connect(m_ble_service, &QLowEnergyService::stateChanged, this, &ServiceInfo::serviceDetailsDiscovered);
        connect(m_ble_service, &QLowEnergyService::characteristicRead, this, &ServiceInfo::bleReadDone);
        connect(m_ble_service, &QLowEnergyService::characteristicWritten, this, &ServiceInfo::bleWriteDone);
        connect(m_ble_service, &QLowEnergyService::characteristicChanged, this, &ServiceInfo::bleReadNotify);

        QTimer::singleShot(0, [=] () { m_ble_service->discoverDetails(scanmode); });
        return;
    }

    // discovery already done
    const QList <QLowEnergyCharacteristic> chars = m_ble_service->characteristics();
    for (const QLowEnergyCharacteristic &ch: chars)
    {
        auto cInfo = new CharacteristicInfo(ch, this);
        m_characteristics.append(cInfo);
    }

    QTimer::singleShot(0, this, &ServiceInfo::characteristicsUpdated);
}

/* ************************************************************************** */

void ServiceInfo::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    qDebug() << "ServiceInfo::serviceDetailsDiscovered(" << getUuidFull() << ")";

    if (newState != QLowEnergyService::RemoteServiceDiscovered)
    {
        // do not hang in "Scanning for characteristics" mode forever
        // in case the service discovery failed
        // We have to queue the signal up to give UI time to even enter the above mode
        if (newState != QLowEnergyService::RemoteServiceDiscovering)
        {
            QMetaObject::invokeMethod(this, "characteristicsUpdated", Qt::QueuedConnection);
        }
        return;
    }

    auto service = qobject_cast<QLowEnergyService *>(sender());
    if (!service) return;

    const QList <QLowEnergyCharacteristic> chars = service->characteristics();
    for (const QLowEnergyCharacteristic &ch: chars)
    {
        auto cInfo = new CharacteristicInfo(ch, this);
        m_characteristics.append(cInfo);
    }

    Q_EMIT characteristicsUpdated();
}

/* ************************************************************************** */

void ServiceInfo::askForNotify(const QString &uuid)
{
    if (m_ble_service)
    {
        qDebug() << "ServiceInfo::askForNotify(" << uuid << ")";

        QBluetoothUuid toread(uuid);
        QLowEnergyCharacteristic crst = m_ble_service->characteristic(toread);
        QLowEnergyDescriptor desc = crst.clientCharacteristicConfiguration();
        m_ble_service->writeDescriptor(desc, QByteArray::fromHex("0100"));
    }
}

void ServiceInfo::askForRead(const QString &uuid)
{
    if (m_ble_service)
    {
        qDebug() << "ServiceInfo::askForRead(" << uuid << ")";

        QBluetoothUuid toread(uuid);
        QLowEnergyCharacteristic crst = m_ble_service->characteristic(toread);
        m_ble_service->readCharacteristic(crst);
    }
}

void ServiceInfo::askForWrite(const QString &uuid, const QString &value, const QString &type)
{
    if (m_ble_service)
    {
        qDebug() << "ServiceInfo::askForWrite(" << uuid << ") > value:" << value;

        QBluetoothUuid towrite(uuid);
        QLowEnergyCharacteristic crst = m_ble_service->characteristic(towrite);

        QByteArray qba = DeviceToolBLEx::askForData_qba(value, type);
        m_ble_service->writeCharacteristic(crst, qba);
    }
}

/* ************************************************************************** */

void ServiceInfo::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleReadDone()";
    qDebug() << "- service" << getUuidFull() << " - characteristic" << c.uuid().toString();
    qDebug() << "- DATA: 0x" << v.toHex();

    for (auto cc: m_characteristics)
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(cc);
        if (cst && cst->getUuidFull() == c.uuid().toString().toUpper())
        {
            // update characteristic value
            cst->setValue(v);
        }
    }
}

void ServiceInfo::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleReadNotify()";
    qDebug() << "- service" << getUuidFull() << " - characteristic" << c.uuid().toString();
    qDebug() << "- DATA: 0x" << v.toHex();

    for (auto cc: m_characteristics)
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(cc);
        if (cst && cst->getUuidFull() == c.uuid().toString().toUpper())
        {
            // update characteristic value
            cst->setValue(v);
        }
    }
}

void ServiceInfo::bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleWriteDone()";
    qDebug() << "- service" << getUuidFull() << " - characteristic" << c.uuid().toString();
    qDebug() << "- DATA: 0x" << v.toHex();

    for (auto cc: m_characteristics)
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(cc);
        if (cst && cst->getUuidFull() == c.uuid().toString().toUpper())
        {
            // update characteristic value
            cst->setValue(v);
        }
    }
}

/* ************************************************************************** */

QString ServiceInfo::getName() const
{
    if (m_ble_service)
    {
        return m_ble_service->serviceName();
    }
    else if (!m_service_cache.isEmpty())
    {
        return m_service_cache["name"].toString();
    }

    return QString();
}

QString ServiceInfo::getType() const
{
    QString result;

    if (m_ble_service)
    {
        if (m_ble_service->type() & QLowEnergyService::PrimaryService)
            result += QStringLiteral("primary");
        else
            result += QStringLiteral("secondary");

        if (m_ble_service->type() & QLowEnergyService::IncludedService)
            result += QStringLiteral(" included");

        result.prepend('<').append('>');
        return result;
    }
    else if (!m_service_cache.isEmpty())
    {
        QJsonArray types = m_service_cache["type"].toArray();
        for (const auto &t: types)
        {
            if (!result.isEmpty()) result += QStringLiteral(" ");
            result += t.toString();
        }
    }

    return result;
}

QStringList ServiceInfo::getTypeList() const
{
    QStringList tlist;

    if (m_ble_service)
    {
        uint tflag = m_ble_service->type();

        if (tflag & QLowEnergyService::PrimaryService)
        {
            tlist += QStringLiteral("primary");
        }
        else
        {
            tlist += QStringLiteral("primary");
        }
        if (tflag & QLowEnergyService::IncludedService)
        {
            tlist += QStringLiteral("included");
        }
    }
    else if (!m_service_cache.isEmpty())
    {
        QJsonArray types = m_service_cache["type"].toArray();
        for (const auto &t: types)
        {
            tlist += t.toString();
        }
    }

    return tlist;
}

QString ServiceInfo::getUuidFull() const
{
    if (m_ble_service)
    {
        return m_ble_service->serviceUuid().toString().toUpper();
    }
    else if (!m_service_cache.isEmpty())
    {
        return m_service_cache["uuid"].toString();
    }

    return QString();
}

QString ServiceInfo::getUuidShort() const
{
    QBluetoothUuid uuid;

    if (m_ble_service)
    {
        uuid = m_ble_service->serviceUuid();
    }
    else if (!m_service_cache.isEmpty())
    {
        uuid = QBluetoothUuid(m_service_cache["uuid"].toString());
    }

    bool success = false;

    quint16 result16 = uuid.toUInt16(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = uuid.toUInt32(&success);
    if (success)
        return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return uuid.toString().toUpper().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}


/* ************************************************************************** */
