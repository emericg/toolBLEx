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

#ifndef ADAPTER_INFO_H
#define ADAPTER_INFO_H
/* ************************************************************************** */

#include "AdapterDetails.h"

#include <QObject>
#include <QString>
#include <QStringList>
#include <QBluetoothAddress>

#include <functional>

class QProcess;

/* ************************************************************************** */

/*!
 * \brief Abstract interface of a platform backend gathering local adapter information.
 *
 * query() starts the asynchronous work, results are delivered through detailsChanged(),
 * possibly several times, as parts arrive or as live properties change.
 * Each emission carries the complete details known so far.
 */
class AdapterInfo: public QObject
{
    Q_OBJECT

protected:
    QBluetoothAddress m_address;
    AdapterDetails m_details;

    /*!
     * \brief Run a command-line tool asynchronously.
     * \param program: Executable name or path.
     * \param arguments: Command-line arguments.
     * \param onFinished: Called with the standard output, once the process has exited.
     * \return The running process (owned by this object, deleted once finished), or nullptr if none found.
     *
     * The process is killed after s_process_timeout_ms, onFinished() is then called anyway.
     * onFinished() is not called if the process fails to start.
     */
    QProcess *startProcess(const QString &program, const QStringList &arguments,
                           std::function<void (const QString &output)> onFinished);

    /*!
     * \brief Replace the current details, and emit detailsChanged() if they differ.
     */
    void setDetails(const AdapterDetails &details);

    static constexpr int s_process_timeout_ms = 333;

Q_SIGNALS:
    void detailsChanged(const AdapterDetails &details);

public:
    explicit AdapterInfo(QObject *parent = nullptr);

    /*!
     * \brief Create the backend of the current platform.
     * \param parent: QObject parent of the backend.
     * \return The backend, or nullptr if the platform has none.
     */
    static AdapterInfo *create(QObject *parent = nullptr);

    /*!
     * \brief Start gathering information about an adapter, asynchronously.
     * \param address: Address of the local adapter, as reported by QBluetoothHostInfo.
     */
    virtual void query(const QBluetoothAddress &address) = 0;

    const AdapterDetails &details() const { return m_details; }
};

/* ************************************************************************** */
#endif // ADAPTER_INFO_H
