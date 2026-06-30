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

#include "DatabaseManager.h"
#include "VendorsDatabase.h"

#include "SettingsManager.h"
#include "MenubarManager.h"
#include "DeviceManager.h"
#include "device_utils.h"

#include "rtlsdr.h"
#include "ubertooth.h"

#include "utils_language.h"
#if defined(Q_OS_MACOS)
#include "utils_os_macos_dock.h"
#endif

#include <SingleApplication.h>

#include <QtGlobal>
#include <QLibraryInfo>
#include <QVersionNumber>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    // Hacks ///////////////////////////////////////////////////////////////////

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    // Qt 6.6+ mouse wheel hack
    qputenv("QT_QUICK_FLICKABLE_WHEEL_DECELERATION", "7500");
#endif

    // Allow macOS (and patched Qt for BlueZ) to report ALL advertising packets
    //qputenv("QT_BLUETOOTH_SCAN_ENABLE_DUPLICATES", "1");

    // GUI application /////////////////////////////////////////////////////////

    SingleApplication app(argc, argv, false);

    // Application name
    app.setApplicationName("toolBLEx");
    app.setApplicationDisplayName("toolBLEx");
    app.setOrganizationName("toolBLEx");
    app.setOrganizationDomain("toolBLEx");

    // Application icon
    QIcon appIcon(":/assets/gfx/logos/icon.svg");
    app.setWindowIcon(appIcon);

    // Init app components
    VendorsDatabase::getInstance();
    DatabaseManager::getInstance();

    // Init app components
    SettingsManager *sm = SettingsManager::getInstance();
    MenubarManager *mb = MenubarManager::getInstance();
    DeviceManager *dm = new DeviceManager;
    if (!sm || !mb || !dm)
    {
        qWarning() << "Cannot init toolBLEx components!";
        return EXIT_FAILURE;
    }

    Ubertooth *ubertooth = new Ubertooth;
    RtlSdr *rtlsdr = new RtlSdr;
    if (!ubertooth || !rtlsdr)
    {
        qWarning() << "Cannot init toolBLEx spectrum analyzers!";
    }

    // Start scanning?
    if (sm->getScanAuto())
    {
        dm->scanDevices_start();
    }

    // Init generic utils
    UtilsLanguage *utilsLanguage = UtilsLanguage::getInstance();
    if (!utilsLanguage)
    {
        qWarning() << "Cannot init toolBLEx utils!";
        return EXIT_FAILURE;
    }

    DeviceUtils::registerQML();

    // Translate the application
    utilsLanguage->loadLanguage(sm->getAppLanguage());

    // Start the application
    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();

    engine_context->setContextProperty("deviceManager", dm);
    engine_context->setContextProperty("ubertooth", ubertooth);
    engine_context->setContextProperty("rtlsdr", rtlsdr);

    // Load the main view
    engine.loadFromModule("toolBLEx", "DesktopApplication");

    if (engine.rootObjects().isEmpty())
    {
        qWarning() << "Cannot init QmlApplicationEngine!";
        return EXIT_FAILURE;
    }

    // For i18n retranslate
    utilsLanguage->setQmlEngine(&engine);

    // QQuickWindow must be valid at this point
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));

    // React to secondary instances
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::show);
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::raise);

    // Menu bar
    mb->setupMenubar(window, dm);

#if defined(Q_OS_MACOS)
    // macOS dock
    MacOSDockHandler *dockIconHandler = MacOSDockHandler::getInstance();
    dockIconHandler->setupDock(window);
    engine_context->setContextProperty("utilsDock", dockIconHandler);
#endif

    return app.exec();
}

/* ************************************************************************** */
