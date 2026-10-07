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
#include "DeviceAdvModel.h"
#include "DeviceLogModel.h"

#include <QObject>
#include <QList>
#include <QDateTime>
#include <QByteArray>
#include <QJsonObject>

#include <QBluetoothDeviceInfo>
#include <QBluetoothLocalDevice>
#include <QLowEnergyController>

#include <QtGraphs/QXYSeries>

/* ************************************************************************** */

/*!
 * \brief The DeviceToolBLEx class
 */
class DeviceToolBLEx: public Device
{
    Q_OBJECT

    Q_PROPERTY(QString deviceName_display READ getName_display NOTIFY deviceUpdated)
    Q_PROPERTY(QString deviceAddr_display READ getAddr_display NOTIFY deviceUpdated)
    Q_PROPERTY(QString deviceName_export READ getName_export NOTIFY deviceUpdated)
    Q_PROPERTY(QString deviceAddr_export READ getAddr_export NOTIFY deviceUpdated)

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

    // Advertisement
    Q_PROPERTY(bool hasAdvertisement READ hasAdvertisement NOTIFY advertisementChanged)

    Q_PROPERTY(int advInterval READ getAdvertisementInterval NOTIFY rssiUpdated)

    Q_PROPERTY(QStringList servicesAdvertised READ getAdvertisedServices NOTIFY servicesAdvertisedChanged)
    Q_PROPERTY(int servicesAdvertisedCount READ getAdvertisedServicesCount NOTIFY servicesAdvertisedChanged)

    Q_PROPERTY(int advCount READ getAdvertisementDataCount NOTIFY advertisementChanged)
    Q_PROPERTY(AdvertisementFilterModel *advModel READ getAdvertisementFilterModel CONSTANT)
    Q_PROPERTY(AdvertisementDataModel *advDataModel READ getAdvertisementDataModel CONSTANT)

    Q_PROPERTY(QVariant svd_uuid READ getServiceUuid NOTIFY advertisementUuidChanged)
    Q_PROPERTY(QVariant mfd_uuid READ getManufacturerUuid NOTIFY advertisementUuidChanged)

    // Services
    Q_PROPERTY(bool hasServices READ hasServices NOTIFY servicesChanged)
    Q_PROPERTY(bool hasServiceCache READ hasServiceCache NOTIFY servicesChanged)
    Q_PROPERTY(bool servicesCached READ getServicesCached NOTIFY servicesChanged)
    Q_PROPERTY(bool servicesScanned READ getServicesScanned NOTIFY servicesChanged)
    Q_PROPERTY(bool servicesReady READ areServicesReady NOTIFY servicesChanged)

    Q_PROPERTY(int servicesScanMode READ getServicesScanMode NOTIFY servicesChanged)
    Q_PROPERTY(int servicesCount READ getServicesCount NOTIFY servicesChanged)
    Q_PROPERTY(QVariant servicesList READ getServices NOTIFY servicesChanged)

    // Characteristics count
    Q_PROPERTY(int characteristicsCount READ getCharacteristicsCount NOTIFY characteristicsChanged)

    // Logs
    Q_PROPERTY(int deviceLogCount READ getDeviceLogCount NOTIFY logUpdated)
    Q_PROPERTY(DeviceLogModel *deviceLogModel READ getDeviceLog_model CONSTANT)
    Q_PROPERTY(QString deviceLogString READ getDeviceLog_string CONSTANT)

    static const int s_max_entries_advertisement = 1024;
    static const int s_max_age_advertisement_ms = 120000;
    static const int s_max_entries_packets = 60;
    static const int s_max_entries_logs = 1024;

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

    QStringList m_advertised_services;

    QList <AdvertisementEntry *> m_advertisementEntries;

    AdvertisementDataModel *m_advertisementDataModel = nullptr;
    AdvertisementFilterModel *m_advertisementFilterModel = nullptr;

    QList <AdvertisementUUID *> m_svd_uuid;
    QList <AdvertisementUUID *> m_mfd_uuid;

    // srv

    int m_services_scanmode = 0; // See ServiceScanMode

    bool m_areServiceReady = false;

    bool m_hasServiceCache = false;

    QList <QObject *> m_services;

    // func

    int getAdvertisementDataCount() const { return m_advertisementDataModel->getAdvertisementCount(); }

    AdvertisementFilterModel *getAdvertisementFilterModel() const { return m_advertisementFilterModel; }
    AdvertisementDataModel *getAdvertisementDataModel() const { return m_advertisementDataModel; }

    QVariant getServiceUuid() const { return QVariant::fromValue(m_svd_uuid); }
    int getServiceUuidCount() const { return m_svd_uuid.count(); }

    QVariant getManufacturerUuid() const { return QVariant::fromValue(m_mfd_uuid); }
    int getManufacturerUuidCount() const { return m_mfd_uuid.count(); }

    void updateCache();

    // log

