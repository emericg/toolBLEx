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

#ifndef ADAPTER_INFO_WINDOWS_H
#define ADAPTER_INFO_WINDOWS_H
/* ************************************************************************** */

#include "AdapterInfo.h"

#include <memory>

struct AdapterInfoWindowsState;

/* ************************************************************************** */

/*!
 * \brief Windows adapter information backend.
 *
 * Sources, queried on a worker thread (MTA), results delivered on the owner thread:
 * - WinRT BluetoothAdapter: roles, LE / classic, secure connections, advertising capabilities, PHYs.
 * - WinRT DeviceInformation: chipset (radio device friendly name), USB ID (device instance ID).
 * - Win32 BluetoothGetRadioInfo(): local name, manufacturer, LMP subversion.
 * - Win32 IOCTL_BTH_GET_LOCAL_INFO: core version, when bthioctl.h is available at build time.
 *
 * Adapters are matched by address.
 */
class AdapterInfoWindows: public AdapterInfo
{
    Q_OBJECT

    std::shared_ptr <AdapterInfoWindowsState> m_state;  //!< shared with the worker thread
    bool m_running = false;

    /*!
     * \brief Gather the details of an adapter, blocking, on a worker thread.
     * \param address: Adapter address, as a 48 bits integer.
     * \return The details found, empty if the adapter was not found.
     */
    static AdapterDetails gather(quint64 address);

public:
    explicit AdapterInfoWindows(QObject *parent = nullptr);
    ~AdapterInfoWindows();

    void query(const QBluetoothAddress &address) override;
};

/* ************************************************************************** */
#endif // ADAPTER_INFO_WINDOWS_H
