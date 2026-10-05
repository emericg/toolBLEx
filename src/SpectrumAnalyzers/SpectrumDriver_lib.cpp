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

#include "SpectrumDriver_lib.h"

#include <QMetaObject>

/* ************************************************************************** */

SpectrumDriver_lib::SpectrumDriver_lib(QObject *parent) : SpectrumDriver(parent)
{
    //
}

SpectrumDriver_lib::~SpectrumDriver_lib()
{
    m_stop_requested = true;
    if (m_worker.joinable()) m_worker.join();
}

/* ************************************************************************** */

bool SpectrumDriver_lib::start(const Config &cfg)
{
    if (m_running) return false;

    if (m_worker.joinable()) m_worker.join(); // previous worker already exited on its own

    clearSamples();
    m_lastError.clear();
    m_stop_requested = false;

    const int generation = ++m_generation;
    m_worker = std::thread([this, cfg, generation]() {
        workerLoop(cfg);
        QMetaObject::invokeMethod(this, [this, generation]() { workerFinished(generation); },
                                  Qt::QueuedConnection);
    });

    setRunning(true);
    return true;
}

/* ************************************************************************** */

void SpectrumDriver_lib::stop()
{
    m_stop_requested = true;
    if (m_worker.joinable()) m_worker.join();

    setRunning(false);
}

/* ************************************************************************** */

void SpectrumDriver_lib::workerFinished(int generation)
{
    if (generation != m_generation) return; // a newer capture was started since
    if (m_worker.joinable()) m_worker.join();

    setRunning(false);
}

/* ************************************************************************** */
