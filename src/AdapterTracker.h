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

#ifndef ADAPTER_TRACKER_H
#define ADAPTER_TRACKER_H
/* ************************************************************************** */

#include <QObject>
#include <QPointer>
#include <QBluetoothLocalDevice>

class Adapter;

/* ************************************************************************** */

/*!
 * \brief Follows one Adapter, reports when its device is replaced, and forwards the device signals.
 *
 * The device of an Adapter is replaced when the adapter is re-plugged,
 * the connections are moved to the new device.
 */
class AdapterTracker: public QObject
{
    Q_OBJECT

    Adapter *m_adapter = nullptr;
    QPointer <QBluetoothLocalDevice> m_device;  //!< device of m_adapter, its signals are forwarded

    /*!
     * \brief Watch the current device of the adapter, instead of the previous one.
     */
    void connectDevice();

    void adapterDeviceChanged();

Q_SIGNALS:
    /*!
     * \brief Emitted when the device of the adapter has been replaced.
     */
    void deviceChanged();

    /*!
     * \brief Emitted when the host mode of the adapter device changes.
     */
    void hostModeChanged(QBluetoothLocalDevice::HostMode state);

    /*!
     * \brief Forwarded from the adapter device, see QBluetoothLocalDevice::pairingFinished().
     */
    void pairingFinished(const QBluetoothAddress &address, QBluetoothLocalDevice::Pairing pairing);

    /*!
     * \brief Forwarded from the adapter device, see QBluetoothLocalDevice::errorOccurred().
     */
    void errorOccurred(QBluetoothLocalDevice::Error error);

public:
    explicit AdapterTracker(QObject *parent = nullptr);

    Adapter *getAdapter() const { return m_adapter; }

    /*!
     * \brief Follow another adapter.
     * \param adapter: the adapter to follow, or nullptr to stop.
     */
    void setAdapter(Adapter *adapter);
};

/* ************************************************************************** */
#endif // ADAPTER_TRACKER_H
