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

#include "SpectrumDriver_bin.h"

#include <QDebug>

/* ************************************************************************** */

SpectrumDriver_bin::SpectrumDriver_bin(QObject *parent) : SpectrumDriver(parent)
{
    //
}

SpectrumDriver_bin::~SpectrumDriver_bin()
{
    if (m_process)
    {
        m_process->disconnect(this);
        m_process->kill();
        m_process->waitForFinished(333);
        delete m_process;
        m_process = nullptr;
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool SpectrumDriver_bin::start(const Config &cfg)
{
    if (m_process) return false;

    const QString binary = binaryPath();
    if (binary.isEmpty()) return false;

    const QStringList args = buildArguments(cfg);

    m_buffer.clear();
    m_lastError.clear();
    clearSamples();

    m_process = new QProcess(this);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &SpectrumDriver_bin::processOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &SpectrumDriver_bin::processStderr);
    connect(m_process, &QProcess::finished, this, &SpectrumDriver_bin::processFinished);
    connect(m_process, &QProcess::errorOccurred, this, &SpectrumDriver_bin::processErrorOccurred);

    qDebug() << "SpectrumDriver_bin::start()" << binary << args;
    m_process->start(binary, args);

    setRunning(true);
    return true;
}

/* ************************************************************************** */

void SpectrumDriver_bin::stop()
{
    if (!m_process) return;

    requestStop(m_process);

    if (!m_process->waitForFinished(333))
    {
        m_process->kill();
        m_process->waitForFinished(333);
    }

    cleanupProcess();
}

/* ************************************************************************** */

void SpectrumDriver_bin::requestStop(QProcess *process)
{
    if (process) process->terminate();
}

/* ************************************************************************** */

void SpectrumDriver_bin::cleanupProcess()
{
    if (!m_process) return;

    m_process->disconnect(this);
    m_process->deleteLater();
    m_process = nullptr;

    setRunning(false);
}

/* ************************************************************************** */
/* ************************************************************************** */

void SpectrumDriver_bin::processFinished()
{
    if (!m_process) return;

    qDebug() << "SpectrumDriver_bin::processFinished(status:" << m_process->exitStatus()
             << "/ code:" << m_process->exitCode() << ")";

    processOutput(); // flush what is left
    cleanupProcess();
}

/* ************************************************************************** */

void SpectrumDriver_bin::processErrorOccurred(QProcess::ProcessError error)
{
    if (!m_process) return;

    // A process that failed to start will never emit finished()
    if (error == QProcess::FailedToStart)
    {
        postError(QStringLiteral("Unable to start '%1': %2").arg(m_process->program(), m_process->errorString()));
        cleanupProcess();
    }
}

/* ************************************************************************** */

void SpectrumDriver_bin::processStderr()
{
    if (!m_process) return;

    const QString err = m_process->readAllStandardError();
    if (err.contains("No supported devices", Qt::CaseInsensitive) ||
        err.contains("No devices found", Qt::CaseInsensitive) ||
        err.contains("could not open Ubertooth device", Qt::CaseInsensitive) ||
        err.contains("usb_claim_interface error", Qt::CaseInsensitive))
    {
        postError(err.trimmed());
    }
}

/* ************************************************************************** */

void SpectrumDriver_bin::processOutput()
{
    if (!m_process) return;

    m_buffer += QString(m_process->readAllStandardOutput());

    std::vector <Sample> samples;

    // Consume only complete lines; keep any trailing partial line for next time
    int nl;
    while ((nl = m_buffer.indexOf('\n')) >= 0)
    {
        const QString line = m_buffer.left(nl).trimmed();
        m_buffer.remove(0, nl + 1);

        if (line.isEmpty() || line.startsWith('#')) continue; // blanks / comments

        parseLine(line, samples);
    }

    pushSamples(std::move(samples));
}

/* ************************************************************************** */
