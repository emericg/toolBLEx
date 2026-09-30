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

#ifndef DEVICE_TOOLBLEX_ADV_H
#define DEVICE_TOOLBLEX_ADV_H
/* ************************************************************************** */

#include <QObject>
#include <QList>
#include <QDateTime>
#include <QByteArray>
#include <QBluetoothUuid>

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
    AdvertisementEntry(const QDateTime &ts, int r, bool m, bool s,
                       QObject *parent) : QObject(parent) {
        m_timestamp = ts;
        m_rssi = r;
        m_hasMFD = m;
        m_hasSVD = s;
    }
    ~AdvertisementEntry() = default;

    const QDateTime &getTimestamp() const { return m_timestamp; }
    const int getRssi() const { return m_rssi; }
    const bool hasMFD() const { return m_hasMFD; }
    const bool hasSVD() const { return m_hasSVD; }
};

/* ************************************************************************** */

class AdvertisementUUID: public QObject
{
    Q_OBJECT

    Q_PROPERTY(uint16_t mode READ getAdvMode CONSTANT)
    Q_PROPERTY(QString uuid READ getUuidStr CONSTANT)
    Q_PROPERTY(bool uuidShort READ isUuidShort CONSTANT)
    Q_PROPERTY(bool selected READ getSelected WRITE setSelected NOTIFY selectedChanged)

    uint16_t m_mode;
    QString m_uuid;
    bool m_selected = true;

Q_SIGNALS:
    void selectedChanged();

public:
    AdvertisementUUID(const uint16_t mode, const QString &uuid, const bool selected,
                      QObject *parent = nullptr): QObject(parent) {
        m_mode = mode;
        m_uuid = uuid;
        m_selected = selected;
    }
    ~AdvertisementUUID() = default;

    uint16_t getAdvMode() const { return m_mode; }
    const QString &getUuidStr() const { return m_uuid; }
    bool isUuidShort() const { return (m_uuid.size() <= 8); }

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
    Q_PROPERTY(bool advUUIDshort READ isUUID_short CONSTANT)
    Q_PROPERTY(QString advUUIDmanuf READ getUUID_vendor CONSTANT)

    Q_PROPERTY(int advDataSize READ getDataSize CONSTANT)
    Q_PROPERTY(QVariant advData READ getData CONSTANT)

    Q_PROPERTY(QString advDataHex READ getDataHex CONSTANT)
    Q_PROPERTY(QString advDataAscii READ getDataAscii CONSTANT)
    Q_PROPERTY(QStringList advDataHex_list READ getDataHex_list CONSTANT)
    Q_PROPERTY(QStringList advDataAscii_list READ getDataAscii_list CONSTANT)

    QDateTime m_timestamp;
    int advMode;
    int advUUID;
    QBluetoothUuid advServiceUUID;
    QString advUUIDstr;
    QString advUUIDvendor;
    QByteArray advData;

public:
    /*!
     * \param adv_mode: BLE_ADV_MANUFACTURERDATA or BLE_ADV_SERVICEDATA.
     * \param adv_id: company ID (manufacturer data), or 16-bit service UUID (service data, 0 if none).
     * \param adv_uuid: full service UUID (service data only).
     */
    AdvertisementData(const uint16_t adv_mode, const uint16_t adv_id, const QBluetoothUuid &adv_uuid,
                      const QByteArray &data, const QDateTime &timestamp,
                      QObject *parent);
    ~AdvertisementData() = default;

    /*!
     * \brief Identifier string of a manufacturer or service data, unique within its mode.
     * \return Company ID or 16/32-bit service UUID as uppercase hex (without "0x"),
     *         or full 128-bit service UUID (uppercase, without braces).
     */
    static QString uuidToString(const uint16_t adv_mode, const uint16_t adv_id,
                                const QBluetoothUuid &adv_uuid);

    bool compare(const QByteArray &data) { return (advData.compare(data) == 0); }

    const QDateTime &getTimestamp() const { return m_timestamp; }

    int getMode() const { return advMode; }

    const QString &getUUID_str() const { return advUUIDstr; }
    bool isUUID_short() const { return (advUUIDstr.size() <= 8); }
    const QString &getUUID_vendor() const { return advUUIDvendor; }
    int getUUID_int() const { return advUUID; }
    uint16_t getUUID_uint() const { return advUUID; }
    const QBluetoothUuid &getServiceUUID() const { return advServiceUUID; }

    const QVariant getData() const { return QVariant::fromValue(advData); }
    int getDataSize() const { return advData.size(); }

    const QByteArray &getDataBA() const { return advData; }

    const QString getDataHex() const { return QString::fromStdString(advData.toHex().toStdString()); }
    const QString getDataAscii() const { return QString::fromStdString(advData.toStdString()); }

    const QStringList getDataHex_list() const {
        QStringList out;
        for (int i = 0; i < advData.size(); i++) {
            QByteArray duo; duo += advData.at(i);
            out += duo.toHex();
        }
        return out;
    }
    const QStringList getDataAscii_list() const {
        QStringList out;
        for (int i = 0; i < advData.size(); i++) {
            QByteArray duo; duo += advData.at(i);
            out += QString::fromStdString(duo.toStdString());
        }
        return out;
    }
};

/* ************************************************************************** */
#endif // DEVICE_TOOLBLEX_ADV_H
