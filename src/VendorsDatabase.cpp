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

#include "VendorsDatabase.h"

#include <QObject>
#include <QFile>
#include <QStringList>

/* ************************************************************************** */

VendorsDatabase *VendorsDatabase::instance = nullptr;

VendorsDatabase *VendorsDatabase::getInstance()
{
    if (instance == nullptr)
    {
        instance = new VendorsDatabase();
    }

    return instance;
}

VendorsDatabase::VendorsDatabase()
{
    loadDb();
}

VendorsDatabase::~VendorsDatabase()
{
    qDeleteAll(m_vendors);
    m_vendors.clear();
}

/* ************************************************************************** */

bool VendorsDatabase::loadDb()
{
    bool status = true;

    if (!m_isLoaded)
    {
        //qDebug() << "VendorDatabase::loadDb()";

        ////////

        QFile vendorsDB(":/vendors/mac-vendors.csv");
        if (vendorsDB.open(QFile::ReadOnly | QFile::Text))
        {
            QTextStream vendors(&vendorsDB);
            vendors.readLine(); // ignore first line, its the legend

            while (!vendors.atEnd())
            {
                QString line = vendors.readLine();
                if (!line.isEmpty())
                {
                    QStringList sections = line.split(';');
                    //qDebug() << "> readDB_csv() sections:" << sections.count() << sections;

                    if (sections.size() > 1)
                    {
                        // ends with:
                        // GmbH
                        // GmbH & Co. KG
                        // Co. Ltd
                        // Ltd
                        // LLC
                        // SAS
                        // , Inc
                        // Inc.
                        // Inc
                        // ASA

                        VendorEntry *mmm = new VendorEntry(sections);
                        if (mmm) m_vendors.push_back(mmm);
                    }
                }
            }

            m_isLoaded = true;
        }
        else
        {
            qWarning() << "VendorDatabase::readDB_csv() file do not exists";
        }

        ////////

        QFile manufacturerIdDB(":/vendors/ble-manufacturer-ids.csv");
        if (manufacturerIdDB.open(QFile::ReadOnly))
        {
            QTextStream vendors(&manufacturerIdDB);
            vendors.readLine(); // ignore first line, its the legend

            while (!vendors.atEnd())
            {
                QString line = vendors.readLine();
                if (!line.isEmpty())
                {
                    QStringList sections = line.split(';');
                    //qDebug() << "> readDB_csv() sections:" << sections.count() << sections;

                    if (sections.size() == 3)
                    {
                        m_manufacturer_ids.insert(QString(sections.at(1)).remove(0, 2), sections.at(2));
                    }
                    else
                    {
                        qWarning() << "ERROR";
                    }
                }
            }

            m_isLoaded = true;
        }
        else
        {
            qWarning() << "VendorDatabase::readDB_csv() file do not exists";
        }

        ////////

        QFile serviceUuidDB(":/vendors/ble-service-uuids.csv");
        if (serviceUuidDB.open(QFile::ReadOnly | QFile::Text))
        {
            QTextStream vendors(&serviceUuidDB);
            vendors.readLine(); // ignore first line, its the legend

            while (!vendors.atEnd())
            {
                QString line = vendors.readLine();
                if (!line.isEmpty())
                {
                    QStringList sections = line.split(';');
                    //qDebug() << "> readDB_csv() sections:" << sections.count() << sections;

                    if (sections.size() == 2)
                    {
                        //qDebug() << "> readDB_csv() sections:" << QString(sections.at(0)).remove(2, 2) << sections.at(1);
                        m_service_uuids.insert(QString(sections.at(0)).remove(0, 2), sections.at(1));
                    }
                    else
                    {
                        qWarning() << "ERROR";
                    }
                }
            }

            m_isLoaded = true;
        }
        else
        {
            qWarning() << "VendorDatabase::readDB_csv() file do not exists";
        }
    }

    return status;
}

/* ************************************************************************** */

void VendorsDatabase::getVendor(const QString &device_mac, QString &device_vendor) const
{
    for (auto v: std::as_const(m_vendors))
    {
        VendorEntry *mac = qobject_cast<VendorEntry *>(v);

        if (device_mac.startsWith(mac->m_prefix))
        {
            //qDebug() << "VendorDatabase::getVendor(" << vendor << ")";
            device_vendor = mac->m_vendor;
            return;
        }
    }
}

/* ************************************************************************** */

void VendorsDatabase::getVendor_serviceUUID(const QString &service_uuid, QString &device_vendor) const
{
    QHashIterator<QString, QString> i(m_service_uuids);
    while (i.hasNext())
    {
        i.next();

        if (i.key().compare(service_uuid, Qt::CaseInsensitive) == 0)
        {
            //qDebug() << "FOUND" << i.key() << i.value();
            device_vendor = i.value();
            return;
        }
    }
}

/* ************************************************************************** */

void VendorsDatabase::getVendor_manufacturerID(const QString &manufacturer_id, QString &device_vendor) const
{
    QHashIterator<QString, QString> i(m_manufacturer_ids);
    while (i.hasNext())
    {
        i.next();

        if (i.key().compare(manufacturer_id, Qt::CaseInsensitive) == 0)
        {
            //qDebug() << "FOUND" << i.key() << i.value();
            device_vendor = i.value();
            return;
        }
    }
}

/* ************************************************************************** */
