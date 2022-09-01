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

#ifndef VENDORS_DATABASE_H
#define VENDORS_DATABASE_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QVariant>

#include <QList>
#include <QHash>
#include <QMap>

/* ************************************************************************** */

class VendorEntry: public QObject
{
    Q_OBJECT

public:
    VendorEntry(const QStringList &section)
    {
        m_prefix = section.at(0);
        m_vendor = section.at(1);

        for (int i = 2; i < section.size(); i++)
        {
            m_vendor +=section.at(i);
        }
    }
    ~VendorEntry() = default;

    QString m_prefix;
    QString m_vendor;
};

/* ************************************************************************** */

class VendorsDatabase: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int vendorCount READ getVendorCount CONSTANT)
    Q_PROPERTY(int servicecUUIDsCount READ getServiceUUIDsCount CONSTANT)
    Q_PROPERTY(int manufacturerIDsCount READ getManufacturerIDsCount CONSTANT)

    bool loadDb();
    bool m_isLoaded = false;

    QList <QObject *> m_vendors;
    int getVendorCount() { return m_vendors.size(); }

    QHash <QString, QString> m_service_uuids;
    int getServiceUUIDsCount() { return m_service_uuids.size(); }

    QHash <QString, QString> m_manufacturer_ids;
    int getManufacturerIDsCount() { return m_manufacturer_ids.size(); }

    // Singleton
    static VendorsDatabase *instance;
    VendorsDatabase();
    ~VendorsDatabase();

public:
    static VendorsDatabase *getInstance();

    void getVendor(const QString &device_mac, QString &device_vendor) const;

    void getVendor_serviceUUID(const QString &service_uuid, QString &device_vendor) const;

    void getVendor_manufacturerID(const QString &manufacturer_id, QString &device_vendor) const;
};

/* ************************************************************************** */
#endif // VENDORS_DATABASE_H
