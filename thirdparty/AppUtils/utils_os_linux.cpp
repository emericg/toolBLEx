/*!
 * Copyright (c) 2021 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
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
