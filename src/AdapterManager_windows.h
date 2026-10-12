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

#ifndef ADAPTER_MANAGER_WINDOWS_H
#define ADAPTER_MANAGER_WINDOWS_H
/* ************************************************************************** */

#include <QObject>

#include <memory>

/* ************************************************************************** */

/*!
 * \brief Windows side of AdapterManager, Windows only.
 *
 * Watches Windows for adapters being plugged or unplugged.
 */
class AdapterManagerWindows: public QObject
{
    Q_OBJECT

    struct State;
    std::shared_ptr <State> m_state;    //!< shared with the DeviceWatcher callbacks, null when not watching

Q_SIGNALS:
    /*!
     * \brief Emitted when an adapter has been plugged or unplugged.
     *
     * The initial enumeration also reports the adapters already known.
     */
    void adaptersChanged();

public:
    explicit AdapterManagerWindows(QObject *parent = nullptr);

    /*!
     * \brief Stop watching adapters, the callbacks will not reach this object anymore.
     */
    ~AdapterManagerWindows();

    /*!
     * \brief Watch Windows for adapters being plugged or unplugged.
     * \return true if adapters are watched.
     *
     * Uses a WinRT DeviceWatcher on BluetoothAdapter::GetDeviceSelector(),
     * the same selector QBluetoothLocalDevice::allDevices() enumerates.
     */
    bool watchAdapters();
};

/* ************************************************************************** */
#endif // ADAPTER_MANAGER_WINDOWS_H
