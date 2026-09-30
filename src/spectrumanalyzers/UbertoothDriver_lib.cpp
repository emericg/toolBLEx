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

#include "UbertoothDriver_lib.h"

#include <QDebug>

#include <libusb.h>

#include <algorithm>
#include <cmath>

/* ************************************************************************** */

namespace {

constexpr quint8 s_ctrl_in = LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_ENDPOINT_IN;
constexpr quint8 s_ctrl_out = LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_ENDPOINT_OUT;

/*!
 * \brief RAII wrapper for a libusb context, device handle, and claimed interface 0.
 */
struct UsbSession
{
    libusb_context *ctx = nullptr;
    libusb_device_handle *devh = nullptr;
    bool claimed = false;

    ~UsbSession()
    {
        if (claimed) libusb_release_interface(devh, 0);
        if (devh) libusb_close(devh);
        if (ctx) libusb_exit(ctx);
    }
};

/*!
 * \brief Tell if a USB device descriptor matches a known Ubertooth.
 */
bool isUbertooth(const libusb_device_descriptor &desc)
{
    return (desc.idVendor == 0x1d50 && desc.idProduct == 0x6002) || // Ubertooth One
           (desc.idVendor == 0x1d50 && desc.idProduct == 0x6000) || // Ubertooth Zero
           (desc.idVendor == 0xffff && desc.idProduct == 0x0004);   // ToorCon 13 badge
}

/*!
 * \brief Build a user-facing error message from a libusb error code, with a per-OS hint.
 * \param what: Operation that failed.
 * \param err: libusb error code.
 */
QString usbError(const char *what, int err)
{
    QString msg = QStringLiteral("%1: %2").arg(what, libusb_strerror(err));

    switch (err)
    {
    case LIBUSB_ERROR_ACCESS:
#if defined(Q_OS_LINUX)
        msg += QStringLiteral(" (missing udev rules for the Ubertooth?)");
#else
        msg += QStringLiteral(" (device used by another application?)");
#endif
        break;
    case LIBUSB_ERROR_NOT_SUPPORTED:
    case LIBUSB_ERROR_NOT_FOUND:
#if defined(Q_OS_WINDOWS)
        msg += QStringLiteral(" (no WinUSB driver, install it with Zadig)");
#endif
        break;
    case LIBUSB_ERROR_BUSY:
        msg += QStringLiteral(" (device already in use, is an ubertooth tool running?)");
        break;
    case LIBUSB_ERROR_NO_DEVICE:
        msg += QStringLiteral(" (device disconnected)");
        break;
    default:
        break;
    }

    return msg;
}

/*!
 * \brief Open and claim the Nth Ubertooth.
 * \param s: Session to fill, its context must be initialized.
 * \param deviceIndex: Index of the Ubertooth among the connected ones.
 * \param error: Receives a user-facing reason on failure.
 * \return true on success.
 */
bool openUbertooth(UsbSession &s, int deviceIndex, QString &error)
{
    libusb_device **list = nullptr;
    const ssize_t count = libusb_get_device_list(s.ctx, &list);
    if (count < 0)
    {
        error = usbError("libusb_get_device_list", static_cast<int>(count));
        return false;
    }

    libusb_device *found = nullptr;
    int seen = 0;
    for (ssize_t i = 0; i < count && !found; i++)
    {
        libusb_device_descriptor desc {};
        if (libusb_get_device_descriptor(list[i], &desc) != LIBUSB_SUCCESS) continue;
        if (isUbertooth(desc) && seen++ == deviceIndex) found = list[i];
    }

    int r = LIBUSB_ERROR_NO_DEVICE;
    if (found) r = libusb_open(found, &s.devh);
    libusb_free_device_list(list, 1);

    if (!found)
    {
        error = QStringLiteral("No Ubertooth device found (index %1)").arg(deviceIndex);
        return false;
    }
    if (r != LIBUSB_SUCCESS)
    {
        s.devh = nullptr;
        error = usbError("libusb_open", r);
        return false;
    }

    libusb_set_auto_detach_kernel_driver(s.devh, 1); // Linux only, harmless elsewhere

    r = libusb_claim_interface(s.devh, 0);
    if (r != LIBUSB_SUCCESS)
    {
        error = usbError("libusb_claim_interface", r);
        return false;
    }
    s.claimed = true;

    return true;
}

} // namespace

/* ************************************************************************** */
/* ************************************************************************** */

UbertoothDriver_lib::UbertoothDriver_lib(QObject *parent) : SpectrumDriver_lib(parent)
{
    //
}

UbertoothDriver_lib::~UbertoothDriver_lib()
{
    stop();
}

/* ************************************************************************** */
/* ************************************************************************** */

int UbertoothDriver_lib::deviceCount()
{
    UsbSession s;
    if (libusb_init(&s.ctx) != LIBUSB_SUCCESS)
    {
        s.ctx = nullptr;
        return -1;
    }

    libusb_device **list = nullptr;
    const ssize_t count = libusb_get_device_list(s.ctx, &list);
    if (count < 0) return -1;

    int found = 0;
    for (ssize_t i = 0; i < count; i++)
    {
        libusb_device_descriptor desc {};
        if (libusb_get_device_descriptor(list[i], &desc) == LIBUSB_SUCCESS && isUbertooth(desc)) found++;
    }
    libusb_free_device_list(list, 1);

    return found;
}

/* ************************************************************************** */

