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

#ifndef ADAPTER_INFO_BLUEZ_H
#define ADAPTER_INFO_BLUEZ_H
/* ************************************************************************** */

#include "AdapterInfo.h"

#include <QVariantMap>

class QDBusMessage;
class QDBusPendingCallWatcher;
class QProcess;

/* ************************************************************************** */

/*!
 * \brief Linux (BlueZ) adapter information backend.
 *
 * Sources:
 * - BlueZ D-Bus, system bus: org.bluez.Adapter1 and org.bluez.LEAdvertisingManager1 properties,
 *   kept up to date through PropertiesChanged, InterfacesAdded and InterfacesRemoved.
 * - sysfs: USB vendor and product IDs of the controller.
 * - `btmgmt info`, when the tool is installed: mgmt supported settings,
 *   and core version and manufacturer when bluetoothd does not export them.
 *
 * The adapter object is matched by address, hciX names do not follow Qt's adapter order.
 * Details are kept when the adapter disappears (unplugged), and refreshed when it comes back.
 */
class AdapterInfoBluez: public AdapterInfo
{
    Q_OBJECT

    QString m_path;                 //!< BlueZ adapter object path, ex: "/org/bluez/hci0"
    QVariantMap m_adapterProps;     //!< org.bluez.Adapter1 properties
    QVariantMap m_advertisingProps; //!< org.bluez.LEAdvertisingManager1 properties
    QString m_usbId;

    int m_mgmtVersion = -1;
    int m_mgmtManufacturer = -1;
    QStringList m_mgmtSettings;

    bool m_watching = false;        //!< ObjectManager signals connected
    QDBusPendingCallWatcher *m_objectsCall = nullptr;
    QProcess *m_btmgmt = nullptr;

    /*!
     * \brief Connect the ObjectManager InterfacesAdded / InterfacesRemoved signals, once.
     */
    void watchObjects();

    /*!
     * \brief Fetch all BlueZ objects (GetManagedObjects), and pick the adapter matching m_address.
     */
    void queryObjects();

    /*!
     * \brief Run `btmgmt info`, if installed.
     */
    void queryBtmgmt();

    /*!
     * \brief Set the adapter object, and its properties.
     * \param path: Adapter object path, empty when the adapter has disappeared.
     * \param adapterProps: org.bluez.Adapter1 properties.
     * \param advertisingProps: org.bluez.LEAdvertisingManager1 properties, empty if not present.
     *
     * Moves the PropertiesChanged connection to the new path, and reads the USB ID.
     */
    void setAdapter(const QString &path, const QVariantMap &adapterProps,
                    const QVariantMap &advertisingProps);

    /*!
     * \brief Read the USB vendor and product IDs of the controller, from sysfs.
     *
     * /sys/class/bluetooth/hciX/device links to the USB interface,
     * idVendor and idProduct are in its parent (the USB device).
     * Left empty for UART and SDIO controllers.
     */
    void readUsbId();

    /*!
     * \brief Parse the `btmgmt info` output, for the controller matching m_address.
     * \param output: Standard output of `btmgmt info`.
     */
    void parseBtmgmt(const QString &output);

    /*!
     * \brief Build the details from all sources, and emit detailsChanged() if they changed.
     *
     * D-Bus values have priority, btmgmt fills the core version and manufacturer when missing.
     */
    void updateDetails();

private Q_SLOTS:
    void propertiesChanged(const QString &interface, const QVariantMap &changed,
                           const QStringList &invalidated);
    void interfacesAdded(const QDBusMessage &msg);
    void interfacesRemoved(const QDBusMessage &msg);

public:
    explicit AdapterInfoBluez(QObject *parent = nullptr);

    void query(const QBluetoothAddress &address) override;
};

/* ************************************************************************** */
#endif // ADAPTER_INFO_BLUEZ_H
