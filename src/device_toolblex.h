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

#ifndef DEVICE_TOOLBLEX_H
#define DEVICE_TOOLBLEX_H
/* ************************************************************************** */

#include "device.h"
#include "device_toolblex_adv.h"

#include <QObject>
#include <QList>
#include <QDateTime>
#include <QByteArray>

#include <QBluetoothDeviceInfo>
#include <QBluetoothLocalDevice>
#include <QLowEnergyController>

/* ************************************************************************** */

/*!
 * \brief The DeviceToolBLEx class
 */
class DeviceToolBLEx: public Device
{
    Q_OBJECT

    Q_PROPERTY(QString deviceName_display READ getName_display NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddr_display READ getAddr_display NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceName_export READ getName_export NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddr_export READ getAddr_export NOTIFY sensorUpdated)

    Q_PROPERTY(bool isBeacon READ isBeacon NOTIFY boolChanged)
    Q_PROPERTY(bool isBlacklisted READ isBlacklisted NOTIFY boolChanged)
    Q_PROPERTY(bool isCached READ isCached NOTIFY boolChanged)
    Q_PROPERTY(bool isBLE READ isBluetoothLowEnergy NOTIFY boolChanged)
    Q_PROPERTY(bool isLowEnergy READ isBluetoothLowEnergy NOTIFY boolChanged)
    Q_PROPERTY(bool isClassic READ isBluetoothClassic NOTIFY boolChanged)

    Q_PROPERTY(bool isPaired READ isPaired NOTIFY pairingChanged)
    Q_PROPERTY(int pairingStatus READ getPairingStatus NOTIFY pairingChanged)

    Q_PROPERTY(bool isStarred READ isStarred WRITE setUserStar NOTIFY starChanged)
    Q_PROPERTY(QString color READ getDeviceColor CONSTANT)

    Q_PROPERTY(bool userStar READ getUserStar WRITE setUserStar NOTIFY starChanged)
    Q_PROPERTY(QString userColor READ getUserColor WRITE setUserColor NOTIFY colorChanged)
    Q_PROPERTY(QString userComment READ getUserComment WRITE setUserComment NOTIFY commentChanged)

    Q_PROPERTY(QDateTime firstSeen READ getFirstSeen CONSTANT)
    Q_PROPERTY(QDateTime lastSeen READ getLastSeen NOTIFY seenChanged)
    Q_PROPERTY(bool lastSeenToday READ isLastSeenToday NOTIFY seenChanged)

    // RSSI
    Q_PROPERTY(int rssiMin READ getRssiMin NOTIFY rssiUpdated)
    Q_PROPERTY(int rssiMax READ getRssiMax NOTIFY rssiUpdated)
    Q_PROPERTY(QVariant rssiHistory READ getRssiHistory NOTIFY rssiUpdated)
    Q_PROPERTY(int advInterval READ getAdvertisementInterval NOTIFY rssiUpdated)

    // Advertisement
    Q_PROPERTY(QStringList servicesAdvertised READ getAdvertisedServices NOTIFY servicesAdvertisedChanged)
    Q_PROPERTY(int servicesAdvertisedCount READ getAdvertisedServicesCount NOTIFY servicesAdvertisedChanged)

    Q_PROPERTY(bool hasAdvertisement READ hasAdvertisement NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant adv READ getAdvertisementData NOTIFY advertisementFilteredChanged)
    Q_PROPERTY(int advCount READ getAdvertisementDataCount NOTIFY advertisementFilteredChanged)

    Q_PROPERTY(QVariant svd READ getServiceData NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant svd_uuid READ getServiceUuid NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant mfd READ getManufacturerData NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant mfd_uuid READ getManufacturerUuid NOTIFY advertisementChanged)

    Q_PROPERTY(QVariant last_svd READ getLastServiceData NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant last_mfd READ getLastManufacturerData NOTIFY advertisementChanged)

    // Services
    Q_PROPERTY(bool hasServices READ hasServices NOTIFY servicesChanged)
    Q_PROPERTY(bool hasServiceCache READ hasServiceCache NOTIFY servicesChanged)
    Q_PROPERTY(bool servicesCached READ getServicesCached NOTIFY servicesChanged)
    Q_PROPERTY(bool servicesScanned READ getServicesScanned NOTIFY servicesChanged)

    Q_PROPERTY(int servicesScanMode READ getServicesScanMode NOTIFY servicesChanged)
    Q_PROPERTY(int servicesCount READ getServicesCount NOTIFY servicesChanged)
    Q_PROPERTY(QVariant servicesList READ getServices NOTIFY servicesChanged)

