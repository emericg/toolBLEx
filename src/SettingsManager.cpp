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
#include <QQmlEngine>
#include <QJSEngine>
#include <QSettings>
#include <QLocale>
#include <QDebug>

#include <QStandardPaths>
#include <QFile>
#include <QDir>

/* ************************************************************************** */
/* ************************************************************************** */

SettingsManager *SettingsManager::getInstance()
{
    static SettingsManager *instance = new SettingsManager(QCoreApplication::instance());
    return instance;
}

SettingsManager *SettingsManager::create(QQmlEngine *, QJSEngine *)
{
    SettingsManager *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

SettingsManager::SettingsManager(QObject *parent) : QObject(parent)
{
    readSettings();
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
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
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
        if (settings.contains("settings/appTheme"))
            m_appTheme = settings.value("settings/appTheme").toString();

        if (settings.contains("settings/appThemeAuto"))
            m_appThemeAuto = settings.value("settings/appThemeAuto").toBool();

        if (settings.contains("settings/appThemeAutoMethod"))
            m_appThemeAutoMethod = settings.value("settings/appThemeAutoMethod").toUInt();

        if (settings.contains("settings/appUnitSystem"))
            m_appUnitSystem = settings.value("settings/appUnitSystem").toUInt();

        if (settings.contains("settings/appLanguage"))
            m_appLanguage = settings.value("settings/appLanguage").toString();

        if (settings.contains("settings/appSplashScreen"))
            m_appSplashScreen = settings.value("settings/appSplashScreen").toBool();

        ////

        if (settings.contains("settings/preferredScreen"))
            m_preferredScreen = settings.value("settings/preferredScreen").toInt();
        if (settings.contains("settings/preferredAdapter_scan"))
            m_preferredAdapter_scan = settings.value("settings/preferredAdapter_scan").toString();
        if (settings.contains("settings/preferredAdapter_adv"))
            m_preferredAdapter_adv = settings.value("settings/preferredAdapter_adv").toString();

        if (settings.contains("settings/scanAuto"))
            m_scanAuto = settings.value("settings/scanAuto").toBool();
        if (settings.contains("settings/scanPause"))
            m_scanPause = settings.value("settings/scanPause").toBool();
        if (settings.contains("settings/scanCacheAuto"))
            m_scanCacheAuto = settings.value("settings/scanCacheAuto").toBool();

        if (settings.contains("settings/scanMethods"))
            m_scanMethods = settings.value("settings/scanMethods").toInt();
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

        if (settings.contains("settings/exportDirectory"))
            m_exportDirectory = settings.value("settings/exportDirectory").toString();

        if (settings.contains("settings/spectrogram_maxSamplingFreq"))
            m_spectrogram_maxSamplingFreq = settings.value("settings/spectrogram_maxSamplingFreq").toInt();
        if (settings.contains("settings/spectrogram_historyCurves"))
            m_spectrogram_historyCurves = settings.value("settings/spectrogram_historyCurves").toInt();
        if (settings.contains("settings/spectrogram_graphSelected"))
            m_spectrogram_graphSelected = settings.value("settings/spectrogram_graphSelected").toInt();
        if (settings.contains("settings/spectrogram_graphColors"))
            m_spectrogram_graphColors = settings.value("settings/spectrogram_graphColors").toInt();

        if (settings.contains("settings/ubertooth_path"))
            m_ubertooth_path = settings.value("settings/ubertooth_path").toString();
        if (settings.contains("settings/ubertooth_freqMin"))
            m_ubertooth_freqMin = settings.value("settings/ubertooth_freqMin").toInt();
        if (settings.contains("settings/ubertooth_freqMax"))
            m_ubertooth_freqMax = settings.value("settings/ubertooth_freqMax").toInt();

        if (settings.contains("settings/rtlsdr_path"))
            m_rtlsdr_path = settings.value("settings/rtlsdr_path").toString();
        if (settings.contains("settings/rtlsdr_freqTarget"))
            m_rtlsdr_freqTarget = settings.value("settings/rtlsdr_freqTarget").toInt();
        if (settings.contains("settings/rtlsdr_freqBandwidth"))
            m_rtlsdr_freqBandwidth = settings.value("settings/rtlsdr_freqBandwidth").toInt();

        status = true;
    }
    else
    {
        qWarning() << "SettingsManager::readSettings() error:" << settings.status();
    }

    if (m_firstlaunch)
    {
        // force settings file creation?
        //writeSettings();
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
        settings.setValue("settings/appThemeAutoMethod", m_appThemeAutoMethod);
        settings.setValue("settings/appUnitSystem", m_appUnitSystem);
        settings.setValue("settings/appLanguage", m_appLanguage);
        settings.setValue("settings/appSplashScreen", m_appSplashScreen);

        settings.setValue("settings/preferredScreen", m_preferredScreen);
        settings.setValue("settings/preferredAdapter_scan", m_preferredAdapter_scan);
        settings.setValue("settings/preferredAdapter_adv", m_preferredAdapter_adv);

        settings.setValue("settings/scanAuto", m_scanAuto);
        settings.setValue("settings/scanPause", m_scanPause);
        settings.setValue("settings/scanCacheAuto", m_scanCacheAuto);
        settings.setValue("settings/scanMethods", m_scanMethods);
        settings.setValue("settings/scanTimeout", m_scanTimeout);
        settings.setValue("settings/scanRssiInterval", m_scanRssiInterval);
        settings.setValue("settings/scanShowBeacon", m_scanShowBeacon);
        settings.setValue("settings/scanShowBlacklisted", m_scanShowBlacklisted);
        settings.setValue("settings/scanShowCached", m_scanShowCached);
        settings.setValue("settings/scanShowClassic", m_scanShowClassic);
        settings.setValue("settings/scanShowLowEnergy", m_scanShowLowEnergy);
        settings.setValue("settings/scanSplitviewOrientation", m_scanviewOrientation);
        settings.setValue("settings/scanSplitviewSize", m_scanviewSize);

        settings.setValue("settings/exportDirectory", m_exportDirectory);

        settings.setValue("settings/spectrogram_maxSamplingFreq", m_spectrogram_maxSamplingFreq);
        settings.setValue("settings/spectrogram_historyCurves", m_spectrogram_historyCurves);
        settings.setValue("settings/spectrogram_graphSelected", m_spectrogram_graphSelected);
        settings.setValue("settings/spectrogram_graphColors", m_spectrogram_graphColors);

        settings.setValue("settings/ubertooth_path", m_ubertooth_path);
        settings.setValue("settings/ubertooth_freqMin", m_ubertooth_freqMin);
        settings.setValue("settings/ubertooth_freqMax", m_ubertooth_freqMax);

        settings.setValue("settings/rtlsdr_path", m_rtlsdr_path);
        settings.setValue("settings/rtlsdr_freqTarget", m_rtlsdr_freqTarget);
        settings.setValue("settings/rtlsdr_freqBandwidth", m_rtlsdr_freqBandwidth);

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
    m_appThemeAutoMethod = 0;
    Q_EMIT appThemeAutoMethodChanged();
    m_appUnitSystem = 0;
    Q_EMIT appUnitSystemChanged();
    m_appLanguage = "auto";
    Q_EMIT appLanguageChanged();
    m_appSplashScreen = true;
    Q_EMIT appSplashScreenChanged();

    m_preferredScreen = 0;
    Q_EMIT preferredScreenChanged();
    m_preferredAdapter_scan.clear();
    Q_EMIT preferredAdapterScanChanged();
    m_preferredAdapter_adv.clear();
    Q_EMIT preferredAdapterAdvChanged();

    m_scanMethods = QBluetoothDeviceDiscoveryAgent::LowEnergyMethod;
    Q_EMIT scanMethodsChanged();
    m_scanTimeout = 0;
    Q_EMIT scanTimeoutChanged();
    m_scanRssiInterval = 1000;
    Q_EMIT scanRssiIntervalChanged();

    m_scanAuto = true;
    Q_EMIT scanAutoChanged();
    m_scanPause = false;
    Q_EMIT scanPauseChanged();
    m_scanCacheAuto = true;
    Q_EMIT scanCacheAutoChanged();
    m_scanShowBeacon = true;
    m_scanShowBlacklisted = false;
    m_scanShowCached = true;
    m_scanShowClassic = true;
    m_scanShowLowEnergy = true;
    Q_EMIT scanShowChanged();

    m_scanviewOrientation = Qt::Horizontal;
    m_scanviewSize.clear();
    Q_EMIT scanviewChanged();

    m_exportDirectory.clear();
    Q_EMIT exportDirectoryChanged();

    m_spectrogram_maxSamplingFreq = 60;
    Q_EMIT spectrogramMaxSamplingFreqChanged();
    m_spectrogram_historyCurves = 32;
    Q_EMIT spectrogramHistoryChanged();
    m_spectrogram_graphSelected = 0;
    Q_EMIT spectrogramGraphChanged();
    m_spectrogram_graphColors = 0;
    Q_EMIT spectrogramColorsChanged();

    m_ubertooth_path.clear();
    Q_EMIT ubertoothPathChanged();
    m_ubertooth_freqMin = 2400;
    m_ubertooth_freqMax = 2500;
    Q_EMIT ubertoothFreqChanged();

    m_rtlsdr_path.clear();
    Q_EMIT rtlsdrPathChanged();
    m_rtlsdr_freqTarget = 433;
    m_rtlsdr_freqBandwidth = 2400;
    Q_EMIT rtlsdrFreqChanged();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SettingsManager::setAppTheme(const QString &value)
{
    if (m_appTheme != value)
    {
        m_appTheme = value;
        Q_EMIT appThemeChanged();

        writeSettings();
    }
}

void SettingsManager::setAppThemeAuto(const bool value)
{
    if (m_appThemeAuto != value)
    {
        m_appThemeAuto = value;
        Q_EMIT appThemeAutoChanged();

        writeSettings();
    }
}

void SettingsManager::setAppThemeAutoMethod(const unsigned value)
{
    if (m_appThemeAutoMethod != value)
    {
        m_appThemeAutoMethod = value;
        Q_EMIT appThemeAutoMethodChanged();

        writeSettings();
    }
}

void SettingsManager::setAppUnitSystem(const unsigned value)
{
    if (m_appUnitSystem != value)
    {
        m_appUnitSystem = value;
        Q_EMIT appUnitSystemChanged();

        writeSettings();
    }
}

void SettingsManager::setAppLanguage(const QString &value)
{
    if (m_appLanguage != value)
    {
        m_appLanguage = value;
        Q_EMIT appLanguageChanged();

        writeSettings();
    }
}

void SettingsManager::setAppSplashScreen(const bool value)
{
    if (m_appSplashScreen != value)
    {
        m_appSplashScreen = value;
        Q_EMIT appSplashScreenChanged();

        writeSettings();
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

void SettingsManager::setScanMethods(const int value)
{
    if (value >= 1 && value <= 3)
    {
        if (m_scanMethods != value)
        {
            m_scanMethods = value;
            writeSettings();
            Q_EMIT scanMethodsChanged();
        }
    }
    else
    {
        qWarning() << "SettingsManager::setScanMethods(" << value << ") INVALID VALUE";
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

void SettingsManager::setSpectrogramMaxSamplingFreq(const int value)
{
    if (value >= 10 && value <= 120)
    {
        if (m_spectrogram_maxSamplingFreq != value)
        {
            m_spectrogram_maxSamplingFreq = value;
            writeSettings();
            Q_EMIT spectrogramMaxSamplingFreqChanged();
        }
    }
}

void SettingsManager::setSpectrogramHistoryCurves(const int value)
{
    if (value >= 16 && value <= 64)
    {
        if (m_spectrogram_historyCurves != value)
        {
            m_spectrogram_historyCurves = value;
            writeSettings();
            Q_EMIT spectrogramHistoryChanged();
        }
    }
}

void SettingsManager::setSpectrogramGraphSelected(const int value)
{
    if (m_spectrogram_graphSelected != value)
    {
        m_spectrogram_graphSelected = value;
        writeSettings();
        Q_EMIT spectrogramGraphChanged();
    }
}

void SettingsManager::setSpectrogramGraphColors(const int value)
{
    if (m_spectrogram_graphColors != value)
    {
        m_spectrogram_graphColors = value;
        writeSettings();
        Q_EMIT spectrogramColorsChanged();
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
    if (value >= 2300 && value < 2600)
    {
        if (m_ubertooth_freqMin != value)
        {
            m_ubertooth_freqMin = value;
            writeSettings();
            Q_EMIT ubertoothFreqChanged();
        }
    }
}

void SettingsManager::setUbertoothFreqMax(const int value)
{
    if (value > 2300 && value <= 2600)
    {
        if (m_ubertooth_freqMax != value)
        {
            m_ubertooth_freqMax = value;
            writeSettings();
            Q_EMIT ubertoothFreqChanged();
        }
    }
}

/* ************************************************************************** */

void SettingsManager::setRtlSdrPath(const QString &value)
{
    if (m_rtlsdr_path != value)
    {
        m_rtlsdr_path = value;
        writeSettings();
        Q_EMIT rtlsdrPathChanged();
    }
}

void SettingsManager::setRtlSdrFreqTarget(const int value)
{
    if (value >= 52 && value <= 2200)
    {
        if (m_rtlsdr_freqTarget != value)
        {
            m_rtlsdr_freqTarget = value;
            writeSettings();
            Q_EMIT rtlsdrFreqChanged();
        }
    }
}

void SettingsManager::setRtlSdrFreqBandwidth(const int value)
{
    if (value >= 2400 && value <= 3200)
    {
        if (m_rtlsdr_freqBandwidth != value)
        {
            m_rtlsdr_freqBandwidth = value;
            writeSettings();
            Q_EMIT rtlsdrFreqChanged();
        }
    }
}

/* ************************************************************************** */
