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

#include <QObject>
#include <QList>
#include <QDateTime>
#include <QByteArray>

#include <QBluetoothDeviceInfo>
#include <QBluetoothLocalDevice>
#include <QLowEnergyController>

/* ************************************************************************** */

class AdvertisementEntry: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDateTime timestamp READ getTimestamp CONSTANT)
    Q_PROPERTY(int rssi READ getRssi CONSTANT)
    Q_PROPERTY(bool hasMFD READ hasMFD CONSTANT)
    Q_PROPERTY(bool hasSVD READ hasSVD CONSTANT)

    QDateTime m_timestamp;

    int m_rssi = 0;
    bool m_hasMFD = false;
    bool m_hasSVD = false;

public:
    AdvertisementEntry(int r, bool m, bool s, QObject *parent) : QObject(parent) {
        m_timestamp = QDateTime::currentDateTime();
        m_rssi = r;
        m_hasMFD = m;
        m_hasSVD = s;
    }
    ~AdvertisementEntry() = default;

    QDateTime getTimestamp() const { return m_timestamp; }
    int getRssi() const { return m_rssi; }
    bool hasMFD() const { return m_hasMFD; }
    bool hasSVD() const { return m_hasSVD; }
};

/* ************************************************************************** */

class AdvertisementUUID: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString uuid READ getUuidStr CONSTANT)
    Q_PROPERTY(bool selected READ getSelected WRITE setSelected NOTIFY selectedChanged)

    uint16_t m_uuid;
    bool m_selected = true;

Q_SIGNALS:
    void selectedChanged();

public:
    AdvertisementUUID(const uint16_t uuid, const bool selected,
              QObject *parent = nullptr): QObject(parent) {
        m_uuid = uuid;
        m_selected = selected;
    }
    ~AdvertisementUUID() = default;

    uint16_t getUuid() const { return m_uuid; }
    QString getUuidStr() const { return QString::number(m_uuid, 16).rightJustified(4, '0'); }
    bool getSelected() const { return m_selected; }
    void setSelected(bool s) { if (m_selected != s) { m_selected = s; Q_EMIT selectedChanged(); } }
};

/* ************************************************************************** */

class AdvertisementData: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QDateTime timestamp READ getTimestamp CONSTANT)
    Q_PROPERTY(int advMode READ getMode CONSTANT)
    Q_PROPERTY(int advUUID READ getUUID_int CONSTANT)
    Q_PROPERTY(QString advUUIDstr READ getUUID_str CONSTANT)
    Q_PROPERTY(QString advUUIDmanuf READ getUUID_vendor CONSTANT)

    Q_PROPERTY(int advDataSize READ getDataSize CONSTANT)
    Q_PROPERTY(QVariant advData READ getData CONSTANT)
    Q_PROPERTY(QString advDataString READ getDataString CONSTANT)

    QDateTime m_timestamp;
    int advMode;
    int advUUID;
    QString advUUIDstr;
    QString advUUIDvendor;
    QByteArray advData;

public:
    AdvertisementData(const uint16_t adv_mode, const uint16_t adv_id,
                      const QByteArray &data, QObject *parent);
    ~AdvertisementData() = default;

    bool compare(const QByteArray &data) { return (advData.compare(data) != 0); }

    QDateTime getTimestamp() const { return m_timestamp; }

    int getMode() const { return advMode; }

    QString getUUID_str() const { return advUUIDstr; }
    QString getUUID_vendor() const { return advUUIDvendor; }
    int getUUID_int() const { return advUUID; }
    uint16_t getUUID_uint() const { return advUUID; }

    QVariant getData() const { return QVariant::fromValue(advData); }
    int getDataSize() const { return advData.size(); }
    QString getDataString() const { return QString::fromStdString(advData.toHex().toStdString()); }
};

/* ************************************************************************** */

/*!
 * \brief The DeviceToolBLEx class
 */
class DeviceToolBLEx: public Device
{
    Q_OBJECT

    Q_PROPERTY(bool isBeacon READ isBeacon NOTIFY boolChanged)
    Q_PROPERTY(bool isBlacklisted READ isBlacklisted NOTIFY boolChanged)
    Q_PROPERTY(bool isCached READ isCached NOTIFY boolChanged)
    Q_PROPERTY(bool isBLE READ isBluetoothLowEnergy NOTIFY boolChanged)
    Q_PROPERTY(bool isLowEnergy READ isBluetoothLowEnergy NOTIFY boolChanged)
    Q_PROPERTY(bool isClassic READ isBluetoothClassic NOTIFY boolChanged)

