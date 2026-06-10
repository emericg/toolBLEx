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

#ifndef UBERTOOTH_H
#define UBERTOOTH_H
/* ************************************************************************** */

#include "SpectrumSource.h"

#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief Spectrum source backed by Ubertooth One USB device.
 *
 * Spawns 'ubertooth-specan' and parses its CSV output ("timestamp, freq_MHz, rssi").
 * Frequencies are integer MHz (1 bin == 1 MHz); the raw RSSI is offset to dBm.
 *
 * Ubertooth One is great from 2.3 GHz to 2.6 GHz, maybe even more at a reduced precision.
 *
 * Usual capture rate with 'ubertooth-specan' is around:
 * - ~83 Hz for the default 2402..2480 Mhz 'WiFi' range.
 * - ~66 Hz for our default 2400..2500 Mhz range.
 * - ~22 Hz for the full 2300..2600 Mhz range.
 */
class Ubertooth: public SpectrumSource
{
    Q_OBJECT

    static constexpr int s_rssi_offset = -52; //!< raw RSSI -> dBm offset

    QString m_path_specan;  //!< 'ubertooth-specan' binary
    QString m_path_util;    //!< 'ubertooth-util' binary (version / device probe)

protected:
    QString binaryPath() const override { return m_path_specan; }
    QStringList buildArguments() const override;

    void configureForStart() override;
    void requestStop(QProcess *process) override;
    void parseLine(const QString &line, int *&current_values, bool &sweepCompleted) override;

public:
    Ubertooth(QObject *parent = nullptr);

    Q_INVOKABLE bool checkPaths() override;
    Q_INVOKABLE bool checkUbertooth();
};

/* ************************************************************************** */
#endif // UBERTOOTH_H