bool UbertoothDriver_lib::probeDevice(int deviceIndex, QString *firmware, QString *error)
{
    QString err;
    UsbSession s;

    int r = libusb_init(&s.ctx);
    if (r != LIBUSB_SUCCESS)
    {
        s.ctx = nullptr;
        if (error) *error = usbError("libusb_init", r);
        return false;
    }

    if (!openUbertooth(s, deviceIndex, err))
    {
        if (error) *error = err;
        return false;
    }

    r = libusb_control_transfer(s.devh, s_ctrl_in, s_cmd_ping, 0, 0, nullptr, 0, s_ctrl_timeout_ms);
    if (r < 0)
    {
        if (error) *error = usbError("UBERTOOTH_PING", r);
        return false;
    }

    if (firmware)
    {
        // Reply is either a 2 bytes SVN revision (old firmwares),
        // or a 2 bytes revision followed by a length prefixed version string.
        quint8 buf[2 + 1 + 255] {};
        r = libusb_control_transfer(s.devh, s_ctrl_in, s_cmd_get_rev_num, 0, 0,
                                    buf, sizeof(buf), s_ctrl_timeout_ms);
        if (r == 2)
        {
            *firmware = QString::number(buf[0] | (buf[1] << 8));
        }
        else if (r > 3)
        {
            const int len = std::min<int>(r - 3, buf[2]);
            *firmware = QString::fromLatin1(reinterpret_cast<const char *>(buf + 3), len);
        }
        else
        {
            firmware->clear();
        }
    }

    return true;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool UbertoothDriver_lib::detect()
{
    m_available = (deviceCount() > 0);
    return m_available;
}

/* ************************************************************************** */

bool UbertoothDriver_lib::checkHardware(int deviceIndex)
{
    QString firmware, error;
    const bool status = probeDevice(deviceIndex, &firmware, &error);

    if (status) qDebug() << "UbertoothDriver_lib::checkHardware() firmware:" << firmware;
    else qWarning() << "UbertoothDriver_lib::checkHardware()" << error;

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void UbertoothDriver_lib::workerLoop(const Config cfg)
{
    const int deviceIndex = cfg.deviceIndex;
    const int freqMin = static_cast<int>(std::lround(cfg.freqMinHz / 1e6));
    const int freqMax = static_cast<int>(std::lround(cfg.freqMaxHz / 1e6));
    if (deviceIndex < 0 || freqMin <= 0 || freqMax > 0xFFFF || freqMin > freqMax)
    {
        postError(QStringLiteral("Invalid Ubertooth capture parameters"));
        return;
    }

    QString err;
    UsbSession s;

    int r = libusb_init(&s.ctx);
    if (r != LIBUSB_SUCCESS)
    {
        s.ctx = nullptr;
        postError(usbError("libusb_init", r));
        return;
    }

    if (!openUbertooth(s, deviceIndex, err))
    {
        postError(err);
        return;
    }

    // Clear any mode left running by a previous (crashed) session, then start the sweep
    libusb_control_transfer(s.devh, s_ctrl_out, s_cmd_stop, 0, 0, nullptr, 0, s_ctrl_timeout_ms);

    r = libusb_control_transfer(s.devh, s_ctrl_out, s_cmd_specan,
                                static_cast<quint16>(freqMin), static_cast<quint16>(freqMax),
                                nullptr, 0, s_ctrl_timeout_ms);
    if (r < 0)
    {
        postError(usbError("UBERTOOTH_SPECAN", r));
        return;
    }

    std::vector <quint8> buf(static_cast<size_t>(s_pkt_len) * s_bulk_packets);

    while (!stopRequested())
    {
        int transferred = 0;
        r = libusb_bulk_transfer(s.devh, s_ep_data_in, buf.data(), static_cast<int>(buf.size()),
                                 &transferred, s_bulk_timeout_ms);

        // On timeout, 'transferred' still holds whatever arrived before it
        if (transferred > 0) decodePackets(buf.data(), transferred);

        if (r != LIBUSB_SUCCESS && r != LIBUSB_ERROR_TIMEOUT && r != LIBUSB_ERROR_INTERRUPTED)
        {
            postError(usbError("bulk read", r));
            break;
        }
    }

    if (r != LIBUSB_ERROR_NO_DEVICE)
    {
        libusb_control_transfer(s.devh, s_ctrl_out, s_cmd_stop, 0, 0, nullptr, 0, s_ctrl_timeout_ms);
    }
}

/* ************************************************************************** */

void UbertoothDriver_lib::decodePackets(const quint8 *data, int len)
{
    std::vector <Sample> samples;
    samples.reserve(static_cast<size_t>(len / s_pkt_len) * (s_pkt_payload_len / 3));

    for (int off = 0; off + s_pkt_len <= len; off += s_pkt_len)
    {
        const quint8 *pkt = data + off;
        if (pkt[0] != s_pkt_type_specan) continue;

        const quint8 *payload = pkt + s_pkt_header_len;
        for (int j = 0; j + 2 < s_pkt_payload_len; j += 3)
        {
            const int freq = (payload[j] << 8) | payload[j + 1];
            const int rssi = static_cast<qint8>(payload[j + 2]);
            samples.push_back({ freq * 1e6, static_cast<float>(rssi + s_rssi_offset) });
        }
    }

    pushSamples(std::move(samples));
}

/* ************************************************************************** */
/* ************************************************************************** */

