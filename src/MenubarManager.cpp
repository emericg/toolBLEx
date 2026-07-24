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

#include "MenubarManager.h"
#include "DeviceManager.h"
#include "SpectrumSource.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QJSEngine>
#include <QDesktopServices>
#include <QKeySequence>
#include <QQuickWindow>
#include <QMenuBar>
#include <QMenu>

/* ************************************************************************** */
/* ************************************************************************** */

MenubarManager *MenubarManager::getInstance()
{
    static MenubarManager *instance = new MenubarManager(QCoreApplication::instance());
    return instance;
}

MenubarManager *MenubarManager::create(QQmlEngine *, QJSEngine *)
{
    MenubarManager *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

/* ************************************************************************** */

MenubarManager::MenubarManager(QObject *parent) : QObject(parent)
{
    //
}

MenubarManager::~MenubarManager()
{

    delete m_actionAbout;
    delete m_actionSettings;

    delete m_actionExport;
    delete m_actionClear;
    delete m_menuFile;

    delete m_actionSensorList;
    delete m_actionScanStart;
    delete m_actionScanStop;
    delete m_actionDisconnect;
    delete m_menuSensors;

    delete m_actionViewScanner;
    delete m_actionViewAdvertiser;
    delete m_actionViewUbertooth;
    delete m_actionViewRtlsdr;
    delete m_menuSort; // owns its sort actions
    delete m_menuView;

    delete m_actionMinimize;
    delete m_actionMaximize;
    delete m_actionFullScreen;
    delete m_actionClose;
    delete m_menuWindow;

    delete m_actionWebsite;
    delete m_actionIssueTracker;
    delete m_actionReleaseNotes;
    delete m_menuHelp;
}

/* ************************************************************************** */
/* ************************************************************************** */

void MenubarManager::setupMenubar(QQuickWindow *view, DeviceManager *dm,
                                  SpectrumSource *ubertooth, SpectrumSource *rtlsdr)
{
    if (!view || !dm)
    {
        qWarning() << "MenubarManager::initSettings() no QQuickWindow or DeviceManager passed";
        return;
    }

    m_saved_devicemanager = dm;
    m_saved_view = view;
    m_saved_ubertooth = ubertooth;
    m_saved_rtlsdr = rtlsdr;

    QMenuBar *menuBar = new QMenuBar(nullptr);

    // Merged into macOS app menu

    m_actionAbout = new QAction(tr("About toolBLEx"));
    m_actionAbout->setMenuRole(QAction::AboutRole);
    connect(m_actionAbout, &QAction::triggered, this, &MenubarManager::about);

    m_actionSettings = new QAction(tr("Show settings"));
    m_actionSettings->setMenuRole(QAction::PreferencesRole);
    connect(m_actionSettings, &QAction::triggered, this, &MenubarManager::settings);

    // File menu

    m_actionExport = new QAction(tr("Export scan results..."));
    m_actionExport->setShortcut(QKeySequence(QKeySequence::Save));
    connect(m_actionExport, &QAction::triggered, this, &MenubarManager::fileExport);

    m_actionClear = new QAction(tr("Clear scan results"));
    m_actionClear->setShortcut(QKeySequence(QStringLiteral("Ctrl+K")));
    connect(m_actionClear, &QAction::triggered, this, &MenubarManager::fileClear);

    m_menuFile = new QMenu(tr("File"));
    m_menuFile->addAction(m_actionExport);
    m_menuFile->addAction(m_actionClear);
    menuBar->addMenu(m_menuFile);

    connect(m_menuFile, &QMenu::aboutToShow, this, &MenubarManager::updateFileActions);
    connect(m_menuFile, &QMenu::aboutToHide, this, &MenubarManager::unlockMenusShortcuts);

    // Devices menu

    m_actionSensorList = new QAction(tr("Show device list"));
    m_actionScanStart = new QAction(tr("Start scanning"));
    m_actionScanStop = new QAction(tr("Stop scanning"));
    m_actionDisconnect = new QAction(tr("Disconnect all"));

    m_actionScanStart->setShortcuts({QKeySequence(QKeySequence::Refresh), QKeySequence(QStringLiteral("Ctrl+F5"))});
    m_actionScanStop->setShortcut(QKeySequence(QStringLiteral("Ctrl+.")));

    connect(m_actionSensorList, &QAction::triggered, this, &MenubarManager::sensorList);
    connect(m_actionScanStart, &QAction::triggered, this, &MenubarManager::scanStart);
    connect(m_actionScanStop, &QAction::triggered, this, &MenubarManager::scanStop);
    connect(m_actionDisconnect, &QAction::triggered, this, &MenubarManager::devicesDisconnect);

    m_menuSensors = new QMenu(tr("Devices"));
    m_menuSensors->addAction(m_actionSensorList);
    m_menuSensors->addSeparator();
    m_menuSensors->addAction(m_actionScanStart);
    m_menuSensors->addAction(m_actionScanStop);
    m_menuSensors->addSeparator();
    m_menuSensors->addAction(m_actionDisconnect);
    menuBar->addMenu(m_menuSensors);

    connect(m_menuSensors, &QMenu::aboutToShow, this, &MenubarManager::updateDeviceActions);
    connect(m_menuSensors, &QMenu::aboutToHide, this, &MenubarManager::unlockMenusShortcuts);

    // View menu

    m_actionViewScanner = new QAction(tr("Scanner"));
    m_actionViewAdvertiser = new QAction(tr("Advertiser"));
    m_actionViewUbertooth = new QAction(tr("Ubertooth"));
    m_actionViewRtlsdr = new QAction(tr("RTL-SDR"));

    m_actionViewScanner->setCheckable(true);
    m_actionViewAdvertiser->setCheckable(true);
    m_actionViewUbertooth->setCheckable(true);
    m_actionViewRtlsdr->setCheckable(true);

    m_actionViewScanner->setShortcut(QKeySequence(QStringLiteral("Ctrl+1")));
    m_actionViewAdvertiser->setShortcut(QKeySequence(QStringLiteral("Ctrl+2")));
    m_actionViewUbertooth->setShortcut(QKeySequence(QStringLiteral("Ctrl+3")));
    m_actionViewRtlsdr->setShortcut(QKeySequence(QStringLiteral("Ctrl+4")));

    connect(m_actionViewScanner, &QAction::triggered, this, [this]() { showWindow(); Q_EMIT viewClicked(0); });
    connect(m_actionViewAdvertiser, &QAction::triggered, this, [this]() { showWindow(); Q_EMIT viewClicked(1); });
    connect(m_actionViewUbertooth, &QAction::triggered, this, [this]() { showWindow(); Q_EMIT viewClicked(2); });
    connect(m_actionViewRtlsdr, &QAction::triggered, this, [this]() { showWindow(); Q_EMIT viewClicked(3); });

#if defined(QT_NO_DEBUG) || defined(NDEBUG)
    // The advertiser screen is only visible in debug builds for noow
    m_actionViewAdvertiser->setVisible(false);
    m_actionViewAdvertiser->setEnabled(false);
#endif

    m_menuView = new QMenu(tr("View"));
    m_menuView->addAction(m_actionViewScanner);
    m_menuView->addAction(m_actionViewAdvertiser);
    m_menuView->addAction(m_actionViewUbertooth);
    m_menuView->addAction(m_actionViewRtlsdr);

    // "Sort by" submenu, for the device list content
    m_menuSort = new QMenu(tr("Sort by"));
    connect(m_menuSort->addAction(tr("Default")),      &QAction::triggered, dm, &DeviceManager::orderby_default);
    connect(m_menuSort->addAction(tr("Address")),      &QAction::triggered, dm, &DeviceManager::orderby_address);
    connect(m_menuSort->addAction(tr("Name")),         &QAction::triggered, dm, &DeviceManager::orderby_name);
    connect(m_menuSort->addAction(tr("Model")),        &QAction::triggered, dm, &DeviceManager::orderby_model);
    connect(m_menuSort->addAction(tr("Manufacturer")), &QAction::triggered, dm, &DeviceManager::orderby_manufacturer);
    connect(m_menuSort->addAction(tr("RSSI")),         &QAction::triggered, dm, &DeviceManager::orderby_rssi);
    connect(m_menuSort->addAction(tr("Interval")),     &QAction::triggered, dm, &DeviceManager::orderby_interval);
    connect(m_menuSort->addAction(tr("First seen")),   &QAction::triggered, dm, &DeviceManager::orderby_firstseen);
    connect(m_menuSort->addAction(tr("Last seen")),    &QAction::triggered, dm, &DeviceManager::orderby_lastseen);

    m_menuView->addSeparator();
    m_menuView->addMenu(m_menuSort);
    m_menuView->addSeparator();
    // enter fullscreen will be added automatically at the end of the view menu
    menuBar->addMenu(m_menuView);

    updateViewActions();

    // Window menu

    m_actionMinimize = new QAction(tr("Minimize"));
    m_actionMaximize = new QAction(tr("Zoom"));
    m_actionFullScreen = new QAction(tr("Enter Full Screen"));
    m_actionClose = new QAction(tr("Close window"));

    m_actionMinimize->setShortcut(QKeySequence(QStringLiteral("Ctrl+M")));
    m_actionFullScreen->setShortcut(QKeySequence(QKeySequence::FullScreen));
    m_actionClose->setShortcut(QKeySequence(QKeySequence::Close));

    connect(m_actionMinimize, &QAction::triggered, this, &MenubarManager::windowMinimize);
    connect(m_actionMaximize, &QAction::triggered, this, &MenubarManager::windowMaximize);
    connect(m_actionFullScreen, &QAction::triggered, this, &MenubarManager::windowFullScreen);
    connect(m_actionClose, &QAction::triggered, this, &MenubarManager::windowClose);

    m_menuWindow = new QMenu(tr("Window"));
    m_menuWindow->addAction(m_actionMinimize);
    m_menuWindow->addAction(m_actionMaximize);
    m_menuWindow->addSeparator();
    m_menuWindow->addAction(m_actionFullScreen);
    m_menuWindow->addSeparator();
    m_menuWindow->addAction(m_actionClose);
    menuBar->addMenu(m_menuWindow);

    connect(m_saved_view, &QWindow::visibilityChanged, this, &MenubarManager::updateWindowActions);
    updateWindowActions();

    m_actionWebsite = new QAction(tr("Visit website"));
    m_actionIssueTracker = new QAction(tr("Visit issue tracker"));
    m_actionReleaseNotes = new QAction(tr("Consult release notes"));

    connect(m_actionWebsite, &QAction::triggered, this, &MenubarManager::website);
    connect(m_actionIssueTracker, &QAction::triggered, this, &MenubarManager::issuetracker);
    connect(m_actionReleaseNotes, &QAction::triggered, this, &MenubarManager::releasenotes);

    m_menuHelp = new QMenu(tr("Help"));
    m_menuHelp->addAction(m_actionAbout);
    m_menuHelp->addAction(m_actionSettings);
    m_menuHelp->addAction(m_actionWebsite);
    m_menuHelp->addAction(m_actionIssueTracker);
    m_menuHelp->addAction(m_actionReleaseNotes);
    menuBar->addMenu(m_menuHelp);
}

/* ************************************************************************** */

void MenubarManager::unlockMenusShortcuts()
{
    // Re-enable the shortcut-bearing actions when the menu closes, so they keep working while the menus are hidden

    if (m_actionExport) m_actionExport->setEnabled(true);
    if (m_actionClear) m_actionClear->setEnabled(true);

    if (m_actionScanStart) m_actionScanStart->setEnabled(true);
    if (m_actionScanStop) m_actionScanStop->setEnabled(true);
}

void MenubarManager::updateFileActions()
{
    if (!m_saved_devicemanager) return;

    const bool hasResults = (m_saved_devicemanager->property("deviceCountShown").toInt() > 0);

    if (m_actionExport) m_actionExport->setEnabled(hasResults);
    if (m_actionClear) m_actionClear->setEnabled(hasResults);
}

void MenubarManager::updateDeviceActions()
{
    if (!m_saved_devicemanager) return;

    const bool bluetoothReady = m_saved_devicemanager->property("bluetooth").toBool();
    const bool scanning = m_saved_devicemanager->property("scanning").toBool();
    const bool connected = m_saved_devicemanager->areDevicesConnected();

    if (m_actionScanStart) m_actionScanStart->setEnabled(bluetoothReady && !scanning);
    if (m_actionScanStop) m_actionScanStop->setEnabled(scanning);
    if (m_actionDisconnect) m_actionDisconnect->setEnabled(connected);
}

void MenubarManager::updateViewActions()
{
    // Checkmark on the active screen
    if (m_actionViewScanner) m_actionViewScanner->setChecked(m_currentView == 0);
    if (m_actionViewAdvertiser) m_actionViewAdvertiser->setChecked(m_currentView == 1);
    if (m_actionViewUbertooth) m_actionViewUbertooth->setChecked(m_currentView == 2);
    if (m_actionViewRtlsdr) m_actionViewRtlsdr->setChecked(m_currentView == 3);
/*
    if (m_actionViewUbertooth && m_saved_ubertooth)
        m_actionViewUbertooth->setEnabled(m_saved_ubertooth->areToolsAvailable());
    if (m_actionViewRtlsdr && m_saved_rtlsdr)
        m_actionViewRtlsdr->setEnabled(m_saved_rtlsdr->areToolsAvailable());
*/
}

void MenubarManager::setCurrentView(int screen)
{
    m_currentView = screen;
    updateViewActions();
}

void MenubarManager::updateWindowActions()
{
    if (!m_saved_view) return;

    const QWindow::Visibility v = m_saved_view->visibility();

    // Remember the last state (Windowed or Maximized) so we can restore it when leaving full screen
    if (v != QWindow::FullScreen && v != QWindow::Minimized && v != QWindow::Hidden)
    {
        m_previousVisibility = v;
    }

    if (m_actionFullScreen)
    {
        m_actionFullScreen->setText(v == QWindow::FullScreen ? tr("Exit Full Screen") : tr("Enter Full Screen"));
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

void MenubarManager::about()
{
    showWindow();
    Q_EMIT aboutClicked();
}

void MenubarManager::settings()
{
    showWindow();
    Q_EMIT settingsClicked();
}

/* ************************************************************************** */

void MenubarManager::fileExport()
{
    if (!m_saved_devicemanager) return;
    if (m_saved_devicemanager->property("deviceCountShown").toInt() <= 0) return;

    showWindow();
    Q_EMIT exportClicked();
}

void MenubarManager::fileClear()
{
    if (!m_saved_devicemanager) return;
    if (m_saved_devicemanager->property("deviceCountShown").toInt() <= 0) return;

    m_saved_devicemanager->clearResults();
}

/* ************************************************************************** */

void MenubarManager::sensorList()
{
    showWindow();
    Q_EMIT sensorsClicked();
}

void MenubarManager::scanStart()
{
    if (!m_saved_devicemanager) return;

    const bool bluetoothReady = m_saved_devicemanager->property("bluetooth").toBool();
    const bool scanning = m_saved_devicemanager->property("scanning").toBool();
    if (bluetoothReady && !scanning) m_saved_devicemanager->scanDevices_start();
}

void MenubarManager::scanStop()
{
    if (!m_saved_devicemanager) return;

    if (m_saved_devicemanager->property("scanning").toBool()) m_saved_devicemanager->scanDevices_stop();
}

void MenubarManager::devicesDisconnect()
{
    if (m_saved_devicemanager && m_saved_devicemanager->areDevicesConnected())
        m_saved_devicemanager->disconnectDevices();
}

/* ************************************************************************** */

void MenubarManager::windowMinimize()
{
    if (m_saved_view) m_saved_view->setVisibility(QWindow::Minimized);
}

void MenubarManager::windowMaximize()
{
    if (!m_saved_view) return;

    // Toggle, matching the behavior of the macOS "Zoom" action
    if (m_saved_view->visibility() == QWindow::Maximized)
    {
        m_saved_view->setVisibility(QWindow::Windowed);
    }
    else
    {
        m_saved_view->setVisibility(QWindow::Maximized);
    }
}

void MenubarManager::windowFullScreen()
{
    if (!m_saved_view) return;

    if (m_saved_view->visibility() == QWindow::FullScreen)
    {
        // Restore the pre-fullscreen state
        m_saved_view->setVisibility(m_previousVisibility);
    }
    else
    {
        m_saved_view->setVisibility(QWindow::FullScreen);
    }
}

void MenubarManager::showWindow()
{
    // Only show() if the window is actually hidden/minimized
    if (!m_saved_view->isVisible() || m_saved_view->visibility() == QWindow::Minimized)
    {
        m_saved_view->show();
    }
    m_saved_view->raise();
    m_saved_view->requestActivate();
}

void MenubarManager::windowClose()
{
    if (m_saved_view) m_saved_view->close();
}

/* ************************************************************************** */

void MenubarManager::website()
{
    QDesktopServices::openUrl(QUrl("https://emeric.io/toolBLEx"));
}

void MenubarManager::issuetracker()
{
    QDesktopServices::openUrl(QUrl("https://github.com/emericg/toolBLEx/issues"));
}

void MenubarManager::releasenotes()
{
    QDesktopServices::openUrl(QUrl("https://github.com/emericg/toolBLEx/releases"));
}

/* ************************************************************************** */
/* ************************************************************************** */
