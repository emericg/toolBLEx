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
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "SettingsManager.h"

#include <QCoreApplication>
#include <QSettings>
#include <QLocale>
#include <QDebug>

#include <QStandardPaths>
#include <QFile>
#include <QDir>

/* ************************************************************************** */

SettingsManager *SettingsManager::instance = nullptr;

SettingsManager *SettingsManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new SettingsManager();
    }

    return instance;
}

SettingsManager::SettingsManager()
{
    readSettings();
}

SettingsManager::~SettingsManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void SettingsManager::reloadSettings()
{
    readSettings();
}

bool SettingsManager::readSettings()
{
    bool status = false;

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());

    if (settings.status() == QSettings::NoError)
    {
#if defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
        if (settings.contains("ApplicationWindow/x"))
            m_appPosition.setWidth(settings.value("ApplicationWindow/x").toInt());
        if (settings.contains("ApplicationWindow/y"))
            m_appPosition.setHeight(settings.value("ApplicationWindow/y").toInt());
        if (settings.contains("ApplicationWindow/width"))
            m_appSize.setWidth(settings.value("ApplicationWindow/width").toInt());
        if (settings.contains("ApplicationWindow/height"))
            m_appSize.setHeight(settings.value("ApplicationWindow/height").toInt());
        if (settings.contains("ApplicationWindow/visibility"))
            m_appVisibility = settings.value("ApplicationWindow/visibility").toUInt();

        if (m_appPosition.width() > 8192) m_appPosition.setWidth(100);
        if (m_appPosition.height() > 8192) m_appPosition.setHeight(100);
        if (m_appSize.width() > 8192) m_appSize.setWidth(1920);
        if (m_appSize.height() > 8192) m_appSize.setHeight(1080);
        if (m_appVisibility < 1 || m_appVisibility > 5) m_appVisibility = 1;
#endif

        ////

        if (settings.contains("settings/appTheme"))
            m_appTheme = settings.value("settings/appTheme").toString();

        if (settings.contains("settings/appThemeAuto"))
            m_appThemeAuto = settings.value("settings/appThemeAuto").toBool();

        if (settings.contains("settings/appSplashScreen"))
            m_appSplashScreen = settings.value("settings/appSplashScreen").toBool();

        if (settings.contains("settings/appLanguage"))
            m_appLanguage = settings.value("settings/appLanguage").toString();

        if (settings.contains("settings/appUnits"))
            m_appUnits = settings.value("settings/appUnits").toInt();

        ////

        if (settings.contains("settings/scanAuto"))
            m_scanAuto = settings.value("settings/scanAuto").toBool();

        if (settings.contains("settings/scanPause"))
            m_scanPause = settings.value("settings/scanPause").toBool();

        if (settings.contains("settings/scanCacheAuto"))
            m_scanCacheAuto = settings.value("settings/scanCacheAuto").toBool();

        if (settings.contains("settings/scanTimeout"))
            m_scanTimeout = settings.value("settings/scanTimeout").toInt();
        if (settings.contains("settings/scanRssiInterval"))
            m_scanRssiInterval = settings.value("settings/scanRssiInterval").toInt();

        if (settings.contains("settings/scanShowBeacon"))
            m_scanShowBeacon = settings.value("settings/scanShowBeacon").toBool();
        if (settings.contains("settings/scanShowBlacklisted"))
            m_scanShowBlacklisted = settings.value("settings/scanShowBlacklisted").toBool();
        if (settings.contains("settings/scanShowCached"))
            m_scanShowCached = settings.value("settings/scanShowCached").toBool();
        if (settings.contains("settings/scanShowClassic"))
            m_scanShowClassic = settings.value("settings/scanShowClassic").toBool();
        if (settings.contains("settings/scanShowLowEnergy"))
            m_scanShowLowEnergy = settings.value("settings/scanShowLowEnergy").toBool();

        if (settings.contains("settings/scanSplitviewOrientation"))
            m_scanviewOrientation = settings.value("settings/scanSplitviewOrientation").toInt();
        if (settings.contains("settings/scanSplitviewSize"))
            m_scanviewSize = settings.value("settings/scanSplitviewSize").toByteArray();

        if (settings.contains("settings/preferredScreen"))
            m_preferredScreen = settings.value("settings/preferredScreen").toInt();

        if (settings.contains("settings/preferredAdapter_scan"))
            m_preferredAdapter_scan = settings.value("settings/preferredAdapter_scan").toString();
        if (settings.contains("settings/preferredAdapter_adv"))
            m_preferredAdapter_adv = settings.value("settings/preferredAdapter_adv").toString();

        if (settings.contains("settings/exportDirectory"))
            m_exportDirectory = settings.value("settings/exportDirectory").toString();

        if (settings.contains("settings/ubertooth_path"))
            m_ubertooth_path = settings.value("settings/ubertooth_path").toString();
        if (settings.contains("settings/ubertooth_freqMin"))
            m_ubertooth_freqMin = settings.value("settings/ubertooth_freqMin").toInt();
        if (settings.contains("settings/ubertooth_freqMax"))
            m_ubertooth_freqMax = settings.value("settings/ubertooth_freqMax").toInt();

        status = true;
    }
    else
    {
        qWarning() << "SettingsManager::readSettings() error:" << settings.status();
    }

    return status;
}