    // Characteristics count
    Q_PROPERTY(int characteristicsCount READ getCharacteristicsCount NOTIFY characteristicsChanged)

    // Logs
    Q_PROPERTY(int deviceLogCount READ getDeviceLogCount NOTIFY logUpdated)
    Q_PROPERTY(QVariant deviceLog READ getDeviceLog NOTIFY logUpdated)
    Q_PROPERTY(QString deviceLogStr READ getDeviceLogStr NOTIFY logUpdated)

    static const int s_min_entries_advertisement = 60;
    static const int s_max_entries_advertisement = 60;
    static const int s_max_entries_packets = 20;

    bool m_isBeacon = false;
    bool m_isCached = false;
    bool m_isBlacklisted = false;

    bool m_isClassic = false;
    bool m_isBLE = false;
    int m_pairingStatus = 0;

    bool m_userStarred = false;
    QString m_userComment;
    QString m_userColor;
    QString m_color;

    QDateTime m_firstSeen;
    QDateTime m_lastSeen;

    // adv

    bool m_hasAdvertisement = false;
    int m_advertisementInterval = 0;

    QList <AdvertisementEntry *> m_advertisementEntries;

    QStringList m_advertised_services;

    QList <AdvertisementData *> m_advertisementData;
    QList <AdvertisementData *> m_advertisementData_filtered;

    QList <AdvertisementData *> m_svd;
    QList <AdvertisementUUID *> m_svd_uuid;
    QList <AdvertisementData *> m_mfd;
    QList <AdvertisementUUID *> m_mfd_uuid;

    // srv

    /*!
     * \FIXME this is only for the services, not their characteristics
     *
     * - 0: not scanned
     * - 1: cache
     * - 2: incomplete scan
     * - 3: incomplete scan (with values)
     * - 4: scanned
     * - 5: scanned (with values)
     */
    int m_services_scanmode = 0;

    bool m_hasServiceCache = false;

    QList <QObject *> m_services;

    // func

    QVariant getLastServiceData() const { if (m_svd.empty()) return QVariant(); return QVariant::fromValue(m_svd.first()); }
    QVariant getLastManufacturerData() const { if (m_mfd.empty()) return QVariant(); return QVariant::fromValue(m_mfd.first()); }

    QVariant getAdvertisementData() const { return QVariant::fromValue(m_advertisementData_filtered); }
    int getAdvertisementDataCount() const { return m_advertisementData_filtered.count(); }

    QVariant getServiceData() const { return QVariant::fromValue(m_svd); }
    int getServiceDataCount() const { return m_svd.count(); }

    QVariant getServiceUuid() const { return QVariant::fromValue(m_svd_uuid); }
    int getServiceUuidCount() const { return m_svd_uuid.count(); }

    QVariant getManufacturerData() const { return QVariant::fromValue(m_mfd); }
    int getManufacturerDataCount() const { return m_mfd.count(); }

    QVariant getManufacturerUuid() const { return QVariant::fromValue(m_mfd_uuid); }
    int getManufacturerUuidCount() const { return m_mfd_uuid.count(); }

    void updateCache();

    // log
    QList <QObject *> m_deviceLog;
    QString m_deviceLogString;

private slots:
    // QLowEnergyController related
    void deviceConnected();
    void deviceDisconnected();
    void deviceErrored(QLowEnergyController::Error error);
    void deviceStateChanged(QLowEnergyController::ControllerState newState);

    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);
    void serviceScanDone();

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &v);
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &v);
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &v);

Q_SIGNALS:
    void advertisementChanged();
    void advertisementFilteredChanged();
    void servicesAdvertisedChanged();
    void servicesChanged();
    void characteristicsChanged();

    void pairingChanged();
    void boolChanged();
    void starChanged();
    void commentChanged();
    void colorChanged();
    void seenChanged();
    void logUpdated();

