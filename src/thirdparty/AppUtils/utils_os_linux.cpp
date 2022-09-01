/*!
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
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2021
 */

#include "utils_os_linux.h"

#if defined(Q_OS_LINUX)

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDebug>

#define MAX_SERVICES 4

/* ************************************************************************** */

uint32_t UtilsLinux::screenKeepOn(const QString &application, const QString &reason)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    if (bus.isConnected())
    {
        QString services[MAX_SERVICES] = {
            "org.freedesktop.ScreenSaver",
            "org.kde.ScreenSaver"
            "org.gnome.ScreenSaver"
            "org.gnome.SessionManager"
        };
        QString paths[MAX_SERVICES] = {
            "/org/freedesktop/ScreenSaver",
            "/org/kde/ScreenSaver"
            "/org/gnome/ScreenSaver"
            "/org/gnome/SessionManager"
        };

        for (int i = 0; i < MAX_SERVICES ; i++)
        {
            QDBusInterface screenSaverInterface(services[i], paths[i], services[i], bus);
            if (!screenSaverInterface.isValid()) continue;

            QDBusReply<uint> reply = screenSaverInterface.call("Inhibit", application, reason);
            if (reply.isValid())
            {
                //qDebug() << "screenKeepOn() succesful:" << reply << " from " << services[i];
                return reply.value();
            }
            else
            {
                QDBusError error = reply.error();
                qWarning() << "screenKeepOn() error:" << error.message() << error.name();
            }
        }
    }

    return 0;
}

void UtilsLinux::screenKeepAuto(uint32_t screensaverId)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    if (bus.isConnected())
    {
        QString services[MAX_SERVICES] = {
            "org.freedesktop.ScreenSaver",
            "org.kde.ScreenSaver"
            "org.gnome.ScreenSaver"
            "org.gnome.SessionManager"
        };
        QString paths[MAX_SERVICES] = {
            "/org/freedesktop/ScreenSaver",
            "/org/kde/ScreenSaver"
            "/org/gnome/ScreenSaver"
            "/org/gnome/SessionManager"
        };

        for (int i = 0; i < MAX_SERVICES ; i++)
        {
            QDBusInterface screenSaverInterface(services[i], paths[i], services[i], bus, nullptr);
            if (!screenSaverInterface.isValid()) continue;

            QDBusReply<uint> reply = screenSaverInterface.call("UnInhibit", screensaverId);
            if (reply.isValid())
            {
                //qDebug() << "screenKeepAuto() succesful:" << reply << " from " << reply.value();
                break;
            }
            else
            {
                QDBusError error = reply.error();
                qWarning() << "screenKeepAuto() error:" << error.message() << error.name();
            }
        }
    }
}

/* ************************************************************************** */
#endif // Q_OS_LINUX
