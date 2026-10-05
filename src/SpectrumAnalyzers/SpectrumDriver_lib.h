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

#ifndef SPECTRUM_DRIVER_LIB_H
#define SPECTRUM_DRIVER_LIB_H
/* ************************************************************************** */

#include "SpectrumDriver.h"

#include <atomic>
#include <thread>

/* ************************************************************************** */

/*!
 * \brief Base for drivers using a library, with blocking I/O on a private worker thread.
 *
 * Owns the worker thread lifecycle.
 * A device driver only implements workerLoop(), which runs until stopRequested() or an error,
 * and feeds pushSamples() / postError().
 *
 * Derived classes MUST call stop() in their own destructor:
 * the worker runs derived code, which is gone by the time this base destructor runs.
 */
class SpectrumDriver_lib: public SpectrumDriver
{
    Q_OBJECT

    std::thread m_worker;
    std::atomic_bool m_stop_requested { false };
    int m_generation = 0;           //!< incremented on each start(), filters stale worker exits

    /*!
     * \brief Owner thread side of the worker exit (joins the thread, updates the running state).
     * \param generation: Value of m_generation when that worker was started.
     */
    void workerFinished(int generation);

protected:
    /*!
     * \brief Worker thread entry point: open the device, capture, close the device.
     * \param cfg: Capture parameters.
     *
     * Must return promptly once stopRequested() becomes true.
     */
    virtual void workerLoop(const Config cfg) = 0;

    bool stopRequested() const { return m_stop_requested; }

public:
    explicit SpectrumDriver_lib(QObject *parent = nullptr);
    ~SpectrumDriver_lib() override;

    bool usesTools() const override { return false; }

    bool start(const Config &cfg) override;

    /*!
     * \brief Request the worker to stop, and wait for it (at most one blocking I/O timeout).
     */
    void stop() override;
};

/* ************************************************************************** */
#endif // SPECTRUM_DRIVER_LIB_H
