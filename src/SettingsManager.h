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

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QByteArray>
#include <QLocale>
#include <QString>
#include <QSize>
#include <QUrl>

/* ************************************************************************** */

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool firstLaunch READ isFirstLaunch NOTIFY firstLaunchChanged)

    Q_PROPERTY(QSize initialSize READ getInitialSize NOTIFY initialSizeChanged)
    Q_PROPERTY(QSize initialPosition READ getInitialPosition NOTIFY initialSizeChanged)
    Q_PROPERTY(int initialVisibility READ getInitialVisibility NOTIFY initialSizeChanged)

    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool appThemeAuto READ getAppThemeAuto WRITE setAppThemeAuto NOTIFY appThemeAutoChanged)
    Q_PROPERTY(bool appThemeCSD READ getAppThemeCSD WRITE setAppThemeCSD NOTIFY appThemeCSDChanged)
    Q_PROPERTY(bool appSplashScreen READ getAppSplashScreen WRITE setAppSplashScreen NOTIFY appSplashScreenChanged)
    Q_PROPERTY(int appUnits READ getAppUnits WRITE setAppUnits NOTIFY appUnitsChanged)
    Q_PROPERTY(QString appLanguage READ getAppLanguage WRITE setAppLanguage NOTIFY appLanguageChanged)

    Q_PROPERTY(bool scanAuto READ getScanAuto WRITE setScanAuto NOTIFY scanAutoChanged)
    Q_PROPERTY(bool scanPause READ getScanPause WRITE setScanPause NOTIFY scanPauseChanged)
    Q_PROPERTY(bool scanCacheAuto READ getScanCacheAuto WRITE setScanCacheAuto NOTIFY scanCacheAutoChanged)
    Q_PROPERTY(int scanTimeout READ getScanTimeout WRITE setScanTimeout NOTIFY scanTimeoutChanged)
    Q_PROPERTY(int scanRssiInterval READ getScanRssiInterval WRITE setScanRssiInterval NOTIFY scanRssiIntervalChanged)

    Q_PROPERTY(bool scanShowBeacon READ getScanShowBeacon WRITE setScanShowBeacon NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowBlacklisted READ getScanShowBlacklisted WRITE setScanShowBlacklisted NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowCached READ getScanShowCached WRITE setScanShowCached NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowClassic READ getScanShowClassic WRITE setScanShowClassic NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowLowEnergy READ getScanShowLowEnergy WRITE setScanShowLowEnergy NOTIFY scanShowChanged)

    Q_PROPERTY(int scanviewOrientation READ getScanviewOrientation WRITE setScanviewOrientation NOTIFY scanviewChanged)
    Q_PROPERTY(QByteArray scanviewSize READ getScanviewSize WRITE setScanviewSize NOTIFY scanviewChanged)

    Q_PROPERTY(int preferredScreen READ getPreferredScreen WRITE setPreferredScreen NOTIFY preferredScreenChanged)

    Q_PROPERTY(QString preferredAdapter_scan READ getPreferredAdapter_scan WRITE setPreferredAdapter_scan NOTIFY preferredAdapterScanChanged)
    Q_PROPERTY(QString preferredAdapter_adv READ getPreferredAdapter_adv WRITE setPreferredAdapter_adv NOTIFY preferredAdapterAdvChanged)

    Q_PROPERTY(QString exportDirectory READ getExportDirectory WRITE setExportDirectory NOTIFY exportDirectoryChanged)
    Q_PROPERTY(QString exportDirectory_str READ getExportDirectory_str NOTIFY exportDirectoryChanged)
    Q_PROPERTY(QUrl exportDirectory_url READ getExportDirectory_url NOTIFY exportDirectoryChanged)

    Q_PROPERTY(QString ubertooth_path READ getUbertoothPath WRITE setUbertoothPath NOTIFY ubertoothPathChanged)
    Q_PROPERTY(int ubertooth_freqMin READ getUbertoothFreqMin WRITE setUbertoothFreqMin NOTIFY ubertoothFreqChanged)
    Q_PROPERTY(int ubertooth_freqMax READ getUbertoothFreqMax WRITE setUbertoothFreqMax NOTIFY ubertoothFreqChanged)

    bool m_firstlaunch = true;

    // Application window
    QSize m_appSize;
    QSize m_appPosition;
    int m_appVisibility = 1;                        //!< QWindow::Visibility

    // Application generic
    QString m_appTheme = "THEME_DESKTOP_LIGHT";
    bool m_appThemeAuto = false;
    bool m_appThemeCSD = false;
    bool m_appSplashScreen = true;
    int m_appUnits = QLocale::MetricSystem;         //!< QLocale::MeasurementSystem
    QString m_appLanguage = "auto";

    // Application specific
    int m_scanTimeout = 0;
    int m_scanRssiInterval = 1000;
    bool m_scanAuto = true;
    bool m_scanPause = false;
    bool m_scanCacheAuto = true;
    bool m_scanShowBeacon = true;
    bool m_scanShowBlacklisted = false;
    bool m_scanShowCached = true;
    bool m_scanShowClassic = true;
    bool m_scanShowLowEnergy = true;

    int m_scanviewOrientation = Qt::Horizontal;
    QByteArray m_scanviewSize;

    int m_preferredScreen = 0;

    QString m_preferredAdapter_scan;
    QString m_preferredAdapter_adv;

    QString m_exportDirectory;

    QString m_ubertooth_path = "ubertooth-specan";
    int m_ubertooth_freqMin = 2400;
    int m_ubertooth_freqMax = 2483;

    // Singleton
    static SettingsManager *instance;
    SettingsManager();
    ~SettingsManager();

    bool readSettings();
    bool writeSettings();

