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

#include "AdapterManager_bluez.h"
#include "BluezTypes.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusArgument>
#include <QDBusObjectPath>
#include <QDBusError>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDBusServiceWatcher>

#include <QDebug>

/* ************************************************************************** */

AdapterManagerBluez::AdapterManagerBluez(QObject *parent) : QObject(parent)
{
    registerBluezTypes();
}

/* ************************************************************************** */

bool AdapterManagerBluez::watchAdapters()
{
    QDBusConnection bus = QDBusConnection::systemBus();

    bool added = bus.connect(QStringLiteral("org.bluez"), QStringLiteral("/"),
                             QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                             QStringLiteral("InterfacesAdded"),
                             this, SLOT(interfacesAdded(QDBusMessage)));
    bool removed = bus.connect(QStringLiteral("org.bluez"), QStringLiteral("/"),
                               QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                               QStringLiteral("InterfacesRemoved"),
                               this, SLOT(interfacesRemoved(QDBusMessage)));

    if (!added || !removed)
    {
        qWarning() << "AdapterManagerBluez::watchAdapters() unable to watch BlueZ adapters:"
                   << bus.lastError().message();
        return false;
    }

    // bluetoothd going away doesn't remove its adapters through InterfacesRemoved
    QDBusServiceWatcher *serviceWatcher = new QDBusServiceWatcher(QStringLiteral("org.bluez"), bus,
                                                                  QDBusServiceWatcher::WatchForOwnerChange, this);
    connect(serviceWatcher, &QDBusServiceWatcher::serviceOwnerChanged, this, [this]() {
        qDebug() << "BlueZ service restarted or stopped";
        Q_EMIT adaptersChanged();
    });

    return true;
}

void AdapterManagerBluez::interfacesAdded(const QDBusMessage &msg)
{
    // InterfacesAdded(OBJPATH object_path, DICT<STRING, DICT<STRING, VARIANT>> interfaces_and_properties)
    const QList <QVariant> args = msg.arguments();
    if (args.size() < 2) return;

    const InterfaceList interfaces = qdbus_cast<InterfaceList>(args.at(1));
    if (interfaces.contains(QStringLiteral("org.bluez.Adapter1")))
    {
        qDebug() << "BlueZ adapter added:" << args.at(0).value<QDBusObjectPath>().path();
        Q_EMIT adaptersChanged();
    }
}

void AdapterManagerBluez::interfacesRemoved(const QDBusMessage &msg)
{
    // InterfacesRemoved(OBJPATH object_path, ARRAY<STRING> interfaces)
    const QList <QVariant> args = msg.arguments();
    if (args.size() < 2) return;

    if (args.at(1).toStringList().contains(QLatin1String("org.bluez.Adapter1")))
    {
        qDebug() << "BlueZ adapter removed:" << args.at(0).value<QDBusObjectPath>().path();
        Q_EMIT adaptersChanged();
    }
}

/* ************************************************************************** */

void AdapterManagerBluez::queryPairedDevices(const QBluetoothAddress &adapterAddress)
{
    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.bluez"), QStringLiteral("/"),
                                                      QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                                                      QStringLiteral("GetManagedObjects"));

    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(QDBusConnection::systemBus().asyncCall(msg), this);
    watcher->setProperty("adapterAddress", adapterAddress.toUInt64());
    connect(watcher, &QDBusPendingCallWatcher::finished, this, &AdapterManagerBluez::pairedDevicesReply);
}

void AdapterManagerBluez::pairedDevicesReply(QDBusPendingCallWatcher *call)
{
    call->deleteLater();

    const QBluetoothAddress adapterAddress(call->property("adapterAddress").toULongLong());
    QHash <quint64, QBluetoothLocalDevice::Pairing> paired;

    QDBusPendingReply <ManagedObjectList> reply = *call;
    if (reply.isError())
    {
        qWarning() << "AdapterManagerBluez::pairedDevicesReply() GetManagedObjects failed:" << reply.error().message();
        Q_EMIT pairedDevicesUpdated(adapterAddress, paired);
        return;
    }

    const ManagedObjectList objects = reply.value();

    // Find the adapter object
    QString adapterPath;
    for (auto it = objects.cbegin(); it != objects.cend(); ++it)
    {
        if (!it.value().contains(QStringLiteral("org.bluez.Adapter1"))) continue;

        const QVariantMap adapter = it.value().value(QStringLiteral("org.bluez.Adapter1"));
        if (QBluetoothAddress(adapter.value(QStringLiteral("Address")).toString()) == adapterAddress)
        {
            adapterPath = it.key().path() + QChar('/');
            break;
        }
    }

    // Then its paired devices
    if (!adapterPath.isEmpty())
    {
        for (auto it = objects.cbegin(); it != objects.cend(); ++it)
        {
            if (!it.key().path().startsWith(adapterPath)) continue;

            const QVariantMap device = it.value().value(QStringLiteral("org.bluez.Device1"));
            if (!device.value(QStringLiteral("Paired")).toBool()) continue;

            QBluetoothAddress addr(device.value(QStringLiteral("Address")).toString());
            if (addr.isNull()) continue;

            paired.insert(addr.toUInt64(), device.value(QStringLiteral("Trusted")).toBool() ?
                                               QBluetoothLocalDevice::AuthorizedPaired :
                                               QBluetoothLocalDevice::Paired);
        }
    }

    Q_EMIT pairedDevicesUpdated(adapterAddress, paired);
}

/* ************************************************************************** */
