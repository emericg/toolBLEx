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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DatabaseManager.h"
#include "SettingsManager.h"

#include <QDir>
#include <QFile>
#include <QString>
#include <QDateTime>
#include <QStandardPaths>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

/* ************************************************************************** */

DatabaseManager *DatabaseManager::instance = nullptr;

DatabaseManager *DatabaseManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new DatabaseManager();
    }

    return instance;
}

DatabaseManager::DatabaseManager()
{
    bool status = false;

    if (!status)
    {
        status = openDatabase_mysql();
    }
    if (!status)
    {
        status = openDatabase_sqlite();
    }
}

DatabaseManager::~DatabaseManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::openDatabase_sqlite()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE"))
    {
        m_dbInternalAvailable = true;

        if (m_dbInternalOpen)
        {
            closeDatabase();
        }

        QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

        if (dbPath.isEmpty() == false)
        {
            QDir dbDirectory(dbPath);
            if (dbDirectory.exists() == false)
            {
                if (dbDirectory.mkpath(dbPath) == false)
                    qWarning() << "Cannot create dbDirectory...";
            }

            if (dbDirectory.exists())
            {
                dbPath += "/data.db";

                QSqlDatabase dbFile(QSqlDatabase::addDatabase("QSQLITE"));
                dbFile.setDatabaseName(dbPath);

                if (dbFile.isOpen())
                {
                    m_dbInternalOpen = true;
                }
                else
                {
                    if (dbFile.open())
                    {
                        m_dbInternalOpen = true;

                        // Migrations //////////////////////////////////////////

                        // Must be done before the creation, so we migrate old data tables
                        // instead of creating new empty tables

                        migrateDatabase();

                        // Check if our tables exists //////////////////////////

                        createDatabase();

                        // Sanitize database ///////////////////////////////////

                        // TODO
                    }
                    else
                    {
                        qWarning() << "Cannot open database... Error:" << dbFile.lastError();
                    }
                }
            }
            else
            {
                qWarning() << "Cannot create nor open dbDirectory...";
            }
        }
        else
        {
            qWarning() << "Cannot find QStandardPaths::AppDataLocation directory...";
        }
    }
    else
    {
        qWarning() << "> SQLite is NOT available";
        m_dbInternalAvailable = false;
    }

    return m_dbInternalOpen;
}

/* ************************************************************************** */

bool DatabaseManager::openDatabase_mysql()
{
    return m_dbExternalOpen;
}

/* ************************************************************************** */

void DatabaseManager::closeDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);

        m_dbInternalOpen = false;
        m_dbExternalOpen = false;
    }
}

/* ************************************************************************** */

void DatabaseManager::resetDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString dbName = db.databaseName();
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);

        m_dbInternalOpen = false;
        m_dbExternalOpen = false;

        // remove db file
        QFile::remove(dbName);
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::tableExists(const QString &tableName)
{
    bool result = false;

    if (tableName.isEmpty())
    {
        qWarning() << "tableExists() with empty table name!";
    }
    else
    {
        QSqlQuery checkTable;
        if (m_dbInternalOpen) // sqlite
        {
            checkTable.exec("PRAGMA table_info(" + tableName + ");");
        }
        else if (m_dbExternalOpen) // mysql
        {
            checkTable.exec("SELECT * FROM information_schema.tables WHERE table_schema = 'toolBLEx' AND table_name = '" + tableName + "' LIMIT 1;");
            //checkTable.exec("SELECT * FROM information_schema.TABLES WHERE TABLE_NAME = '" + tableName + "' AND TABLE_SCHEMA in (SELECT DATABASE());");
        }
        if (checkTable.first())
        {
            result = true;
        }
    }

    return result;
}

void DatabaseManager::createDatabase()
{
    if (!tableExists("version"))
    {
        qDebug() << "+ Adding 'version' table to local database";

        QSqlQuery createDbVersion;
        createDbVersion.prepare("CREATE TABLE version (dbVersion INT);");
        if (createDbVersion.exec())
        {
            QSqlQuery writeDbVersion;
            writeDbVersion.prepare("INSERT INTO version (dbVersion) VALUES (:dbVersion)");
            writeDbVersion.bindValue(":dbVersion", s_dbCurrentVersion);
            writeDbVersion.exec();
        }
        else
        {
            qWarning() << "> createDbVersion.exec() ERROR"
                       << createDbVersion.lastError().type() << ":" << createDbVersion.lastError().text();
        }
    }

    if (!tableExists("devices"))
    {
        qDebug() << "+ Adding 'devices' table to local database";

        QSqlQuery createDevices;
        createDevices.prepare("CREATE TABLE devices (" \
                              "deviceAddr VARCHAR(38) PRIMARY KEY," \
                              "deviceAddrMAC VARCHAR(17)," \
                              "deviceName VARCHAR(255)," \
                              "deviceModel VARCHAR(255)," \
                              "deviceModelID VARCHAR(255)," \
                              "deviceManufacturer VARCHAR(255)," \
                              "deviceFirmware VARCHAR(255)," \
                              "deviceBattery INT," \
                              "deviceCoreConfig INT," \
                              "deviceClass VARCHAR(255)," \
                              "starred INT," \
                              "comment VARCHAR(255)," \
                              "color VARCHAR(255)," \
                              "firstSeen DATETIME," \
                              "lastSeen DATETIME," \
                              "settings VARCHAR(255)" \
                              ");");

        if (createDevices.exec() == false)
        {
            qWarning() << "> createDevices.exec() ERROR"
                       << createDevices.lastError().type() << ":" << createDevices.lastError().text();
        }
    }

    if (!tableExists("devicesBlacklist"))
    {
        qDebug() << "+ Adding 'devicesBlacklist' table to local database";

        QSqlQuery createDevicesBlacklist;
        createDevicesBlacklist.prepare("CREATE TABLE devicesBlacklist (" \
                                       "deviceAddr VARCHAR(38) PRIMARY KEY" \
                                       ");");

        if (createDevicesBlacklist.exec() == false)
        {
            qWarning() << "> createDevicesBlacklist.exec() ERROR"
                       << createDevicesBlacklist.lastError().type() << ":" << createDevicesBlacklist.lastError().text();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void DatabaseManager::migrateDatabase()
{
    int dbVersion = 0;

    QSqlQuery readVersion;
    readVersion.prepare("SELECT dbVersion FROM version");
    readVersion.exec();
    if (readVersion.first())
    {
        dbVersion = readVersion.value(0).toInt();
        //qDebug() << "dbVersion is #" << dbVersion;
    }
    readVersion.finish();

    if (dbVersion > 0 && dbVersion != s_dbCurrentVersion)
    {
        //
    }
}

/* ************************************************************************** */
