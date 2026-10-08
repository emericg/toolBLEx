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

#ifndef ADAPTER_INFO_MACOS_H
#define ADAPTER_INFO_MACOS_H
/* ************************************************************************** */

#include "AdapterInfo.h"

class QProcess;

/* ************************************************************************** */

/*!
 * \brief macOS adapter information backend.
 *
 * Sources:
 * - `system_profiler SPBluetoothDataType`: chipset, firmware, core version, manufacturer.
 *   Not matched to the adapter address, macOS has a single controller.
 */
class AdapterInfoMacos: public AdapterInfo
{
    Q_OBJECT

    QProcess *m_profiler = nullptr; //!< running `system_profiler`, if any

    /*!
     * \brief Parse the `system_profiler SPBluetoothDataType` output.
     * \param output: Standard output of `system_profiler`.
     * \param details: Filled with the "Bluetooth Controller" section values.
     */
    static void parseProfiler(const QString &output, AdapterDetails &details);

public:
    explicit AdapterInfoMacos(QObject *parent = nullptr);

    void query(const QBluetoothAddress &address) override;
};

/* ************************************************************************** */
#endif // ADAPTER_INFO_MACOS_H
