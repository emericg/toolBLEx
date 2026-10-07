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
#include "BleDescriptorInfo.h"

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
    if (parent)
    {
        m_device = qobject_cast<DeviceToolBLEx*>(parent);
    }

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
    if (parent)
    {
        m_device = qobject_cast<DeviceToolBLEx*>(parent);
    }

    if (!m_ble_service)
    {
        m_service_cache = servicecache;

        const QJsonArray characteristicsArray = m_service_cache["characteristics"].toArray();
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

int ServiceInfo::getServiceStatus() const
{
    if (m_ble_service) return m_ble_service->state();
    return 0;
}

QString ServiceInfo::getServiceStatusStr() const
{
    if (m_ble_service)
    {
        if (m_ble_service->state() == QLowEnergyService::InvalidService) return QStringLiteral("Invalid");
        if (m_ble_service->state() == QLowEnergyService::RemoteService) return QStringLiteral("Remote");
        if (m_ble_service->state() == QLowEnergyService::RemoteServiceDiscovering) return QStringLiteral("Discovering...");
        if (m_ble_service->state() == QLowEnergyService::RemoteServiceDiscovered) return QStringLiteral("Discovered");
    }
    return QString("Cache");
}

/* ************************************************************************** */

const QLowEnergyService *ServiceInfo::getService()
{
    return m_ble_service;
}

const QList <QObject *> ServiceInfo::getCharacteristicsInfos()
{
    return m_characteristics;
}

bool ServiceInfo::containsCharacteristic(const QString &uuid)
{
    for (const auto &c: std::as_const(m_characteristics))
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
        if (cst && cst->getUuidFull() == uuid)
        {
            return true;
        }
    }

    return false;
}

void ServiceInfo::clearCharacteristicsData()
{
    for (const auto &c: std::as_const(m_characteristics))
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
        if (!cst) continue;

        // Drop the value read from the device
        cst->setValue(QByteArray());

        // Drop the transient operation status, so no badge outlives the data
        cst->setReadInProgress(false);
        cst->setWriteInProgress(false);
        cst->setNotifyInProgress(false);
        cst->setReadInError(false);
        cst->setWriteInError(false);
        cst->setNotifyInError(false);

        for (const auto &d: cst->getDescriptorsInfos())
        {
            DescriptorInfo *dsc = qobject_cast<DescriptorInfo *>(d);
            if (!dsc) continue;

            dsc->setReadInProgress(false);
            dsc->setReadInError(false);
        }
    }
}

/* ************************************************************************** */

void ServiceInfo::connectToService(QLowEnergyService::DiscoveryMode scanmode)
{
    //qDebug() << "ServiceInfo::connectToService()";

    if (!m_ble_service) return;
    Q_EMIT stateUpdated();

    if (m_ble_service->state() == QLowEnergyService::RemoteService ||
        m_ble_service->state() == QLowEnergyService::RemoteServiceDiscovering)
    {
        connect(m_ble_service, &QLowEnergyService::stateChanged, this, &ServiceInfo::serviceDetailsDiscovered);
        connect(m_ble_service, &QLowEnergyService::errorOccurred, this, &ServiceInfo::serviceErrorOccured);

        connect(m_ble_service, &QLowEnergyService::characteristicRead, this, &ServiceInfo::bleReadDone);
        connect(m_ble_service, &QLowEnergyService::characteristicWritten, this, &ServiceInfo::bleWriteDone);
        connect(m_ble_service, &QLowEnergyService::characteristicChanged, this, &ServiceInfo::bleReadNotify);

        connect(m_ble_service, &QLowEnergyService::descriptorRead, this, &ServiceInfo::bleDescReadDone);
        connect(m_ble_service, &QLowEnergyService::descriptorWritten, this, &ServiceInfo::bleDescWriteDone);

        if (m_ble_service->state() == QLowEnergyService::RemoteService)
        {
            // Windows hack, see: QTBUG-80770 and QTBUG-78488
            QTimer::singleShot(0, this, [=] () { m_ble_service->discoverDetails(scanmode); });
        }

        return;
    }

    if (m_ble_service->state() == QLowEnergyService::RemoteServiceDiscovered)
    {
        qDeleteAll(m_characteristics);
        m_characteristics.clear();

        const QList <QLowEnergyCharacteristic> chars = m_ble_service->characteristics();
        for (const QLowEnergyCharacteristic &ch: chars)
        {
            auto cInfo = new CharacteristicInfo(ch, this);
            m_characteristics.append(cInfo);
            if (m_device) m_device->decodeStandardCharacteristic(ch.uuid(), ch.value());
        }
        Q_EMIT characteristicsUpdated();
    }
}

/* ************************************************************************** */

