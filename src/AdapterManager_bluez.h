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

#ifndef ADAPTER_MANAGER_BLUEZ_H
#define ADAPTER_MANAGER_BLUEZ_H
/* ************************************************************************** */

#include <QObject>

class QDBusMessage;

/* ************************************************************************** */

/*!
 * \brief BlueZ side of AdapterManager, Linux only.
 *
 * Watches BlueZ for adapters being plugged or unplugged.
 */
class AdapterManagerBluez: public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void interfacesAdded(const QDBusMessage &msg);
    void interfacesRemoved(const QDBusMessage &msg);

Q_SIGNALS:
    /*!
     * \brief Emitted when an adapter has been plugged or unplugged, or when bluetoothd restarted or stopped.
     */
    void adaptersChanged();

public:
    explicit AdapterManagerBluez(QObject *parent = nullptr);

    /*!
     * \brief Watch BlueZ for adapters being plugged or unplugged.
     * \return true if BlueZ is watched.
     *
     * Uses org.freedesktop.DBus.ObjectManager InterfacesAdded / InterfacesRemoved signals,
     * filtered on the org.bluez.Adapter1 interface, and the org.bluez service owner (bluetoothd restarts).
     */
    bool watchAdapters();
};

/* ************************************************************************** */
#endif // ADAPTER_MANAGER_BLUEZ_H
