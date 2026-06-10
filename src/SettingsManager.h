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

#include <QtQml/qqmlregistration.h>

#include <QObject>
#include <QByteArray>
#include <QString>
#include <QSize>
#include <QUrl>

#include <QLocale>
#include <QBluetoothDeviceDiscoveryAgent>

class QJSEngine;
class QQmlEngine;

/* ************************************************************************** */

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool firstLaunch READ isFirstLaunch NOTIFY firstLaunchChanged)

    Q_PROPERTY(QSize initialSize READ getInitialSize NOTIFY initialSizeChanged)
    Q_PROPERTY(QSize initialPosition READ getInitialPosition NOTIFY initialSizeChanged)
    Q_PROPERTY(int initialVisibility READ getInitialVisibility NOTIFY initialSizeChanged)

    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool appThemeAuto READ getAppThemeAuto WRITE setAppThemeAuto NOTIFY appThemeAutoChanged)
    Q_PROPERTY(int appThemeAutoMethod READ getAppThemeAutoMethod WRITE setAppThemeAutoMethod NOTIFY appThemeAutoChanged)
    Q_PROPERTY(bool appThemeCSD READ getAppThemeCSD WRITE setAppThemeCSD NOTIFY appThemeCSDChanged)
    Q_PROPERTY(bool appSplashScreen READ getAppSplashScreen WRITE setAppSplashScreen NOTIFY appSplashScreenChanged)
    Q_PROPERTY(int appUnits READ getAppUnits WRITE setAppUnits NOTIFY appUnitsChanged)
    Q_PROPERTY(QString appLanguage READ getAppLanguage WRITE setAppLanguage NOTIFY appLanguageChanged)

    Q_PROPERTY(int preferredScreen READ getPreferredScreen WRITE setPreferredScreen NOTIFY preferredScreenChanged)
    Q_PROPERTY(QString preferredAdapter_scan READ getPreferredAdapter_scan WRITE setPreferredAdapter_scan NOTIFY preferredAdapterScanChanged)
    Q_PROPERTY(QString preferredAdapter_adv READ getPreferredAdapter_adv WRITE setPreferredAdapter_adv NOTIFY preferredAdapterAdvChanged)

    Q_PROPERTY(bool scanAuto READ getScanAuto WRITE setScanAuto NOTIFY scanAutoChanged)
    Q_PROPERTY(bool scanPause READ getScanPause WRITE setScanPause NOTIFY scanPauseChanged)
    Q_PROPERTY(bool scanCacheAuto READ getScanCacheAuto WRITE setScanCacheAuto NOTIFY scanCacheAutoChanged)
    Q_PROPERTY(int scanMethods READ getScanMethods WRITE setScanMethods NOTIFY scanMethodsChanged)
    Q_PROPERTY(int scanTimeout READ getScanTimeout WRITE setScanTimeout NOTIFY scanTimeoutChanged)
    Q_PROPERTY(int scanRssiInterval READ getScanRssiInterval WRITE setScanRssiInterval NOTIFY scanRssiIntervalChanged)

    Q_PROPERTY(bool scanShowBeacon READ getScanShowBeacon WRITE setScanShowBeacon NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowBlacklisted READ getScanShowBlacklisted WRITE setScanShowBlacklisted NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowCached READ getScanShowCached WRITE setScanShowCached NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowClassic READ getScanShowClassic WRITE setScanShowClassic NOTIFY scanShowChanged)
    Q_PROPERTY(bool scanShowLowEnergy READ getScanShowLowEnergy WRITE setScanShowLowEnergy NOTIFY scanShowChanged)

    Q_PROPERTY(int scanviewOrientation READ getScanviewOrientation WRITE setScanviewOrientation NOTIFY scanviewChanged)
    Q_PROPERTY(QByteArray scanviewSize READ getScanviewSize WRITE setScanviewSize NOTIFY scanviewChanged)

    Q_PROPERTY(QString exportDirectory READ getExportDirectory WRITE setExportDirectory NOTIFY exportDirectoryChanged)
    Q_PROPERTY(QString exportDirectory_str READ getExportDirectory_str NOTIFY exportDirectoryChanged)
    Q_PROPERTY(QUrl exportDirectory_url READ getExportDirectory_url NOTIFY exportDirectoryChanged)

    Q_PROPERTY(int spectrogram_samplingFreq READ getSpectrogramSamplingFreq WRITE setSpectrogramSamplingFreq NOTIFY spectrogramSamplingChanged)
    Q_PROPERTY(int spectrogram_historyCurves READ getSpectrogramHistoryCurves WRITE setSpectrogramHistoryCurves NOTIFY spectrogramHistoryChanged)
    Q_PROPERTY(int spectrogram_graphSelected READ getSpectrogramGraphSelected WRITE setSpectrogramGraphSelected NOTIFY spectrogramGraphChanged)
    Q_PROPERTY(int spectrogram_graphColors READ getSpectrogramGraphColors WRITE setSpectrogramGraphColors NOTIFY spectrogramColorsChanged)

    Q_PROPERTY(QString ubertooth_path READ getUbertoothPath WRITE setUbertoothPath NOTIFY ubertoothPathChanged)
    Q_PROPERTY(int ubertooth_freqMin READ getUbertoothFreqMin WRITE setUbertoothFreqMin NOTIFY ubertoothFreqChanged)
    Q_PROPERTY(int ubertooth_freqMax READ getUbertoothFreqMax WRITE setUbertoothFreqMax NOTIFY ubertoothFreqChanged)

    Q_PROPERTY(QString rtlsdr_path READ getRtlSdrPath WRITE setRtlSdrPath NOTIFY rtlsdrPathChanged)
    Q_PROPERTY(int rtlsdr_freqTarget READ getRtlSdrFreqTarget WRITE setRtlSdrFreqTarget NOTIFY rtlsdrFreqChanged)
    Q_PROPERTY(int rtlsdr_freqBandwidth READ getRtlSdrFreqBandwidth WRITE setRtlSdrFreqBandwidth NOTIFY rtlsdrFreqChanged)

    bool m_firstlaunch = true;

    // Application window
    QSize m_appSize;
    QSize m_appPosition;
    int m_appVisibility = 1;                //!< QWindow::Visibility

    // Application generic
    QString m_appTheme = "THEME_DESKTOP_LIGHT";
    bool m_appThemeAuto = false;
    int m_appThemeAutoMethod = 0;
    bool m_appThemeCSD = false;
    bool m_appSplashScreen = true;
    int m_appUnits = QLocale::MetricSystem; //!< QLocale::MeasurementSystem
    QString m_appLanguage = "auto";

    // Application specific
    int m_preferredScreen = 0;
    QString m_preferredAdapter_scan;
    QString m_preferredAdapter_adv;

    int m_scanMethods = QBluetoothDeviceDiscoveryAgent::LowEnergyMethod; //!< QBluetoothDeviceDiscoveryAgent::DiscoveryMethod
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

    QString m_exportDirectory;

    int m_spectrogram_samplingFrequency = 60;
    int m_spectrogram_historyCurves = 32;
    int m_spectrogram_graphSelected = 0;
    int m_spectrogram_graphColors = 0;

    QString m_ubertooth_path = "ubertooth-specan";
    int m_ubertooth_freqMin = 2400;
    int m_ubertooth_freqMax = 2500;

    QString m_rtlsdr_path = "soapy_power";
    int m_rtlsdr_freqTarget = 433;
    int m_rtlsdr_freqBandwidth = 2400;

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
    void appThemeAutoMethodChanged();
    void appThemeCSDChanged();
    void appSplashScreenChanged();
    void appUnitsChanged();
    void appLanguageChanged();

    void preferredScreenChanged();
    void preferredAdapterScanChanged();
    void preferredAdapterAdvChanged();

    void scanAutoChanged();
    void scanPauseChanged();
    void scanCacheAutoChanged();
    void scanMethodsChanged();
    void scanTimeoutChanged();
    void scanRssiIntervalChanged();
    void scanShowChanged();
    void scanviewChanged();

    void exportDirectoryChanged();

    void spectrogramSamplingChanged();
    void spectrogramHistoryChanged();
    void spectrogramGraphChanged();
    void spectrogramColorsChanged();

    void ubertoothPathChanged();
    void ubertoothFreqChanged();

    void rtlsdrPathChanged();
    void rtlsdrFreqChanged();

