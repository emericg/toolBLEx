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

#ifndef UBERTOOTH_DRIVER_LIB_H
#define UBERTOOTH_DRIVER_LIB_H
/* ************************************************************************** */

#include "SpectrumDriver_lib.h"

#include <QString>

/* ************************************************************************** */

/*!
 * \brief Ubertooth One spectrum analyzer driver, talking to the firmware directly through libusb.
 *
 * The 'library' here is libusb-1.0, not libubertooth.
 * No libubertooth, libbtbb, nor 'ubertooth-specan' binary is required,
 * so this works on Linux, macOS and Windows (with a WinUSB driver).
 *
 * Protocol (from ubertooth_interface.h / ubertooth_control.c):
 * - vendor control OUT UBERTOOTH_SPECAN (wValue = low MHz, wIndex = high MHz) starts the sweep,
 * - vendor control OUT UBERTOOTH_STOP stops it,
 * - bulk IN endpoint 0x82 streams 64 bytes 'usb_pkt_rx' packets,
 * - SPECAN packets carry 16 triplets of (freq_hi, freq_lo, int8 rssi) in their 50 bytes payload.
 *
 * Frequencies are integer MHz, the raw RSSI is offset to dBm like with 'ubertooth-specan'.
 */
class UbertoothDriver_lib: public SpectrumDriver_lib
{
    Q_OBJECT

    static constexpr int s_rssi_offset = -52;       //!< raw RSSI -> dBm offset (from ubertooth-specan-ui)

    static constexpr quint8 s_ep_data_in = 0x82;
    static constexpr int s_pkt_len = 64;
    static constexpr int s_pkt_header_len = 14;
    static constexpr int s_pkt_payload_len = 50;
    static constexpr int s_pkt_type_specan = 4;

    static constexpr quint8 s_cmd_ping = 0;
    static constexpr quint8 s_cmd_stop = 21;
    static constexpr quint8 s_cmd_specan = 27;
    static constexpr quint8 s_cmd_get_rev_num = 33;

    static constexpr unsigned s_ctrl_timeout_ms = 1000;
    static constexpr unsigned s_bulk_timeout_ms = 100;
    static constexpr int s_bulk_packets = 16;       //!< packets per bulk read (~40 ms at usual rates)

    /*!
     * \brief Decode a bulk buffer made of consecutive 64 bytes packets, and push its samples.
     * \param data: Raw bulk data.
     * \param len: Number of valid bytes in data.
     *
     * Non SPECAN packets (keep-alive, messages) are ignored.
     */
    void decodePackets(const quint8 *data, int len);

protected:
    void workerLoop(const Config cfg) override;

public:
    explicit UbertoothDriver_lib(QObject *parent = nullptr);
    ~UbertoothDriver_lib() override;

    /*!
     * \brief Available if at least one Ubertooth is connected (does not open it).
     */
    bool detect() override;

    /*!
     * \brief Open the device, ping it, and read its firmware version.
     */
    bool checkHardware(int deviceIndex) override;

    double defaultFloorDb() const override { return -100.0; }
    double defaultCeilDb() const override { return -20.0; }

    /*!
     * \brief Count connected Ubertooth devices.
     * \return Device count, or -1 if libusb could not be initialized.
     *
     * Does not open the devices, so it works even without USB access rights or driver.
     */
    static int deviceCount();

    /*!
     * \brief Open a device and read its firmware version.
     * \param deviceIndex: Index of the Ubertooth among the connected ones.
     * \param firmware: Optional, receives the firmware version string (ex: "2020-12-R1").
     * \param error: Optional, receives a user-facing reason on failure.
     * \return true if the device could be opened, claimed, and answered.
     */
    static bool probeDevice(int deviceIndex, QString *firmware = nullptr, QString *error = nullptr);
};

/* ************************************************************************** */
#endif // UBERTOOTH_DRIVER_LIB_H
