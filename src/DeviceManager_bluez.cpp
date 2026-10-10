/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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
#include "BluezTypes.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusError>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>

#include <QDebug>

/* ************************************************************************** */

namespace {

/*!
 * \brief Find the devices paired to an adapter, in a GetManagedObjects reply.
 * \param objects: the BlueZ objects, adapters and devices.
 * \param adapterAddress: only report devices known to this adapter.
 * \return the paired devices, by address. Empty if the adapter is unknown to BlueZ.
 */
QHash <quint64, QBluetoothLocalDevice::Pairing> pairedDevices(const ManagedObjectList &objects,
                                                              const QBluetoothAddress &adapterAddress)
{
    QHash <quint64, QBluetoothLocalDevice::Pairing> paired;

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
    if (adapterPath.isEmpty()) return paired;

    // Then its paired devices
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

    return paired;
}

} // namespace

/* ************************************************************************** */

void DeviceManager::queryPairedDevices_bluez(const QBluetoothAddress &adapterAddress)
{
    registerBluezTypes();

    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.bluez"), QStringLiteral("/"),
                                                      QStringLiteral("org.freedesktop.DBus.ObjectManager"),
                                                      QStringLiteral("GetManagedObjects"));

    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(QDBusConnection::systemBus().asyncCall(msg), this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, adapterAddress](QDBusPendingCallWatcher *call) {
        call->deleteLater();

        // Drop replies about a previous adapter
        if (!m_adapterDevice || m_adapterDevice->address() != adapterAddress) return;

        QDBusPendingReply <ManagedObjectList> reply = *call;
        if (reply.isError())
        {
            qWarning() << "DeviceManager::queryPairedDevices_bluez() GetManagedObjects failed:"
                       << reply.error().message();
            setDevicesPaired({});
            return;
        }

        setDevicesPaired(pairedDevices(reply.value(), adapterAddress));
    });
}

/* ************************************************************************** */
