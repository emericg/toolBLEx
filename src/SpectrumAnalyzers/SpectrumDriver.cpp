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

#include "SpectrumDriver.h"

#include <QMetaObject>
#include <QDebug>

/* ************************************************************************** */

SpectrumDriver::SpectrumDriver(QObject *parent) : QObject(parent)
{
    //
}

/* ************************************************************************** */

void SpectrumDriver::setRunning(bool running)
{
    if (m_running != running)
    {
        m_running = running;
        Q_EMIT runningChanged();
    }
}

/* ************************************************************************** */

void SpectrumDriver::postError(const QString &message)
{
    qWarning() << metaObject()->className() << message;

    QMetaObject::invokeMethod(this, [this, message]() {
        m_lastError = message;
        Q_EMIT errorOccurred(message);
    }, Qt::QueuedConnection);
}

/* ************************************************************************** */

void SpectrumDriver::pushSamples(std::vector <Sample> &&samples)
{
    if (samples.empty()) return;

    bool post = false;
    {
        std::lock_guard lock(m_pending_mutex);

        if (m_pending.size() + samples.size() > s_max_pending) m_pending.clear(); // consumer stalled

        if (m_pending.empty()) m_pending = std::move(samples);
        else m_pending.insert(m_pending.end(), samples.begin(), samples.end());

        if (!m_notify_posted)
        {
            m_notify_posted = true;
            post = true;
        }
    }

    if (post)
    {
        QMetaObject::invokeMethod(this, [this]() { Q_EMIT readyRead(); }, Qt::QueuedConnection);
    }
}

/* ************************************************************************** */

void SpectrumDriver::clearSamples()
{
    std::lock_guard lock(m_pending_mutex);
    m_pending.clear();
    m_notify_posted = false;
}

/* ************************************************************************** */

std::vector <SpectrumDriver::Sample> SpectrumDriver::takeSamples()
{
    std::vector <Sample> out;

    std::lock_guard lock(m_pending_mutex);
    out.swap(m_pending);
    m_notify_posted = false;

    return out;
}

/* ************************************************************************** */