/* ************************************************************************** */

bool SettingsManager::writeSettings()
{
    bool status = false;

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());

    if (settings.isWritable())
    {
        settings.setValue("settings/appTheme", m_appTheme);
        settings.setValue("settings/appThemeAuto", m_appThemeAuto);
        settings.setValue("settings/appSplashScreen", m_appSplashScreen);
        settings.setValue("settings/appLanguage", m_appLanguage);
        settings.setValue("settings/appUnits", m_appUnits);

        settings.setValue("settings/scanAuto", m_scanAuto);
        settings.setValue("settings/scanPause", m_scanPause);
        settings.setValue("settings/scanCacheAuto", m_scanCacheAuto);
        settings.setValue("settings/scanTimeout", m_scanTimeout);
        settings.setValue("settings/scanRssiInterval", m_scanRssiInterval);
        settings.setValue("settings/scanShowBeacon", m_scanShowBeacon);
        settings.setValue("settings/scanShowBlacklisted", m_scanShowBlacklisted);
        settings.setValue("settings/scanShowCached", m_scanShowCached);
        settings.setValue("settings/scanShowClassic", m_scanShowClassic);
        settings.setValue("settings/scanShowLowEnergy", m_scanShowLowEnergy);
        settings.setValue("settings/scanSplitviewOrientation", m_scanviewOrientation);
        settings.setValue("settings/scanSplitviewSize", m_scanviewSize);

        settings.setValue("settings/preferredScreen", m_preferredScreen);

        settings.setValue("settings/preferredAdapter_scan", m_preferredAdapter_scan);
        settings.setValue("settings/preferredAdapter_adv", m_preferredAdapter_adv);

        settings.setValue("settings/exportDirectory", m_exportDirectory);

        settings.setValue("settings/ubertooth_path", m_ubertooth_path);
        settings.setValue("settings/ubertooth_freqMin", m_ubertooth_freqMin);
        settings.setValue("settings/ubertooth_freqMax", m_ubertooth_freqMax);

        if (settings.status() == QSettings::NoError)
        {
            status = true;
        }
        else
        {
            qWarning() << "SettingsManager::writeSettings() error:" << settings.status();
        }
    }
    else
    {
        qWarning() << "SettingsManager::writeSettings() error: read only file?";
    }

    return status;
}

/* ************************************************************************** */

