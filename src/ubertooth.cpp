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

#include "ubertooth.h"
#include "SettingsManager.h"

#include <QStringList>
#include <QProcess>
#include <QFile>
#include <QDebug>

/* ************************************************************************** */
/* ************************************************************************** */

Ubertooth::Ubertooth(QObject *parent) : SpectrumSource(parent)
{
    m_floorDb = -100.0;
    m_ceilDb = -20.0;

    m_unit = MHz;

    configureForStart();

    checkPaths();
}

/* ************************************************************************** */
/* ************************************************************************** */

bool Ubertooth::checkPaths()
{
    bool status = false;

#if defined(Q_OS_WINDOWS)
    return status; // We just don't support Windows
#endif

    SettingsManager *sm = SettingsManager::getInstance();
    QString path_specscan = sm->getUbertoothPath();

    // Just check if the path points to a file
    if (path_specscan.contains("ubertooth-specan") && QFile::exists(path_specscan))
    {
        status = true;
    }
    else
    {
        QString path_util = "";
        if (path_specscan.contains("ubertooth-specan"))
        {
            path_util = path_specscan;
            path_util.replace("ubertooth-specan", "ubertooth-util");
        }

        QProcess process;
        process.start(path_util, QStringList("-v"), QIODevice::ReadOnly);
        process.waitForFinished(8000);

        QString err(process.readAllStandardError());
        QProcess::ProcessError error = process.error();

        if (error >= QProcess::FailedToStart && err.isEmpty())
        {
            qDebug() << "QProcess::FailedToStart for process '" << path_util << "' with error:" << error;
        }
        else
        {
            status = true;
        }
    }

    if (status)
    {
        m_path_specan = path_specscan;
        m_path_util = path_specscan;
        m_path_util.replace("ubertooth-specan", "ubertooth-util");
    }
    else
    {
        qDebug() << "Ubertooth::checkPaths() Unable to detect Ubertooth tools at: '" << path_specscan << "'";
    }

    if (m_toolsAvailable != status)
    {
        m_toolsAvailable = status;
        Q_EMIT availableChanged();
    }

    return status;
}

/* ************************************************************************** */

bool Ubertooth::checkUbertooth()
{
#if defined(Q_OS_WINDOWS)
    return false; // We just don't support Windows
#endif

    if (m_childProcess) return true; // A running capture already implies a device

    bool status = false;

    QProcess process;
    process.start(m_path_util, QStringList("-v"), QIODevice::ReadOnly);
    process.waitForFinished(8000);

    QString output(process.readAllStandardOutput());

    if (!output.isEmpty())
    {
        QStringList output_split = output.split('\n');
        QString l1 = output_split.first();

        if (l1.contains("could not open Ubertooth device", Qt::CaseInsensitive) ||
            l1.contains("usb_claim_interface error", Qt::CaseInsensitive) ||
            l1.contains("failed to run:", Qt::CaseInsensitive))
        {
            qDebug() << "Ubertooth::checkUbertooth() Unable to detect an Ubertooth device";
        }
        else
        {
            // ubertooth-util -v: "Firmware version: 2020-12-R1 (API:1.07)\n"
            status = true;
        }
    }

    if (m_hardwareAvailable != status)
    {
        m_hardwareAvailable = status;
        Q_EMIT availableChanged();
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void Ubertooth::configureForStart()
{
    SettingsManager *sm = SettingsManager::getInstance();
    m_freq_min = sm->getUbertoothFreqMin();
    m_freq_max = sm->getUbertoothFreqMax();
    Q_EMIT freqChanged();
}

/* ************************************************************************** */

QStringList Ubertooth::buildArguments() const
{
    QStringList args;
    args << "-l" + QString::number(m_freq_min);
    args << "-u" + QString::number(m_freq_max);
    if (m_deviceIndex > 0) args << "-U" + QString::number(m_deviceIndex);
    return args;
}

/* ************************************************************************** */

void Ubertooth::requestStop(QProcess *process)
{
    // ubertooth-specan reads stdin, and stops cleanly on 'q'.

    if (process) process->write("q\n");
}

/* ************************************************************************** */

void Ubertooth::parseLine(const QString &line, int *&current_values, bool &sweepCompleted)
{
    // ubertooth-specan CSV: "timestamp, freq_MHz, rssi"

    const QStringList f = line.split(',');
    if (f.size() != 3) return;

    bool ok_freq = false, ok_rssi = false;
    const int freq = f.at(1).toInt(&ok_freq);
    const int rssi = f.at(2).toInt(&ok_rssi);

    if (!ok_freq || !ok_rssi) return;
    if (freq < m_freq_min || freq > m_freq_max) return;

    recordBin(freq, rssi + s_rssi_offset, current_values, sweepCompleted);
}

/* ************************************************************************** */
/* ************************************************************************** */