Q_SIGNALS:
    void firstLaunchChanged();
    void initialSizeChanged();
    void appThemeChanged();
    void appThemeAutoChanged();
    void appThemeCSDChanged();
    void appSplashScreenChanged();
    void appUnitsChanged();
    void appLanguageChanged();

    void scanAutoChanged();
    void scanPauseChanged();
    void scanCacheAutoChanged();
    void scanTimeoutChanged();
    void scanRssiIntervalChanged();
    void scanShowChanged();
    void scanviewChanged();
    void preferredScreenChanged();
    void preferredAdapterScanChanged();
    void preferredAdapterAdvChanged();
    void exportDirectoryChanged();
    void ubertoothPathChanged();
    void ubertoothFreqChanged();

public:
    static SettingsManager *getInstance();

    bool isFirstLaunch() const { return m_firstlaunch; }

    QSize getInitialSize() { return m_appSize; }
    QSize getInitialPosition() { return m_appPosition; }
    int getInitialVisibility() { return m_appVisibility; }

    ////

    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAppThemeAuto() const { return m_appThemeAuto; }
    void setAppThemeAuto(const bool value);

    bool getAppThemeCSD() const { return m_appThemeCSD; }
    void setAppThemeCSD(const bool value);

    bool getAppSplashScreen() const { return m_appSplashScreen; }
    void setAppSplashScreen(const bool value);

    int getAppUnits() const { return m_appUnits; }
    void setAppUnits(int value);

    QString getAppLanguage() const { return m_appLanguage; }
    void setAppLanguage(const QString &value);

    ////

    bool getScanAuto() const { return m_scanAuto; }
    void setScanAuto(const bool value);

    bool getScanPause() const { return m_scanPause; }
    void setScanPause(const bool value);

    bool getScanCacheAuto() const { return m_scanCacheAuto; }
    void setScanCacheAuto(const bool value);

    int getScanTimeout() const { return m_scanTimeout; }
    void setScanTimeout(const int value);

    int getScanRssiInterval() const { return m_scanRssiInterval; }
    void setScanRssiInterval(const int value);

    bool getScanShowBeacon() const { return m_scanShowBeacon; }
    void setScanShowBeacon(const bool value);
    bool getScanShowBlacklisted() const { return m_scanShowBlacklisted; }
    void setScanShowBlacklisted(const bool value);
    bool getScanShowCached() const { return m_scanShowCached; }
    void setScanShowCached(const bool value);
    bool getScanShowClassic() const { return m_scanShowClassic; }
    void setScanShowClassic(const bool value);
    bool getScanShowLowEnergy() const { return m_scanShowLowEnergy; }
    void setScanShowLowEnergy(const bool value);

    int getScanviewOrientation() const { return m_scanviewOrientation; }
    void setScanviewOrientation(const int value);
    QByteArray getScanviewSize() const { return m_scanviewSize; }
    void setScanviewSize(const QByteArray &value);

    int getPreferredScreen() const { return m_preferredScreen; }
    void setPreferredScreen(const int value);

    QString getPreferredAdapter_scan() const { return m_preferredAdapter_scan; }
    void setPreferredAdapter_scan(const QString &value);
    QString getPreferredAdapter_adv() const { return m_preferredAdapter_adv; }
    void setPreferredAdapter_adv(const QString &value);

    QString getExportDirectory() const { return m_exportDirectory; }
    QString getExportDirectory_str() const;
    QUrl getExportDirectory_url() const;
    void setExportDirectory(const QString &value);

    QString getUbertoothPath() const { return m_ubertooth_path; }
    void setUbertoothPath(const QString &value);
    int getUbertoothFreqMin() const { return m_ubertooth_freqMin; }
    void setUbertoothFreqMin(const int value);
    int getUbertoothFreqMax() const { return m_ubertooth_freqMax; }
    void setUbertoothFreqMax(const int value);

    ////

    Q_INVOKABLE void reloadSettings();
    Q_INVOKABLE void resetSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
