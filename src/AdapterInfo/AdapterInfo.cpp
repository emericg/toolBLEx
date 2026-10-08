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

#include "AdapterInfo.h"

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
#include "AdapterInfoBluez.h"
#elif defined(Q_OS_WINDOWS)
#include "AdapterInfoWindows.h"
#elif defined(Q_OS_MACOS)
#include "AdapterInfoMacos.h"
#endif

#include <QProcess>
#include <QStandardPaths>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

AdapterInfo::AdapterInfo(QObject *parent) : QObject(parent)
{
    //
}

AdapterInfo *AdapterInfo::create(QObject *parent)
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    return new AdapterInfoBluez(parent);
#elif defined(Q_OS_WINDOWS)
    return new AdapterInfoWindows(parent);
#elif defined(Q_OS_MACOS)
    return new AdapterInfoMacos(parent);
#else
    Q_UNUSED(parent)
    return nullptr;
#endif
}

/* ************************************************************************** */

void AdapterInfo::setDetails(const AdapterDetails &details)
{
    if (m_details != details)
    {
        m_details = details;
        Q_EMIT detailsChanged(m_details);
    }
}

QProcess *AdapterInfo::startProcess(const QString &program, const QStringList &arguments,
                                    std::function<void (const QString &output)> onFinished)
{
    const QString path = QStandardPaths::findExecutable(program);
    if (path.isEmpty()) return nullptr;

    QProcess *process = new QProcess(this);

    connect(process, &QProcess::finished, this,
            [process, onFinished = std::move(onFinished)](int, QProcess::ExitStatus) {
        onFinished(QString::fromLocal8Bit(process->readAllStandardOutput()));
        process->deleteLater();
    });
    connect(process, &QProcess::errorOccurred, this,
            [process, program](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart)
        {
            qWarning() << "AdapterInfo::startProcess(" << program << ") failed to start";
            process->deleteLater();
        }
    });

    QTimer::singleShot(s_process_timeout_ms, process, [process]() { process->kill(); });

    process->start(path, arguments);

    return process;
}

/* ************************************************************************** */
