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

#include "AdapterManager.h"

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QHash>

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusArgument>
#include <QDBusObjectPath>
#include <QDBusError>
#endif

#include <QDebug>

/* ************************************************************************** */

QHash <quint64, QBluetoothLocalDevice::Pairing> AdapterManager::getPairedDevices_bluez(const QBluetoothAddress &adapterAddress) const
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

bool AdapterManager::startAdaptersWatcher_bluez()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    QDBusConnection bus = QDBusConnection::systemBus();

    bool added = bus.connect(QStringLiteral("org.bluez"), QStringLiteral("/"),
                             QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                             QStringLiteral("InterfacesAdded"),
                             this, SLOT(interfacesAdded_bluez(QDBusMessage)));
    bool removed = bus.connect(QStringLiteral("org.bluez"), QStringLiteral("/"),
                               QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                               QStringLiteral("InterfacesRemoved"),
                               this, SLOT(interfacesRemoved_bluez(QDBusMessage)));

    if (!added || !removed)
    {
        qWarning() << "AdapterManager::startAdaptersWatcher_bluez() unable to watch BlueZ adapters:"
                   << bus.lastError().message();
        return false;
    }

    return true;
#else
    return false;
#endif
}

void AdapterManager::interfacesAdded_bluez(const QDBusMessage &msg)
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    // InterfacesAdded(OBJPATH object_path, DICT<STRING, DICT<STRING, VARIANT>> interfaces_and_properties)
    const QList <QVariant> args = msg.arguments();
    if (args.size() < 2) return;

    bool isAdapter = false;

    const QDBusArgument arg = args.at(1).value<QDBusArgument>();
    arg.beginMap();
    while (!arg.atEnd())
    {
        QString iface;
        QVariantMap props;
        arg.beginMapEntry();
        arg >> iface >> props;
        arg.endMapEntry();

        if (iface == QLatin1String("org.bluez.Adapter1")) isAdapter = true;
    }
    arg.endMap();

    if (isAdapter)
    {
        qDebug() << "BlueZ adapter added:" << args.at(0).value<QDBusObjectPath>().path();
        m_adaptersRefreshTimer.start();
    }
#else
    Q_UNUSED(msg)
#endif
}

void AdapterManager::interfacesRemoved_bluez(const QDBusMessage &msg)
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    // InterfacesRemoved(OBJPATH object_path, ARRAY<STRING> interfaces)
    const QList <QVariant> args = msg.arguments();
    if (args.size() < 2) return;

    if (args.at(1).toStringList().contains(QLatin1String("org.bluez.Adapter1")))
    {
        qDebug() << "BlueZ adapter removed:" << args.at(0).value<QDBusObjectPath>().path();
        m_adaptersRefreshTimer.start();
    }
#else
    Q_UNUSED(msg)
#endif
}

/* ************************************************************************** */