void ServiceInfo::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{
    qDebug() << "ServiceInfo::serviceDetailsDiscovered(" << getUuidFull() << " / " << newState << ")";
/*
    QLowEnergyService::InvalidService	0	A service can become invalid when it looses the connection to the underlying device. Even though the connection may be lost it retains its last information. An invalid service cannot become valid anymore even if the connection to the device is re-established.
    QLowEnergyService::RemoteService	1	The service details are yet to be discovered by calling discoverDetails(). The only reliable pieces of information are its serviceUuid() and serviceName().
    QLowEnergyService::RemoteServiceDiscovering	2	The service details are being discovered.
    QLowEnergyService::RemoteServiceDiscovered	3	The service details have been discovered.
    QLowEnergyService::LocalService (since Qt 5.7)	4	The service is associated with a controller object in the peripheral role. Such service objects do not change their state.
    QLowEnergyService::DiscoveryRequired	RemoteService	Deprecated. Was renamed to RemoteService.
    QLowEnergyService::DiscoveringService	RemoteServiceDiscovering	Deprecated. Was renamed to RemoteServiceDiscovering.
    QLowEnergyService::ServiceDiscovered	RemoteServiceDiscovered	Deprecated. Was renamed to RemoteServiceDiscovered.
*/
    Q_EMIT stateUpdated();

    if (newState != QLowEnergyService::RemoteServiceDiscovered)
    {
        // do not hang in "Scanning for characteristics" mode forever in case the service discovery failed
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
        if (m_device) m_device->decodeStandardCharacteristic(ch.uuid(), ch.value());
    }
    Q_EMIT characteristicsUpdated();

    if (newState == QLowEnergyService::RemoteServiceDiscovered)
    {
        if (m_device) m_device->logEvent("Service details discovered for " + m_ble_service->serviceUuid().toString(), LogEvent::STATE);

        // The service details have been discovered
        m_scan_complete = true;
    }
    Q_EMIT stateUpdated();

    // Notify parent device
    if (m_device) m_device->serviceDetailsDiscovered_fromservice();
}

void ServiceInfo::serviceErrorOccured(QLowEnergyService::ServiceError error)
{
    if (error <= QLowEnergyService::NoError) return;
    qDebug() << "ServiceInfo::serviceErrorOccured(" << getUuidFull() << " / " << error << ")";

    if (m_device) m_device->logEvent("serviceErrorOccured", LogEvent::ERROR);
/*
    QLowEnergyService::NoError	0	No error has occurred.
    QLowEnergyService::OperationError	1	An operation was attempted while the service was not ready. An example might be the attempt to write to the service while it was not yet in the ServiceDiscovered state() or the service is invalid due to a loss of connection to the peripheral device.
    QLowEnergyService::CharacteristicReadError (since Qt 5.5)	5	An attempt to read a characteristic value failed. For example, it might be triggered in response to a call to readCharacteristic().
    QLowEnergyService::CharacteristicWriteError	2	An attempt to write a new value to a characteristic failed. For example, it might be triggered when attempting to write to a read-only characteristic.
    QLowEnergyService::DescriptorReadError (since Qt 5.5)	6	An attempt to read a descriptor value failed. For example, it might be triggered in response to a call to readDescriptor().
    QLowEnergyService::DescriptorWriteError	3	An attempt to write a new value to a descriptor failed. For example, it might be triggered when attempting to write to a read-only descriptor.
    QLowEnergyService::UnknownError (since Qt 5.5)	4	An unknown error occurred when interacting with the service.
*/
    if (error == QLowEnergyService::OperationError)
    {
        // ???
    }
    else if (error == QLowEnergyService::CharacteristicReadError)
    {
        for (const auto &c: std::as_const(m_characteristics))
        {
            CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
            if (cst && cst->getReadInProgress()) cst->setReadInError(true);
            if (cst && cst->getNotifyInProgress()) cst->setNotifyInError(true);
        }
    }
    else if (error == QLowEnergyService::CharacteristicWriteError)
    {
        for (const auto &c: std::as_const(m_characteristics))
        {
            CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
            if (cst && cst->getWriteInProgress()) cst->setWriteInError(true);
        }
    }
    else if (error == QLowEnergyService::DescriptorReadError)
    {
        for (const auto &c: std::as_const(m_characteristics))
        {
            CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
            if (!cst) continue;

            for (const auto &d: cst->getDescriptorsInfos())
            {
                DescriptorInfo *dsc = qobject_cast<DescriptorInfo *>(d);
                if (dsc && dsc->getReadInProgress()) dsc->setReadInError(true);
            }
        }
    }
    else if (error == QLowEnergyService::DescriptorWriteError)
    {
        // ???
    }
    else // if (error == QLowEnergyService::UnknownError)
    {
        // ???
    }
}

/* ************************************************************************** */