    Q_PROPERTY(bool isPaired READ isPaired NOTIFY pairingChanged)
    Q_PROPERTY(int pairingStatus READ getPairingStatus NOTIFY pairingChanged)

    Q_PROPERTY(bool hasCache READ hasCache NOTIFY cacheChanged)
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
    Q_PROPERTY(bool hasAdvertisement READ hasAdvertisement NOTIFY advertisementChanged)

    Q_PROPERTY(QStringList servicesAdvertised READ getAdvertisedServices NOTIFY servicesAdvertisedChanged)
    Q_PROPERTY(int servicesAdvertisedCount READ getAdvertisedServicesCount NOTIFY servicesAdvertisedChanged)

    Q_PROPERTY(QVariant adv READ getAdvertisementData NOTIFY advertisementFilteredChanged)
    Q_PROPERTY(int advCount READ getAdvertisementDataCount NOTIFY advertisementFilteredChanged)

    Q_PROPERTY(QVariant svd READ getServiceData NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant svd_uuid READ getServiceUuid NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant mfd READ getManufacturerData NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant mfd_uuid READ getManufacturerUuid NOTIFY advertisementChanged)

    Q_PROPERTY(QVariant last_svd READ getLastServiceData NOTIFY advertisementChanged)
    Q_PROPERTY(QVariant last_mfd READ getLastManufacturerData NOTIFY advertisementChanged)

    // Services
    Q_PROPERTY(bool servicesScanned READ getServicesScanned NOTIFY servicesChanged)
    Q_PROPERTY(int servicesCount READ getServicesCount NOTIFY servicesChanged)
    Q_PROPERTY(QVariant servicesList READ getServices NOTIFY servicesChanged)

    static const int s_min_entries_advertisement = 60;
    static const int s_max_entries_advertisement = 180;
    static const int s_max_entries_packets = 24;

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

    bool m_hasCache = false;
    bool m_hasAdvertisement = false;
    int m_advertisementInterval = 0;

    QStringList m_advertised_services;

    QList <AdvertisementEntry *> m_advertisementEntries;

    QList <AdvertisementData *> m_advertisementData;
    QList <AdvertisementData *> m_advertisementData_filtered;

    QList <AdvertisementData *> m_svd;
    QList <AdvertisementUUID *> m_svd_uuid;
    QList <AdvertisementData *> m_mfd;
    QList <AdvertisementUUID *> m_mfd_uuid;

    bool m_services_scanned = false;
    QList <QObject *> m_services;

    QVariant getLastServiceData() const { if (m_svd.empty()) return QVariant(); return QVariant::fromValue(m_svd.last()); }
    QVariant getLastManufacturerData() const { if (m_mfd.empty()) return QVariant(); return QVariant::fromValue(m_mfd.last()); }

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

private:
    // QLowEnergyController related
    void deviceConnected();
    void addLowEnergyService(const QBluetoothUuid &uuid);
    void serviceScanDone();

Q_SIGNALS:
    void advertisementChanged();
    void advertisementFilteredChanged();
    void servicesAdvertisedChanged();
    void servicesChanged();
    void pairingChanged();
    void boolChanged();
    void cacheChanged();
    void starChanged();
    void commentChanged();
    void colorChanged();
    void seenChanged();

public:
    DeviceToolBLEx(const QString &deviceAddr, const QString &deviceName,
                   QObject *parent = nullptr);
    DeviceToolBLEx(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceToolBLEx();

    virtual bool getSqlDeviceInfos();
    virtual void setDeviceClass(const int major, const int minor, const int service);
    virtual void setCoreConfiguration(const int bleconf);

    // toolBLEx
    QVariant getServices() const { return QVariant::fromValue(m_services); }
    int getServicesCount() const { return m_services.count(); }
    bool getServicesScanned() const { return m_services_scanned; }

    int getAdvertisedServicesCount() const { return m_advertised_services.count(); }
    QStringList getAdvertisedServices() const { return m_advertised_services; };
    void setAdvertisedServices(const QList<QBluetoothUuid> &services);

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
    void setCache(bool v);

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
    bool hasCache() const { return m_hasCache; }
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

    Q_INVOKABLE bool exportDeviceInfo(bool withAdvertisements = true, bool withServices = true, bool withValues = true);
};

/* ************************************************************************** */
#endif // DEVICE_TOOLBLEX_H