public:
    static SettingsManager *getInstance();
    static SettingsManager *create(QQmlEngine *, QJSEngine *);

    bool isFirstLaunch() const { return m_firstlaunch; }

    QSize getInitialSize() { return m_appSize; }
    QSize getInitialPosition() { return m_appPosition; }
    int getInitialVisibility() { return m_appVisibility; }

    ////

    const QString &getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAppThemeAuto() const { return m_appThemeAuto; }
    void setAppThemeAuto(const bool value);

    int getAppThemeAutoMethod() const { return m_appThemeAutoMethod; }
    void setAppThemeAutoMethod(const int value);

    bool getAppThemeCSD() const { return m_appThemeCSD; }
    void setAppThemeCSD(const bool value);

    bool getAppSplashScreen() const { return m_appSplashScreen; }
    void setAppSplashScreen(const bool value);

    int getAppUnits() const { return m_appUnits; }
    void setAppUnits(int value);

    const QString &getAppLanguage() const { return m_appLanguage; }
    void setAppLanguage(const QString &value);

    ////

    bool getScanAuto() const { return m_scanAuto; }
    void setScanAuto(const bool value);

    bool getScanPause() const { return m_scanPause; }
    void setScanPause(const bool value);

    bool getScanCacheAuto() const { return m_scanCacheAuto; }
    void setScanCacheAuto(const bool value);

    int getScanMethods() const { return m_scanMethods; }
    void setScanMethods(const int value);

    int getScanTimeout_ms() const { return m_scanTimeout*60*1000; }
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
    const QByteArray &getScanviewSize() const { return m_scanviewSize; }
    void setScanviewSize(const QByteArray &value);

    int getPreferredScreen() const { return m_preferredScreen; }
    void setPreferredScreen(const int value);

    const QString &getPreferredAdapter_scan() const { return m_preferredAdapter_scan; }
    void setPreferredAdapter_scan(const QString &value);
    const QString &getPreferredAdapter_adv() const { return m_preferredAdapter_adv; }
    void setPreferredAdapter_adv(const QString &value);

    const QString &getExportDirectory() const { return m_exportDirectory; }
    QString getExportDirectory_str() const;
    QUrl getExportDirectory_url() const;
    void setExportDirectory(const QString &value);

    const QString &getUbertoothPath() const { return m_ubertooth_path; }
    void setUbertoothPath(const QString &value);
    int getUbertoothFreqMin() const { return m_ubertooth_freqMin; }
    void setUbertoothFreqMin(const int value);
    int getUbertoothFreqMax() const { return m_ubertooth_freqMax; }
    void setUbertoothFreqMax(const int value);

    const QString &getRtlSdrPath() const { return m_rtlsdr_path; }
    void setRtlSdrPath(const QString &value);
    int getRtlSdrFreqTarget() const { return m_rtlsdr_freqTarget; }
    void setRtlSdrFreqTarget(const int value);
    int getRtlSdrFreqBandwidth() const { return m_rtlsdr_freqBandwidth; }
    void setRtlSdrFreqBandwidth(const int value);

    int getSpectrogramSamplingFreq() const { return m_spectrogram_samplingFrequency; }
    void setSpectrogramSamplingFreq(const int value);
    int getSpectrogramHistoryCurves() const { return m_spectrogram_historyCurves; }
    void setSpectrogramHistoryCurves(const int value);
    int getSpectrogramGraphSelected() const { return m_spectrogram_graphSelected; }
    void setSpectrogramGraphSelected(const int value);
    int getSpectrogramGraphColors() const { return m_spectrogram_graphColors; }
    void setSpectrogramGraphColors(const int value);

    ////

    Q_INVOKABLE void reloadSettings();
    Q_INVOKABLE void resetSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