void ServiceInfo::askForNotify(const QString &uuid)
{
    if (m_ble_service)
    {
        qDebug() << "ServiceInfo::askForNotify(" << uuid << ")";
        if (m_device) m_device->logEvent("User asked for NOTIFY on " + uuid, LogEvent::USER);

        QBluetoothUuid toread(uuid);
        QLowEnergyCharacteristic crst = m_ble_service->characteristic(toread);
        QLowEnergyDescriptor desc = crst.clientCharacteristicConfiguration();

        QByteArray descValue = QByteArray::fromHex("0000");
        bool inProgress = false;

        if (desc.value() == QByteArray::fromHex("0000"))
        {
            descValue = QByteArray::fromHex("0100");
            inProgress = true;
        }

        m_ble_service->writeDescriptor(desc, descValue);
        for (const auto &c: std::as_const(m_characteristics))
        {
            CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
            if (cst && cst->getUuidFull() == uuid)
            {
                cst->setNotifyInProgress(inProgress);
            }
        }
    }
}

void ServiceInfo::askForRead(const QString &uuid)
{
    if (m_ble_service)
    {
        qDebug() << "ServiceInfo::askForRead(" << uuid << ")";
        if (m_device) m_device->logEvent("User asked for READ on " + uuid, LogEvent::USER);

        QBluetoothUuid toread(uuid);
        QLowEnergyCharacteristic crst = m_ble_service->characteristic(toread);
        m_ble_service->readCharacteristic(crst);

        for (const auto &c: std::as_const(m_characteristics))
        {
            CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
            if (cst && cst->getUuidFull() == uuid)
            {
                cst->setReadInProgress(true);
            }
        }
    }
}

void ServiceInfo::askForWrite(const QString &uuid, const QByteArray &data, bool withResponse)
{
    if (m_ble_service)
    {
        qDebug() << "ServiceInfo::askForWrite(" << uuid << ") > data:" << data.toHex()
                 << " (size:" << data.size() << "/ withResponse:" << withResponse << ")";

        if (m_device) m_device->logEvent("User asked for WRITE on " + uuid, LogEvent::USER);

        QBluetoothUuid towrite(uuid);
        QLowEnergyCharacteristic crst = m_ble_service->characteristic(towrite);
        const QLowEnergyCharacteristic::PropertyTypes properties = crst.properties();

        // Use the mode asked by the user, as long as the characteristic supports it,
        // otherwise fallback to whatever mode is available
        QLowEnergyService::WriteMode m = QLowEnergyService::WriteWithResponse;
        if (withResponse && (properties & QLowEnergyCharacteristic::Write))
        {
            m = QLowEnergyService::WriteWithResponse;
        }
        else if (!withResponse && (properties & QLowEnergyCharacteristic::WriteNoResponse))
        {
            m = QLowEnergyService::WriteWithoutResponse;
        }
        else if (properties & QLowEnergyCharacteristic::Write)
        {
            m = QLowEnergyService::WriteWithResponse;
        }
        else if (properties & QLowEnergyCharacteristic::WriteNoResponse)
        {
            m = QLowEnergyService::WriteWithoutResponse;
        }
        else if (properties & QLowEnergyCharacteristic::WriteSigned)
        {
            m = QLowEnergyService::WriteSigned;
        }

        if (m == QLowEnergyService::WriteWithResponse)
        {
            // Only a "with response" write gets a confirmation to wait for
            for (const auto &c: std::as_const(m_characteristics))
            {
                CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(c);
                if (cst && cst->getUuidFull() == uuid)
                {
                    cst->setWriteInProgress(true);
                }
            }
        }

        m_ble_service->writeCharacteristic(crst, data, m);

        if (m == QLowEnergyService::WriteWithoutResponse && (properties & QLowEnergyCharacteristic::Read))
        {
            // If the write is "no response" we manually trigger a read so we can get confirmation of the value
            m_ble_service->readCharacteristic(crst);
        }
    }
}

void ServiceInfo::askForDescriptorRead(DescriptorInfo *descriptor)
{
    if (m_ble_service && descriptor && descriptor->isReadable())
    {
        qDebug() << "ServiceInfo::askForDescriptorRead(" << descriptor->getUuidFull() << ")";
        if (m_device) m_device->logEvent("User asked for descriptor READ on " + descriptor->getUuidFull(), LogEvent::USER);

        descriptor->setReadInProgress(true);
        m_ble_service->readDescriptor(descriptor->getDescriptor());
    }
}

/* ************************************************************************** */