void SettingsManager::resetSettings()
{
    m_appTheme = "THEME_DESKTOP_LIGHT";
    Q_EMIT appThemeChanged();
    m_appThemeAuto = false;
    Q_EMIT appThemeAutoChanged();
    m_appThemeCSD = false;
    Q_EMIT appThemeCSDChanged();
    m_appSplashScreen = true;
    Q_EMIT appSplashScreenChanged();
    m_appUnits = 0;
    Q_EMIT appUnitsChanged();
    m_appLanguage = "auto";
    Q_EMIT appLanguageChanged();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SettingsManager::setAppTheme(const QString &value)
{
    if (m_appTheme != value)
    {
        m_appTheme = value;
        writeSettings();
        Q_EMIT appThemeChanged();
    }
}

void SettingsManager::setAppThemeAuto(const bool value)
{
    if (m_appThemeAuto != value)
    {
        m_appThemeAuto = value;
        writeSettings();
        Q_EMIT appThemeAutoChanged();
    }
}

void SettingsManager::setAppThemeCSD(const bool value)
{
    if (m_appThemeCSD != value)
    {
        m_appThemeCSD = value;
        writeSettings();
        Q_EMIT appThemeCSDChanged();
    }
}

void SettingsManager::setAppSplashScreen(const bool value)
{
    if (m_appSplashScreen != value)
    {
        m_appSplashScreen = value;
        writeSettings();
        Q_EMIT appSplashScreenChanged();
    }
}

void SettingsManager::setAppUnits(int value)
{
    if (m_appUnits != value)
    {
        m_appUnits = value;
        writeSettings();
        Q_EMIT appUnitsChanged();
    }
}

void SettingsManager::setAppLanguage(const QString &value)
{
    if (m_appLanguage != value)
    {
        m_appLanguage = value;
        writeSettings();
        Q_EMIT appLanguageChanged();
    }
}

/* ************************************************************************** */

void SettingsManager::setScanAuto(const bool value)
{
    if (m_scanAuto != value)
    {
        m_scanAuto = value;
        writeSettings();
        Q_EMIT scanAutoChanged();
    }
}

void SettingsManager::setScanPause(const bool value)
{
    if (m_scanPause != value)
    {
        m_scanPause = value;
        writeSettings();
        Q_EMIT scanPauseChanged();
    }
}

void SettingsManager::setScanCacheAuto(const bool value)
{
    if (m_scanCacheAuto != value)
    {
        m_scanCacheAuto = value;
        writeSettings();
        Q_EMIT scanCacheAutoChanged();
    }
}

void SettingsManager::setScanTimeout(const int value)
{
    if (m_scanTimeout != value)
    {
        m_scanTimeout = value;
        writeSettings();
        Q_EMIT scanTimeoutChanged();
    }
}

void SettingsManager::setScanRssiInterval(const int value)
{
    if (m_scanRssiInterval != value)
    {
        m_scanRssiInterval = value;
        writeSettings();
        Q_EMIT scanRssiIntervalChanged();
    }
}

void SettingsManager::setScanShowBeacon(const bool value)
{
    if (m_scanShowBeacon != value)
    {
        m_scanShowBeacon = value;
        writeSettings();
        Q_EMIT scanShowChanged();
    }
}
void SettingsManager::setScanShowBlacklisted(const bool value)
{
    if (m_scanShowBlacklisted != value)
    {
        m_scanShowBlacklisted = value;
        writeSettings();
        Q_EMIT scanShowChanged();
    }
}
void SettingsManager::setScanShowCached(const bool value)
{
    if (m_scanShowCached != value)
    {
        m_scanShowCached = value;
        writeSettings();
        Q_EMIT scanShowChanged();
    }
}
void SettingsManager::setScanShowClassic(const bool value)
{
    if (m_scanShowClassic != value)
    {
        m_scanShowClassic = value;
        writeSettings();
        Q_EMIT scanShowChanged();
    }
}
void SettingsManager::setScanShowLowEnergy(const bool value)
{
    if (m_scanShowLowEnergy != value)
    {
        m_scanShowLowEnergy = value;
        writeSettings();
        Q_EMIT scanShowChanged();
    }
}

/* ************************************************************************** */

void SettingsManager::setScanviewOrientation(const int value)
{
    if (m_scanviewOrientation != value)
    {
        m_scanviewOrientation = value;
        writeSettings();
        Q_EMIT scanviewChanged();
    }
}

void SettingsManager::setScanviewSize(const QByteArray &value)
{
    if (m_scanviewSize != value)
    {
        m_scanviewSize = value;
        writeSettings();
        Q_EMIT scanviewChanged();
    }
}

/* ************************************************************************** */

void SettingsManager::setPreferredScreen(const int value)
{
    if (m_preferredScreen != value)
    {
        m_preferredScreen = value;
        writeSettings();
        Q_EMIT preferredScreenChanged();
    }
}

/* ************************************************************************** */

void SettingsManager::setPreferredAdapter_scan(const QString &value)
{
    if (m_preferredAdapter_scan != value)
    {
        m_preferredAdapter_scan = value;
        writeSettings();
        Q_EMIT preferredAdapterScanChanged();
    }
}

void SettingsManager::setPreferredAdapter_adv(const QString &value)
{
    if (m_preferredAdapter_adv != value)
    {
        m_preferredAdapter_adv = value;
        writeSettings();
        Q_EMIT preferredAdapterAdvChanged();
    }
}

/* ************************************************************************** */

QString SettingsManager::getExportDirectory_str() const
{
    QString exportDirectoryString;
    QDir exportDirectory;

    // from saved settings
    exportDirectoryString = m_exportDirectory;
    if (!exportDirectoryString.isEmpty())
    {
        exportDirectory = QFileInfo(exportDirectoryString).dir();

        if (!exportDirectory.exists())
        {
            exportDirectory.mkpath(exportDirectory.path());
        }
        if (exportDirectory.exists())
        {
            return exportDirectoryString;
        }
    }

    // from default
    exportDirectoryString = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/toolBLEx";
    if (!exportDirectoryString.isEmpty())
    {
        exportDirectory = QFileInfo(exportDirectoryString).dir();

        if (!exportDirectory.exists())
        {
            exportDirectory.mkpath(exportDirectory.path());
        }
        if (exportDirectory.exists())
        {
            return exportDirectoryString;
        }
    }

    // fail
    return QString();
}

QUrl SettingsManager::getExportDirectory_url() const
{
    return QUrl::fromLocalFile(getExportDirectory_str());
}

void SettingsManager::setExportDirectory(const QString &value)
{
    if (m_exportDirectory != value)
    {
        m_exportDirectory = value;
        writeSettings();
        Q_EMIT exportDirectoryChanged();
    }
}

/* ************************************************************************** */

void SettingsManager::setUbertoothPath(const QString &value)
{
    if (m_ubertooth_path != value)
    {
        m_ubertooth_path = value;
        writeSettings();
        Q_EMIT ubertoothPathChanged();
    }
}

void SettingsManager::setUbertoothFreqMin(const int value)
{
    if (m_ubertooth_freqMin != value)
    {
        m_ubertooth_freqMin = value;
        writeSettings();
        Q_EMIT ubertoothFreqChanged();
    }
}

void SettingsManager::setUbertoothFreqMax(const int value)
{
    if (m_ubertooth_freqMax != value)
    {
        m_ubertooth_freqMax = value;
        writeSettings();
        Q_EMIT ubertoothFreqChanged();
    }
}

/* ************************************************************************** */
