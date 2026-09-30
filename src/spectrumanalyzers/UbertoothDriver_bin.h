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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef UBERTOOTH_DRIVER_BIN_H
#define UBERTOOTH_DRIVER_BIN_H
/* ************************************************************************** */

#include "SpectrumDriver_bin.h"

#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief Ubertooth One spectrum analyzer driver, using the 'ubertooth-specan' binary.
 *
 * Parses its CSV output ("timestamp, freq_MHz, rssi").
 * Frequencies are integer MHz, the raw RSSI is offset to dBm.
 *
 * Usual capture rate with 'ubertooth-specan' is around:
 * - ~83 Hz for the default 2402..2480 Mhz 'WiFi' range.
 * - ~66 Hz for our default 2400..2500 Mhz range.
 * - ~22 Hz for the full 2300..2600 Mhz range.
 */
class UbertoothDriver_bin: public SpectrumDriver_bin
{
    Q_OBJECT

    static constexpr int s_rssi_offset = -52; //!< raw RSSI -> dBm offset (from ubertooth-specan-ui)

    QString m_path_specan;  //!< 'ubertooth-specan' binary
    QString m_path_util;    //!< 'ubertooth-util' binary (version / device probe)

protected:
    QString binaryPath() const override { return m_path_specan; }
    QStringList buildArguments(const Config &cfg) const override;
    void parseLine(const QString &line, std::vector <Sample> &out) override;

    /*!
     * \brief 'ubertooth-specan' reads stdin, and stops cleanly on 'q'.
     */
    void requestStop(QProcess *process) override;

public:
    explicit UbertoothDriver_bin(QObject *parent = nullptr);

    /*!
     * \brief Find the tools using QStandardPaths::findExecutable(), and save them to the settings.
     * \return true if tools found.
     */
    bool autodetect() override;

    /*!
     * \brief Validate the tools path from the settings.
     * \return true if tools found.
     */
    bool detect() override;

    /*!
     * \brief Run 'ubertooth-util -v' to check for a device.
     */
    bool checkHardware(int deviceIndex) override;

    double defaultFloorDb() const override { return -100.0; }
    double defaultCeilDb() const override { return -20.0; }
};

/* ************************************************************************** */
#endif // UBERTOOTH_DRIVER_BIN_H
