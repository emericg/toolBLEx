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

#include <QDesktopServices>
#include <QQuickWindow>
#include <QMenuBar>
#include <QMenu>

/* ************************************************************************** */

MenubarManager *MenubarManager::instance = nullptr;

MenubarManager *MenubarManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new MenubarManager();
    }

    return instance;
}

MenubarManager::MenubarManager()
{
    //
}

MenubarManager::~MenubarManager()
{
    delete m_actionSensorList;
    delete m_menuSensors;

    delete m_actionAbout;
    delete m_actionWebsite;
    delete m_actionIssueTracker;
    delete m_actionReleaseNotes;
    delete m_menuHelp;
}

/* ************************************************************************** */

void MenubarManager::setupMenubar(QQuickWindow *view, DeviceManager *dm)
{
    if (!view || !dm)
    {
        qWarning() << "MenubarManager::initSettings() no QQuickWindow or DeviceManager passed";
        return;
    }

    m_saved_devicemanager = dm;
    m_saved_view = view;

    QMenuBar *menuBar = new QMenuBar(nullptr);

    m_actionSensorList = new QAction(tr("Device list"));

    connect(m_actionSensorList, &QAction::triggered, this, &MenubarManager::sensorList);

    m_menuSensors = new QMenu(tr("Devices"));
    m_menuSensors->addAction(m_actionSensorList);
    menuBar->addMenu(m_menuSensors);

    m_actionAbout = new QAction(tr("About toolBLEx"));
    m_actionWebsite = new QAction(tr("Visit website"));
    m_actionIssueTracker = new QAction(tr("Visit issue tracker"));
    m_actionReleaseNotes = new QAction(tr("Consult release notes"));

    connect(m_actionAbout, &QAction::triggered, this, &MenubarManager::about);
    connect(m_actionWebsite, &QAction::triggered, this, &MenubarManager::website);
    connect(m_actionIssueTracker, &QAction::triggered, this, &MenubarManager::issuetracker);
    connect(m_actionReleaseNotes, &QAction::triggered, this, &MenubarManager::releasenotes);

    m_menuHelp = new QMenu(tr("Help"));
    m_menuHelp->addAction(m_actionAbout);
    m_menuHelp->addSeparator();
    m_menuHelp->addAction(m_actionWebsite);
    m_menuHelp->addAction(m_actionIssueTracker);
    m_menuHelp->addAction(m_actionReleaseNotes);
    menuBar->addMenu(m_menuHelp);
}

/* ************************************************************************** */

void MenubarManager::sensorList()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT sensorsClicked();
}

void MenubarManager::settings()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT settingsClicked();
}

void MenubarManager::about()
{
    m_saved_view->show();
    m_saved_view->raise();
    Q_EMIT aboutClicked();
}

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
