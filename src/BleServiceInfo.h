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

#ifndef BLE_SERVICE_INFO_H
#define BLE_SERVICE_INFO_H
/* ****************************************************************************/

#include <QObject>
#include <QString>
#include <QStringList>

#include <QLowEnergyService>
#include <QJsonObject>

class DeviceToolBLEx;

/* ****************************************************************************/

class ServiceInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool scanComplete READ getScanComplete NOTIFY stateUpdated)
    Q_PROPERTY(int serviceStatus READ getServiceStatus NOTIFY stateUpdated)
    Q_PROPERTY(QString serviceStatusStr READ getServiceStatusStr NOTIFY stateUpdated)

    Q_PROPERTY(QString serviceName READ getName NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceUuid READ getUuidFull NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceUuidFull READ getUuidFull NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceUuidShort READ getUuidShort NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceType READ getType NOTIFY serviceUpdated)
    Q_PROPERTY(QStringList serviceTypeList READ getTypeList NOTIFY serviceUpdated)

    Q_PROPERTY(QVariant characteristicList READ getCharacteristics NOTIFY characteristicsUpdated)
    Q_PROPERTY(int characteristicsCount READ getCharacteristicsCount NOTIFY characteristicsUpdated)

    DeviceToolBLEx *m_device = nullptr; // parent device

    QLowEnergyService *m_ble_service = nullptr; // current service
    void connectToService(QLowEnergyService::DiscoveryMode scanMode);

    QList <QObject *> m_characteristics; // included characteristics
    QVariant getCharacteristics() { return QVariant::fromValue(m_characteristics); }

    bool m_scan_complete = false; // persists around disconnection

    QJsonObject m_service_cache;

Q_SIGNALS:
    void stateUpdated();
    void serviceUpdated();
    void characteristicsUpdated();

private slots:
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);
    void serviceErrorOccured(QLowEnergyService::ServiceError error);

    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void bleDescReadDone(const QLowEnergyDescriptor &d, const QByteArray &value);
    void bleDescWriteDone(const QLowEnergyDescriptor &d, const QByteArray &value);

public:
    ServiceInfo() = default;
    ServiceInfo(QLowEnergyService *service, QLowEnergyService::DiscoveryMode scanMode, QObject *parent);
    ServiceInfo(const QJsonObject &servicecache, QObject *parent);
    ~ServiceInfo();

    bool getScanComplete() const { return m_scan_complete; }
    int getServiceStatus() const;
    QString getServiceStatusStr() const;

    QLowEnergyService *getService();
    QList <QObject *> getCharacteristicsInfos();
    bool containsCharacteristic(const QString &uuid);
    int getCharacteristicsCount() const { return m_characteristics.count(); }

    QString getName() const;
    QString getUuidFull() const;
    QString getUuidShort() const;
    QString getType() const;
    QStringList getTypeList() const;

    void askForNotify(const QString &uuid);
    void askForRead(const QString &uuid);
    void askForWrite(const QString &uuid, const QString &value, const QString &type);
};

/* ****************************************************************************/
#endif // BLE_SERVICE_INFO_H