    DeviceLogModel *m_deviceLog_obj;
    QString m_deviceLog_str;

private slots:
    // QLowEnergyController related
    void deviceConnected() override;
    void deviceDisconnected() override;
    void deviceErrored(QLowEnergyController::Error error) override;
    void deviceStateChanged(QLowEnergyController::ControllerState newState) override;

    void addLowEnergyService(const QBluetoothUuid &uuid) override;
    void serviceScanDone() override;
    void serviceDiscoveryDone() override;

    void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &v) override;
    void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &v) override;
    void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &v) override;

Q_SIGNALS:
    void advertisementChanged();
    void advertisementUuidChanged();
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
    void logLineAppended(const QString &line);

public:
    DeviceToolBLEx(const QString &deviceAddr, const QString &deviceName, QObject *parent = nullptr);
    DeviceToolBLEx(const QBluetoothDeviceInfo &d, QObject *parent = nullptr);
    ~DeviceToolBLEx();

    bool getSqlDeviceInfos() override;
    void setDeviceClass(const int major, const int minor, const int service) override;
    void setCoreConfiguration(const int bleconf) override;

    /// toolBLEx

    bool isAvailable() const { return (m_rssi < 0); }

    QString getName_display() const;
    QString getAddr_display() const;
    QString getName_export() const;
    QString getAddr_export() const;

    enum ServiceScanMode {
        srv_unscanned           = 0, //!< not scanned
        srv_cached              = 1, //!< cache
        srv_cached_values       = 2, //!< cache (with values)
        srv_scanning            = 3, //!< scanning
        srv_scanning_values     = 4, //!< scanning (with values)
        srv_incomplete          = 5, //!< incomplete scan
        srv_incomplete_values   = 6, //!< incomplete scan (with values)
        srv_scanned             = 7, //!< scanned
        srv_scanned_values      = 8, //!< scanned (with values)
    };
    Q_ENUM(ServiceScanMode)

    QVariant getServices() const { return QVariant::fromValue(m_services); }
    int getServicesCount() const { return m_services.count(); }
    int getServicesScanMode() const { return m_services_scanmode; }
    bool getServicesCached() const { return (m_services_scanmode == srv_cached || m_services_scanmode == srv_cached_values); }
    bool getServicesScanning() const { return (m_services_scanmode == srv_scanning || m_services_scanmode == srv_scanning_values); }
    bool getServicesScanned() const { return (m_services_scanmode == srv_scanned || m_services_scanmode == srv_scanned_values); }
    bool areServicesReady() const { return m_areServiceReady; }

    void serviceDetailsDiscovered_fromservice();

    int getCharacteristicsCount() const;

    /*!
     * \brief Apply a standard GATT characteristic value to the matching device property.
     * \param uuid: characteristic UUID.
     * \param value: raw characteristic value.
     *
     * So far we handle:
     * - Battery Level (0x2A19)
     * - Model Number String (0x2A24)
     * - Firmware Revision String (0x2A26)
     *
     * Other characteristics are ignored.
     */
    void decodeStandardCharacteristic(const QBluetoothUuid &uuid, const QByteArray &value);

    int getAdvertisedServicesCount() const { return m_advertised_services.count(); }
    QStringList getAdvertisedServices() const { return m_advertised_services; };
    void setAdvertisedServices(const QList <QBluetoothUuid> &services);

    /*!
     * \brief Parse the manufacturer and service data of an advertisement, and set the beacon flag.
     * \param hasMfd: set to true if new manufacturer data was found.
     * \param hasSvd: set to true if new service data was found.
     */
    void parseAdvertisement(const QBluetoothDeviceInfo &info, const QDateTime &timestamp,
                            bool &hasMfd, bool &hasSvd);

    bool parseAdvertisementToolBLEx(uint16_t mode,
                                    uint16_t id, const QBluetoothUuid &uuid,
                                    const QByteArray &data,
                                    const QDateTime &timestamp);

    /*!
     * \brief Get the most recent advertisement entries, for the RSSI bar strip.
     * \return Up to s_max_entries_packets entries, oldest first.
     */
    QVariant getRssiHistory() const {
        return QVariant::fromValue(m_advertisementEntries.last(qMin<qsizetype>(s_max_entries_packets,
                                                                                m_advertisementEntries.size())));
    }
    const QList <AdvertisementEntry *> &getRssiHistory2() const { return m_advertisementEntries; }

    void addAdvertisementEntry(const QDateTime &timestamp, const int rssi,
                               const bool hasMFD = false, const bool hasSVD = false);
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

    Q_INVOKABLE void actionScanWithValues() override;
    Q_INVOKABLE void actionScanWithoutValues();

    Q_INVOKABLE void askForNotify(const QString &uuid);
    Q_INVOKABLE void askForRead(const QString &uuid);

    /*!
     * \brief Write a characteristic value.
     * \param uuid: the characteristic UUID (full, uppercase, with braces).
     * \param data: the value, already encoded (see encodeWriteValue()).
     * \param withResponse: the write mode to use, if the characteristic supports it.
     */
    Q_INVOKABLE void askForWrite(const QString &uuid, const QByteArray &data, bool withResponse = true);

    /*!
     * \brief Read a descriptor value again.
     * \param descriptor: a DescriptorInfo, from one of this device characteristics.
     */
    Q_INVOKABLE void askForDescriptorRead(QObject *descriptor);

    /*!
     * \brief Encode a value typed by the user, using a GATT format.
     * \param value: the value, as typed (hexadecimal for FORMAT_STRUCT).
     * \param format: one of the GATT format types (see BleFormat::FormatType).
     * \param bigEndian: byte order of the fixed size formats, GATT values are little endian.
     * \param exponent: presentation format exponent, integer formats only.
     *                  The value is then the actual value, ex: "21.5" with -2 is encoded as 2150.
     * \return a map with "bytes" (QByteArray, empty if it cannot be encoded),
     *         "hex" (QStringList, one string per byte), "error" (BleFormat::WriteError),
     *         and "errorString" (empty for WRITE_OK). An empty value gives no bytes and no error.
     *
     * Values that need rounding are still encoded, but reported as WRITE_PRECISION_LOST.
     */
    Q_INVOKABLE static QVariantMap encodeWriteValue(const QString &value, int format,
                                                    bool bigEndian = false, int exponent = 0);

    Q_INVOKABLE bool checkServiceCache();

    /*!
     * \brief Save the services structure cache of this device.
     * \param withValues: also save the characteristic values.
     */
    Q_INVOKABLE bool saveServiceCache(bool withValues = false);

    /*!
     * \brief Restore the services structure cache of this device.
     *
     * Reads caches with or without characteristic values, and legacy caches.
     */
    Q_INVOKABLE void restoreServiceCache();

    /*!
     * \brief Serialize this device to the device profile format (see DeviceProfile).
     * \param withGenericInfo: "device_info" section (manufacturer, comment, seen dates).
     * \param withAdvertisements: "advertising" section (latest packet of each UUID).
     * \param withServices: "services" section.
     * \param withValues: characteristic values, in the "services" section.
     * \param comment: capture comment.
     */
    QJsonObject getProfileJson(bool withGenericInfo, bool withAdvertisements,
                               bool withServices, bool withValues,
                               const QString &comment = QString()) const;

    /*!
     * \brief Check or generate an export file path.
     * \param filename: the path to check, a default path is generated if empty.
     * \param suffix: suffix of the generated path, ex: ".txt".
     * \return false if the export directory cannot be created.
     */
    bool getExportFile(QString &filename, const QString &suffix) const;

    int getDeviceLogCount() const { return m_deviceLog_obj->rowCount(); }
    DeviceLogModel *getDeviceLog_model() const { return m_deviceLog_obj; }
    const QString &getDeviceLog_string() const { return m_deviceLog_str; }

    void logEvent(const QString &logline, const int event = 0,
                  const QDateTime timestamp = QDateTime::currentDateTime());
    void logEvent2(const QDateTime &timestamp, const int event, const QString &logline);

    Q_INVOKABLE void clearAdvertisement();

    /*!
     * \brief Fill the advertisement timeline series, one point per received packet.
     * \param none: Series for packets without manufacturer or service data.
     * \param mfd: Series for packets with manufacturer data only.
     * \param svd: Series for packets with service data only.
     * \param both: Series for packets with both manufacturer and service data.
     * \param refTimeMs: Reference time (ms since epoch) used as x = 0.
     * \param windowMs: Visible time window (ms) before refTimeMs.
     *
     * Points are placed at their age relative to refTimeMs, in (negative) seconds, with RSSI as y.
     * Packets older than the window, or without a valid RSSI, are skipped.
     */
    Q_INVOKABLE void getAdvTimelineData(QXYSeries *none, QXYSeries *mfd,
                                        QXYSeries *svd, QXYSeries *both,
                                        qint64 refTimeMs, qint64 windowMs) const;

    Q_INVOKABLE void clearDeviceServices();

    Q_INVOKABLE void clearDeviceServicesData();

    Q_INVOKABLE void clearDeviceLog();

    Q_INVOKABLE bool exportDeviceLog(const QString &filename);

    Q_INVOKABLE bool exportDeviceInfo(const QString &filename,
                                      bool withGenericInfo = true, bool withAdvertisements = true,
                                      bool withServices = true, bool withValues = true,
                                      const QString &comment = QString());

    /*!
     * \brief Export this device as a JSON device profile (.toolblex.json).
     *
     * Same sections as exportDeviceInfo(), the file can be loaded by the simulator.
     */
    Q_INVOKABLE bool exportDeviceProfile(const QString &filename,
                                         bool withGenericInfo = true, bool withAdvertisements = true,
                                         bool withServices = true, bool withValues = true,
                                         const QString &comment = QString());
};

/* ************************************************************************** */
#endif // DEVICE_TOOLBLEX_H
