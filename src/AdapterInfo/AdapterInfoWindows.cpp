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

// C++/WinRT headers first, to avoid clashes with Qt macros
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.Metadata.h>
#include <winrt/Windows.Devices.Enumeration.h>
#include <winrt/Windows.Devices.Bluetooth.h>

#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <winioctl.h>
#include <BluetoothAPIs.h>

#if __has_include(<bthioctl.h>)
#include <bthioctl.h>
#define TOOLBLEX_HAS_BTHIOCTL
#endif

#include "AdapterInfoWindows.h"
#include "AdapterInfoUtils.h"

#include <QRegularExpression>
#include <QDebug>

#include <mutex>
#include <thread>

/* ************************************************************************** */

using namespace winrt::Windows::Devices::Bluetooth;
using namespace winrt::Windows::Devices::Enumeration;
using winrt::Windows::Foundation::Metadata::ApiInformation;

/*!
 * \brief State shared with the worker thread.
 */
struct AdapterInfoWindowsState
{
    std::mutex mutex;
    AdapterInfoWindows *owner = nullptr;    //!< null once the backend is deleted
};

/* ************************************************************************** */

AdapterInfoWindows::AdapterInfoWindows(QObject *parent) : AdapterInfo(parent)
{
    m_state = std::make_shared<AdapterInfoWindowsState>();
    m_state->owner = this;
}

AdapterInfoWindows::~AdapterInfoWindows()
{
    std::lock_guard lock(m_state->mutex);
    m_state->owner = nullptr;
}

void AdapterInfoWindows::query(const QBluetoothAddress &address)
{
    m_address = address;

    if (m_running) return;
    m_running = true;

    std::thread([state = m_state, address = address.toUInt64()]() {
        winrt::init_apartment(winrt::apartment_type::multi_threaded);
        const AdapterDetails details = gather(address);
        winrt::uninit_apartment();

        // Events posted to a deleted object are discarded
        std::lock_guard lock(state->mutex);
        if (AdapterInfoWindows *owner = state->owner)
        {
            QMetaObject::invokeMethod(owner, [owner, details]() {
                owner->m_running = false;
                owner->setDetails(details);
            }, Qt::QueuedConnection);
        }
    }).detach();
}

/* ************************************************************************** */

AdapterDetails AdapterInfoWindows::gather(quint64 address)
{
    AdapterDetails d;

    // WinRT
    try
    {
        const winrt::hstring instanceIdKey = L"System.Devices.DeviceInstanceId";
        const DeviceInformationCollection adapters = DeviceInformation::FindAllAsync(
            BluetoothAdapter::GetDeviceSelector(),
            winrt::single_threaded_vector<winrt::hstring>({ instanceIdKey })).get();

        for (const DeviceInformation &info: adapters)
        {
            const BluetoothAdapter adapter = BluetoothAdapter::FromIdAsync(info.Id()).get();
            if (!adapter || adapter.BluetoothAddress() != address) continue;

            d.classic = adapter.IsClassicSupported();
            d.lowEnergy = adapter.IsLowEnergySupported();
            d.centralRole = adapter.IsCentralRoleSupported();
            d.peripheralRole = adapter.IsPeripheralRoleSupported();
            d.advertisingOffload = adapter.IsAdvertisementOffloadSupported();
            d.leSecureConnections = adapter.AreLowEnergySecureConnectionsSupported();

            const wchar_t *adapterClass = L"Windows.Devices.Bluetooth.BluetoothAdapter";
            if (ApiInformation::IsPropertyPresent(adapterClass, L"IsExtendedAdvertisingSupported"))
            {
                d.extendedAdvertising = adapter.IsExtendedAdvertisingSupported();
            }
            if (ApiInformation::IsPropertyPresent(adapterClass, L"MaxAdvertisementDataLength"))
            {
                d.maxAdvertisingLength = static_cast<int>(adapter.MaxAdvertisementDataLength());
            }
#if defined(WDK_NTDDI_VERSION) && (WDK_NTDDI_VERSION >= 0x0A000010) // NTDDI_WIN11_GE, SDK 10.0.26100
            if (ApiInformation::IsPropertyPresent(adapterClass, L"IsLowEnergyUncoded2MPhySupported") &&
                ApiInformation::IsPropertyPresent(adapterClass, L"IsLowEnergyCodedPhySupported"))
            {
                if (adapter.IsLowEnergySupported()) d.phys << "1M";
                if (adapter.IsLowEnergyUncoded2MPhySupported()) d.phys << "2M";
                if (adapter.IsLowEnergyCodedPhySupported()) d.phys << "Coded";
            }
#endif

            // Radio device node: chipset name, and USB ID
            const winrt::hstring instanceId =
                winrt::unbox_value_or<winrt::hstring>(info.Properties().TryLookup(instanceIdKey), L"");
            if (!instanceId.empty())
            {
                const QString id = QString::fromWCharArray(instanceId.c_str());
                static const QRegularExpression usb(QStringLiteral("VID_([0-9A-F]{4})&PID_([0-9A-F]{4})"),
                                                    QRegularExpression::CaseInsensitiveOption);
                const QRegularExpressionMatch match = usb.match(id);
                if (match.hasMatch())
                {
                    d.usbId = (match.captured(1) + ':' + match.captured(2)).toLower();
                }

                const DeviceInformation device = DeviceInformation::CreateFromIdAsync(
                    instanceId, winrt::single_threaded_vector<winrt::hstring>(),
                    DeviceInformationKind::Device).get();
                if (device) d.chipset = QString::fromWCharArray(device.Name().c_str());
            }

            break;
        }
    }
    catch (const winrt::hresult_error &e)
    {
        qWarning() << "AdapterInfoWindows::gather() WinRT error:"
                   << QString::fromWCharArray(e.message().c_str());
    }

    // Win32
    BLUETOOTH_FIND_RADIO_PARAMS params = { sizeof(BLUETOOTH_FIND_RADIO_PARAMS) };
    HANDLE radio = nullptr;
    HBLUETOOTH_RADIO_FIND find = BluetoothFindFirstRadio(&params, &radio);
    if (find)
    {
        do {
            BLUETOOTH_RADIO_INFO radioInfo = { sizeof(BLUETOOTH_RADIO_INFO) };
            if (BluetoothGetRadioInfo(radio, &radioInfo) == ERROR_SUCCESS &&
                radioInfo.address.ullLong == address)
            {
                d.alias = QString::fromWCharArray(radioInfo.szName);
                d.manufacturerId = radioInfo.manufacturer;
                d.lmpSubversion = radioInfo.lmpSubversion;

#if defined(TOOLBLEX_HAS_BTHIOCTL)
                BTH_LOCAL_RADIO_INFO localInfo = {};
                DWORD bytes = 0;
                if (DeviceIoControl(radio, IOCTL_BTH_GET_LOCAL_INFO, nullptr, 0,
                                    &localInfo, sizeof(localInfo), &bytes, nullptr))
                {
                    d.coreVersion = AdapterInfoUtils::coreVersionString(localInfo.radioInfo.lmpVersion);
                }
#endif
                CloseHandle(radio);
                break;
            }

            CloseHandle(radio);
            radio = nullptr;
        } while (BluetoothFindNextRadio(find, &radio));

        BluetoothFindRadioClose(find);
    }

    return d;
}

/* ************************************************************************** */