void ServiceInfo::bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleReadDone()";
    qDebug() << "- service" << getUuidFull() << " - characteristic" << c.uuid().toString();
    qDebug() << "- DATA (" << v.size() << "b)" << v.toHex();

    if (m_device) m_device->logEvent("Read done on " + c.uuid().toString() + " / " + QString::number(v.size()) + " bytes / 0x" + v.toHex(), LogEvent::DATA);
    if (m_device) m_device->decodeStandardCharacteristic(c.uuid(), v);

    for (const auto &cc: std::as_const(m_characteristics))
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(cc);
        if (cst && cst->getUuidFull() == c.uuid().toString().toUpper())
        {
            // update characteristic value
            cst->setValue(v);
            cst->setReadInProgress(false);
            cst->setWriteInProgress(false);
        }
    }
}

void ServiceInfo::bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleReadNotify()";
    qDebug() << "- service" << getUuidFull() << " - characteristic" << c.uuid().toString();
    qDebug() << "- DATA (" << v.size() << "b)" << v.toHex();

    if (m_device) m_device->logEvent("Read/Notify on " + c.uuid().toString() + " / " + QString::number(v.size()) + " bytes / 0x" + v.toHex(), LogEvent::DATA);
    if (m_device) m_device->decodeStandardCharacteristic(c.uuid(), v);

    for (const auto &cc: std::as_const(m_characteristics))
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
    qDebug() << "- DATA (" << v.size() << "b)" << v.toHex();

    if (m_device) m_device->logEvent("Write done on " + c.uuid().toString() + " / " + QString::number(v.size()) + " bytes / 0x" + v.toHex(), LogEvent::DATA);

    for (const auto &cc: std::as_const(m_characteristics))
    {
        CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(cc);
        if (cst && cst->getUuidFull() == c.uuid().toString().toUpper())
        {
            // update characteristic value
            cst->setValue(v);
        }
    }
}

void ServiceInfo::updateDescriptor(const QLowEnergyDescriptor &d, const QByteArray &v)
{
    if (!m_ble_service) return;

    // Find the characteristic owning that descriptor
    const QList <QLowEnergyCharacteristic> chars = m_ble_service->characteristics();
    for (const QLowEnergyCharacteristic &ch: chars)
    {
        if (!ch.descriptors().contains(d)) continue;

        for (const auto &cc: std::as_const(m_characteristics))
        {
            CharacteristicInfo *cst = qobject_cast<CharacteristicInfo *>(cc);
            if (cst && cst->getUuidFull() == ch.uuid().toString().toUpper())
            {
                cst->updateDescriptor(d, v);
            }
        }

        return;
    }
}

void ServiceInfo::bleDescReadDone(const QLowEnergyDescriptor &d, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleDescReadDone()";
    qDebug() << "- service" << getUuidFull() << " - descriptor" << d.uuid().toString();
    qDebug() << "- DATA (" << v.size() << "b)" << v.toHex();

    if (m_device) m_device->logEvent("Descriptor read on " + d.uuid().toString() + " / " + QString::number(v.size()) + " bytes / 0x" + v.toHex(), LogEvent::DATA);

    updateDescriptor(d, v);
}

void ServiceInfo::bleDescWriteDone(const QLowEnergyDescriptor &d, const QByteArray &v)
{
    qDebug() << "ServiceInfo::bleDescWriteDone()";
    qDebug() << "- service" << getUuidFull() << " - descriptor" << d.uuid().toString();
    qDebug() << "- DATA (" << v.size() << "b)" << v.toHex();

    if (m_device) m_device->logEvent("Descriptor write on " + d.uuid().toString() + " / " + QString::number(v.size()) + " bytes / 0x" + v.toHex(), LogEvent::DATA);

    updateDescriptor(d, v);
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
            result += QStringLiteral("Primary");
        else
            result += QStringLiteral("Secondary");

        if (m_ble_service->type() & QLowEnergyService::IncludedService)
            result += QStringLiteral(" (included)");

        return result;
    }
    else if (!m_service_cache.isEmpty())
    {
        const QJsonArray types = m_service_cache["type"].toArray();
        for (const auto &t: types)
        {
            if (!result.isEmpty()) result += QStringLiteral(" ");

            if (t.toString() == "primary") result += QStringLiteral("Primary");
            else if (t.toString() == "secondary") result += QStringLiteral("Secondary");
            else result += t.toString();
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
            tlist += QStringLiteral("Primary");
        }
        else
        {
            tlist += QStringLiteral("Secondary");
        }
        if (tflag & QLowEnergyService::IncludedService)
        {
            tlist += QStringLiteral("(included)");
        }
    }
    else if (!m_service_cache.isEmpty())
    {
        const QJsonArray types = m_service_cache["type"].toArray();
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
    if (success) return QStringLiteral("0x") + QString::number(result16, 16).toUpper().rightJustified(4, '0');

    quint32 result32 = uuid.toUInt32(&success);
    if (success) return QStringLiteral("0x") + QString::number(result32, 16).toUpper().rightJustified(8, '0');

    return uuid.toString().toUpper().remove(QLatin1Char('{')).remove(QLatin1Char('}'));
}


/* ************************************************************************** */
