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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceManager.h"

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QHash>

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusArgument>
#include <QDBusObjectPath>
#endif

/* ************************************************************************** */

QHash <quint64, QBluetoothLocalDevice::Pairing> DeviceManager::getPairedDevices_bluez(const QBluetoothAddress &adapterAddress) const
{
    QHash <quint64, QBluetoothLocalDevice::Pairing> paired;

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.bluez"), QStringLiteral("/"),
                                                      QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                                                      QStringLiteral("GetManagedObjects"));
    QDBusMessage reply = QDBusConnection::systemBus().call(msg, QDBus::Block, 2000);
    if (reply.type() != QDBusMessage::ReplyMessage || reply.arguments().isEmpty()) return paired;

    QString adapterPath;
    QList <std::pair<QString, QVariantMap>> devices;

    const QDBusArgument arg = reply.arguments().constFirst().value<QDBusArgument>();
    arg.beginMap();
    while (!arg.atEnd())
    {
        QDBusObjectPath path;
        arg.beginMapEntry();
        arg >> path;
        arg.beginMap();
        while (!arg.atEnd())
        {
            QString iface;
            QVariantMap props;
            arg.beginMapEntry();
            arg >> iface >> props;
            arg.endMapEntry();

            if (iface == QLatin1String("org.bluez.Adapter1") &&
                QBluetoothAddress(props.value(QStringLiteral("Address")).toString()) == adapterAddress)
            {
                adapterPath = path.path();
            }
            else if (iface == QLatin1String("org.bluez.Device1") &&
                     props.value(QStringLiteral("Paired")).toBool())
            {
                devices.append({path.path(), props});
            }
        }
        arg.endMap();
        arg.endMapEntry();
    }
    arg.endMap();

    for (const auto &[path, props]: std::as_const(devices))
    {
        if (!adapterPath.isEmpty() && !path.startsWith(adapterPath + QChar('/'))) continue;

        QBluetoothAddress addr(props.value(QStringLiteral("Address")).toString());
        if (addr.isNull()) continue;

        paired.insert(addr.toUInt64(), props.value(QStringLiteral("Trusted")).toBool() ?
                                           QBluetoothLocalDevice::AuthorizedPaired :
                                           QBluetoothLocalDevice::Paired);
    }
#else
    Q_UNUSED(adapterAddress)
#endif

    return paired;
}

/* ************************************************************************** */
