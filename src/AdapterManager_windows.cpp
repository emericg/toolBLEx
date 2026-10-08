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

// C++/WinRT headers first, to avoid clashes with Qt macros
#if defined(_WIN32)
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Devices.Enumeration.h>
#include <winrt/Windows.Devices.Bluetooth.h>

#include <mutex>
#endif

#include "AdapterManager.h"

#include <QDebug>

/* ************************************************************************** */

#if defined(Q_OS_WINDOWS)

using namespace winrt::Windows::Devices::Enumeration;
using namespace winrt::Windows::Devices::Bluetooth;
using WinRtInspectable = winrt::Windows::Foundation::IInspectable;

/*!
 * \brief State shared with the DeviceWatcher callbacks, which are called from other threads.
 */
struct AdaptersWatcherWindows
{
    DeviceWatcher watcher { nullptr };
    winrt::event_token addedToken;
    winrt::event_token removedToken;
    winrt::event_token updatedToken;
    winrt::event_token enumerationToken;

    std::mutex mutex;
    AdapterManager *owner = nullptr;    //!< null once stopped
    bool enumerated = false;            //!< the initial enumeration reports the adapters already known

    void enumerationCompleted()
    {
        std::lock_guard lock(mutex);
        enumerated = true;
    }

    void adaptersChanged()
    {
        std::lock_guard lock(mutex);
        if (!owner || !enumerated) return;

        // Events posted to a deleted object are discarded
        AdapterManager *am = owner;
        QMetaObject::invokeMethod(am, [am]() { am->m_adaptersRefreshTimer.start(); }, Qt::QueuedConnection);
    }
};

#endif // defined(Q_OS_WINDOWS)

/* ************************************************************************** */

bool AdapterManager::startAdaptersWatcher_windows()
{
#if defined(Q_OS_WINDOWS)
    try
    {
        auto state = std::make_shared<AdaptersWatcherWindows>();
        state->owner = this;
        state->watcher = DeviceInformation::CreateWatcher(BluetoothAdapter::GetDeviceSelector());

        // Callbacks keep the state alive, until they are revoked
        state->addedToken = state->watcher.Added(
            [state](const DeviceWatcher &, const DeviceInformation &) { state->adaptersChanged(); });
        state->removedToken = state->watcher.Removed(
            [state](const DeviceWatcher &, const DeviceInformationUpdate &) { state->adaptersChanged(); });
        state->enumerationToken = state->watcher.EnumerationCompleted(
            [state](const DeviceWatcher &, const WinRtInspectable &) { state->enumerationCompleted(); });

        // Added and Removed are only raised after the initial enumeration if Updated is handled too
        state->updatedToken = state->watcher.Updated(
            [](const DeviceWatcher &, const DeviceInformationUpdate &) {});

        state->watcher.Start();

        m_adaptersWatcher_windows = state;
        return true;
    }
    catch (const winrt::hresult_error &e)
    {
        qWarning() << "AdapterManager::startAdaptersWatcher_windows() unable to watch Windows adapters:"
                   << QString::fromWCharArray(e.message().c_str());
        return false;
    }
#else
    return false;
#endif
}

void AdapterManager::stopAdaptersWatcher_windows()
{
#if defined(Q_OS_WINDOWS)
    if (!m_adaptersWatcher_windows) return;

    std::shared_ptr <AdaptersWatcherWindows> state = std::move(m_adaptersWatcher_windows);
    {
        std::lock_guard lock(state->mutex);
        state->owner = nullptr;
    }

    try
    {
        state->watcher.Added(state->addedToken);
        state->watcher.Removed(state->removedToken);
        state->watcher.Updated(state->updatedToken);
        state->watcher.EnumerationCompleted(state->enumerationToken);

        const DeviceWatcherStatus status = state->watcher.Status();
        if (status == DeviceWatcherStatus::Started || status == DeviceWatcherStatus::EnumerationCompleted)
        {
            state->watcher.Stop();
        }
    }
    catch (const winrt::hresult_error &e)
    {
        qWarning() << "AdapterManager::stopAdaptersWatcher_windows() error:"
                   << QString::fromWCharArray(e.message().c_str());
    }
#endif
}

/* ************************************************************************** */
