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

#include "UbertoothDriver_bin.h"
#include "SettingsManager.h"

#include <QStandardPaths>
#include <QStringList>
#include <QProcess>
#include <QFile>
#include <QDebug>

#include <cmath>

/* ************************************************************************** */
/* ************************************************************************** */

UbertoothDriver_bin::UbertoothDriver_bin(QObject *parent) : SpectrumDriver_bin(parent)
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool UbertoothDriver_bin::autodetect()
{
    m_path_specan = QStandardPaths::findExecutable("ubertooth-specan");
    m_path_util = QStandardPaths::findExecutable("ubertooth-util");

    if (m_path_specan.isEmpty() || m_path_util.isEmpty()) return false;

    SettingsManager *sm = SettingsManager::getInstance();
    sm->setUbertoothPath(m_path_specan);

    return true;
}

/* ************************************************************************** */

bool UbertoothDriver_bin::detect()
{
    bool status = false;

    SettingsManager *sm = SettingsManager::getInstance();
    QString path_specan = sm->getUbertoothPath();

    if (path_specan.isEmpty() || !path_specan.contains("ubertooth-specan"))
    {
        m_available = false;
        return false;
    }

    if (QFile::exists(path_specan))
    {
        // If the path points directly to a file
        status = true;
    }
    else if (path_specan == "ubertooth-specan")
    {
        // If the path is the executable name, and we can find it
        path_specan = QStandardPaths::findExecutable("ubertooth-specan");
        if (!path_specan.isEmpty())
        {
            status = true;

            // And save it... QStandardPaths::findExecutable() is expensive
            sm->setUbertoothPath(path_specan);
        }
    }
    else
    {
        // Otherwise, just try to run it...

        QString path_util = path_specan;
        path_util.replace("ubertooth-specan", "ubertooth-util");

        QProcess process;
        process.start(path_util, QStringList("-v"), QIODevice::ReadOnly);
        process.waitForStarted(333);
        process.waitForFinished(333);

        QString err(process.readAllStandardError());
        QProcess::ProcessError error = process.error();

        if (error >= QProcess::FailedToStart && err.isEmpty())
        {
            qWarning() << "QProcess::FailedToStart for process '" << path_util << "' with error:" << error;
        }
        else
        {
            status = true;
        }
    }

    if (status)
    {
        m_path_specan = path_specan;
        m_path_util = path_specan; // always next to specan
        m_path_util.replace("ubertooth-specan", "ubertooth-util");
    }
    else
    {
        qDebug() << "UbertoothDriver_bin::detect() Unable to detect Ubertooth tools at: '" << path_specan << "'";
    }

    m_available = status;
    return status;
}

/* ************************************************************************** */

bool UbertoothDriver_bin::checkHardware(int deviceIndex)
{
    if (m_path_util.isEmpty()) return false;

    bool status = false;

    QStringList args("-v");
    if (deviceIndex > 0) args << "-U" + QString::number(deviceIndex);

    QProcess process;
    process.start(m_path_util, args, QIODevice::ReadOnly);
    process.waitForStarted(333);
    process.waitForFinished(333);

    QString output(process.readAllStandardOutput());

    if (!output.isEmpty())
    {
        QStringList output_split = output.split('\n');
        QString l1 = output_split.first();

        if (l1.contains("could not open Ubertooth device", Qt::CaseInsensitive) ||
            l1.contains("usb_claim_interface error", Qt::CaseInsensitive) ||
            l1.contains("failed to run:", Qt::CaseInsensitive))
        {
            qWarning() << "UbertoothDriver_bin::checkHardware() Unable to detect an Ubertooth device";
            qWarning() << "UbertoothDriver_bin::checkHardware() error:" << l1;
        }
        else
        {
            // ubertooth-util -v: "Firmware version: 2020-12-R1 (API:1.07)\n"
            status = true;
        }
    }

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

QStringList UbertoothDriver_bin::buildArguments(const Config &cfg) const
{
    QStringList args;
    args << "-l" + QString::number(std::lround(cfg.freqMinHz / 1e6));
    args << "-u" + QString::number(std::lround(cfg.freqMaxHz / 1e6));
    if (cfg.deviceIndex > 0) args << "-U" + QString::number(cfg.deviceIndex);
    return args;
}

/* ************************************************************************** */

void UbertoothDriver_bin::requestStop(QProcess *process)
{
    if (process) process->write("q\n");
}

/* ************************************************************************** */

void UbertoothDriver_bin::parseLine(const QString &line, std::vector <Sample> &out)
{
    // ubertooth-specan CSV: "timestamp (seconds), freq (MHz), rssi (dB)"

    const QStringList f = line.split(',');
    if (f.size() != 3) return;

    bool ok_freq = false, ok_rssi = false;
    const int freq = f.at(1).toInt(&ok_freq);
    const int rssi = f.at(2).toInt(&ok_rssi);

    if (!ok_freq || !ok_rssi) return;

    out.push_back({ freq * 1e6, static_cast<float>(rssi + s_rssi_offset) });
}

/* ************************************************************************** */
/* ************************************************************************** */