public:
    DeviceToolBLEx(const QString &deviceAddr, const QString &deviceName,
                   QObject *parent = nullptr);
    DeviceToolBLEx(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceToolBLEx();

    virtual bool getSqlDeviceInfos();
    virtual void setDeviceClass(const int major, const int minor, const int service);
    virtual void setCoreConfiguration(const int bleconf);

    // toolBLEx
    QString getName_display() const;
    QString getAddr_display() const;
    QString getName_export() const;
    QString getAddr_export() const;

    QVariant getServices() const { return QVariant::fromValue(m_services); }
    int getServicesCount() const { return m_services.count(); }
    int getServicesScanMode() const { return m_services_scanmode; }
    bool getServicesCached() const { return (m_services_scanmode == 1); }
    bool getServicesScanned() const { return (m_services_scanmode > 1); }

    int getCharacteristicsCount() const;

    int getAdvertisedServicesCount() const { return m_advertised_services.count(); }
    QStringList getAdvertisedServices() const { return m_advertised_services; };
    void setAdvertisedServices(const QList <QBluetoothUuid> &services);

    bool parseAdvertisementToolBLEx(uint16_t mode,
                                    uint16_t id, const QBluetoothUuid &uuid,
                                    const QByteArray &data);

    bool isAvailable() const { return (m_rssi < 0); }
    QVariant getRssiHistory() const { return QVariant::fromValue(m_advertisementEntries); }
    const QList <AdvertisementEntry *> &getRssiHistory2() const { return m_advertisementEntries; }

    void addAdvertisementEntry(const int rssi, const bool hasMFD = false, const bool hasSVD = false);
    void cleanAdvertisementEntries();

    int getAdvertisementInterval() const { return m_advertisementInterval; }

    void setStarred(bool v);
    void setBeacon(bool v);
    void setBlacklisted(bool v);
    void setCached(bool v);

    bool isPaired() const { return m_pairingStatus; }
    int getPairingStatus() const { return m_pairingStatus; }
    void setPairingStatus(QBluetoothLocalDevice::Pairing p);

    QString getDeviceColor() const { return m_color; }
    void setDeviceColor(const QString &color);

    bool getUserStar() const { return m_userStarred; }
    void setUserStar(bool star);

    QString getUserComment() const { return m_userComment; }
    void setUserComment(const QString &comment);

    QString getUserColor() const { if (!m_userColor.isEmpty()) return m_userColor; return m_color; }
    void setUserColor(const QString &color);

    QDateTime getFirstSeen() const { return m_firstSeen; }
    QDateTime getLastSeen() const { return m_lastSeen; }
    void setLastSeen(const QDateTime &dt);
    bool isLastSeenToday();

    bool hasAdvertisement() const { return m_hasAdvertisement; }
    bool hasServices() const { return !m_services.isEmpty(); }
    bool hasServiceCache() const { return m_hasServiceCache; }

    bool isStarred() const { return m_userStarred; }
    bool isBeacon() const { return m_isBeacon; }
    bool isBlacklisted() const { return m_isBlacklisted; }
    bool isCached() const { return m_isCached; }
    bool isBluetoothClassic() const { return m_isClassic; }
    bool isBluetoothLowEnergy() const { return m_isBLE; }

    Q_INVOKABLE void blacklist(bool blacklist);
    Q_INVOKABLE void cache(bool cache);

    Q_INVOKABLE void mfdFilterUpdate();
    Q_INVOKABLE void svdFilterUpdate();
    Q_INVOKABLE void advertisementFilterUpdate();

    Q_INVOKABLE void actionScanWithValues();
    Q_INVOKABLE void actionScanWithoutValues();

    Q_INVOKABLE void askForNotify(const QString &uuid);
    Q_INVOKABLE void askForRead(const QString &uuid);
    Q_INVOKABLE void askForWrite(const QString &uuid, const QString &value, const QString &type);

    Q_INVOKABLE static QByteArray askForData_qba(const QString &value, const QString &type);
    Q_INVOKABLE static QStringList askForData_strlst(const QString &value, const QString &type);

    Q_INVOKABLE bool checkServiceCache();
    Q_INVOKABLE bool saveServiceCache();
    Q_INVOKABLE void restoreServiceCache();

    bool getExportFile(QString &filename, bool log) const;

    const QVariant getDeviceLog() const { return QVariant::fromValue(m_deviceLog); }
    const QString &getDeviceLogStr() const { return m_deviceLogString; }
    int getDeviceLogCount() const { return m_deviceLog.size(); }
    void logEvent(const QString &logline, const int event = 0);

    Q_INVOKABLE bool saveLog(const QString &filename);
    Q_INVOKABLE void clearLog();

    Q_INVOKABLE bool exportDeviceInfo(const QString &filename,
                                      bool withGenericInfo = true, bool withAdvertisements = true,
                                      bool withServices = true, bool withValues = true);
};

/* ************************************************************************** */
#endif // DEVICE_TOOLBLEX_H
