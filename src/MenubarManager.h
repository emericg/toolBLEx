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

#ifndef MENUBAR_MANAGER_H
#define MENUBAR_MANAGER_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>

#include <QObject>
#include <QWindow>

class QJSEngine;
class QQmlEngine;

class QMenu;
class QAction;
class QQuickWindow;

class DeviceManager;
class SpectrumSource;

/* ************************************************************************** */

/*!
 * \brief The MenubarManager class
 */
class MenubarManager: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QQuickWindow *m_saved_view = nullptr;
    DeviceManager *m_saved_devicemanager = nullptr;
    SpectrumSource *m_saved_ubertooth = nullptr;
    SpectrumSource *m_saved_rtlsdr = nullptr;

    QAction *m_actionAbout = nullptr;
    QAction *m_actionSettings = nullptr;

    QMenu *m_menuFile = nullptr;
    QAction *m_actionExport = nullptr;
    QAction *m_actionClear = nullptr;

    QMenu *m_menuSensors = nullptr;
    QAction *m_actionSensorList = nullptr;
    QAction *m_actionScanStart = nullptr;
    QAction *m_actionScanStop = nullptr;
    QAction *m_actionDisconnect = nullptr;

    QMenu *m_menuView = nullptr;
    QAction *m_actionViewScanner = nullptr;
    QAction *m_actionViewAdvertiser = nullptr;
    QAction *m_actionViewUbertooth = nullptr;
    QAction *m_actionViewRtlsdr = nullptr;
    QMenu *m_menuSort = nullptr;

    int m_currentView = -1; //!< UI screen currently shown, for the View menu checkmark

    QMenu *m_menuWindow = nullptr;
    QAction *m_actionMinimize = nullptr;
    QAction *m_actionMaximize = nullptr;
    QAction *m_actionFullScreen = nullptr;
    QAction *m_actionClose = nullptr;

    QWindow::Visibility m_previousVisibility = QWindow::Windowed; //!< state to restore when leaving full screen

    QMenu *m_menuHelp = nullptr;
    QAction *m_actionWebsite = nullptr;
    QAction *m_actionIssueTracker = nullptr;
    QAction *m_actionReleaseNotes = nullptr;

    void showWindow();

    // Singleton
    explicit MenubarManager(QObject *parent = nullptr);
    ~MenubarManager();

signals:
    void sensorsClicked();
    void settingsClicked();
    void aboutClicked();
    void exportClicked();
    void viewClicked(int screen);

public:
    static MenubarManager *getInstance();
    static MenubarManager *create(QQmlEngine *, QJSEngine *);

    void setupMenubar(QQuickWindow *view, DeviceManager *dm,
                      SpectrumSource *ubertooth, SpectrumSource *rtlsdr);

    Q_INVOKABLE void setCurrentView(int screen);

private slots:
    void unlockMenusShortcuts();
    void updateFileActions();
    void updateDeviceActions();
    void updateViewActions();
    void updateWindowActions();
    void about();
    void settings();
    void fileExport();
    void fileClear();
    void sensorList();
    void scanStart();
    void scanStop();
    void devicesDisconnect();
    void windowMinimize();
    void windowMaximize();
    void windowFullScreen();
    void windowClose();
    void website();
    void issuetracker();
    void releasenotes();
};

/* ************************************************************************** */
#endif // MENUBAR_MANAGER_H
