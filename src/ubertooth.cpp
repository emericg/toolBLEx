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

#include <QProcess>
#include <QStringList>
#include <QFileInfo>
#include <QFile>
#include <QDir>
#include <QDebug>

/* ************************************************************************** */

Ubertooth::Ubertooth(QObject *parent) : QObject(parent)
{
    SettingsManager *sm = SettingsManager::getInstance();
    m_freq_min = sm->getUbertoothFreqMin();
    m_freq_max = sm->getUbertoothFreqMax();

    checkPath();
}

Ubertooth::~Ubertooth()
{
    qDeleteAll(m_values);
    m_values.clear();
    m_values_latest.clear();
    m_max_max = s_rssi_offset;
}

/* ************************************************************************** */

bool Ubertooth::checkPath()
{
    bool status = false;

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

        QString out(process.readAllStandardOutput());
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
        qDebug() << "Ubertooth::checkPath() Unable to detect Ubertooth tools at: '" << path_specscan << "'";
    }

    if (m_toolsAvailable != status)
    {
        m_toolsAvailable = status;
        Q_EMIT availableChanged();
    }

    return status;
}

bool Ubertooth::checkUbertooth()
{
    if (m_childProcess) return true;

    bool status = false;

    QProcess process;
    process.start(m_path_util, QStringList("-v"), QIODevice::ReadOnly);
    process.waitForFinished(8000);

    QString output(process.readAllStandardOutput());
    //QString err(process.readAllStandardError());
    //QProcess::ProcessError error = process.error();

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
            // ubertooth-util -N: "0" or "1"

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

void Ubertooth::startWork()
{
    if (m_path_specan.isEmpty()) return;
    if (m_childProcess) return;

    qDeleteAll(m_values);
    m_values.clear();
    m_values_latest.clear();
    m_max_max = s_rssi_offset;

    if (m_childProcess == nullptr)
    {
        m_childProcess = new QProcess();
    }

    if (m_childProcess)
    {
        connect(m_childProcess, SIGNAL(started()), this, SLOT(processStarted()));
        connect(m_childProcess, SIGNAL(finished(int)), this, SLOT(processFinished()));
        connect(m_childProcess, &QProcess::readyReadStandardOutput, this, &Ubertooth::processOutput);
        connect(m_childProcess, &QProcess::readyReadStandardError, this, &Ubertooth::processOutput);

        SettingsManager *sm = SettingsManager::getInstance();
        m_freq_min = sm->getUbertoothFreqMin();
        m_freq_max = sm->getUbertoothFreqMax();
        Q_EMIT freqChanged();

        QStringList args;
        args << "-l" + QString::number(m_freq_min);
        args << "-u" + QString::number(m_freq_max);

        //qDebug() << "Ubertooth::startWork()" << m_path_specan << args;
        m_childProcess->start(m_path_specan, args);
    }
}

void Ubertooth::stopWork()
{
    if (m_childProcess)
    {
        m_childProcess->write("q\n");

        if (m_childProcess->waitForFinished(333))
        {
            //qDebug() << "Ubertooth::stopWork()";
        }
        else
        {
            //qDebug() << "Ubertooth::stopWork() current process won't die...";
            m_childProcess->kill();
        }
    }
}

/* ************************************************************************** */

void Ubertooth::processStarted()
{
    if (m_childProcess)
    {
        qDebug() << "Ubertooth::processStarted()";
        Q_EMIT runningChanged();
    }
}

void Ubertooth::processFinished()
{
    if (m_childProcess)
    {
        int exitStatus = m_childProcess->exitStatus();
        int exitCode = m_childProcess->exitCode();

        m_childProcess->waitForFinished();
        m_childProcess->deleteLater();
        m_childProcess = nullptr;

        qDebug() << "Ubertooth::processFinished(status:" << exitStatus << "/ code:" << exitCode << ")";
        Q_EMIT runningChanged();
    }
}

/* ************************************************************************** */

void Ubertooth::processOutput()
{
    if (m_childProcess)
    {
        m_childProcess->waitForBytesWritten(40);

        QString output(m_lastLineSplit);
        m_lastLineSplit.clear();
        output += m_childProcess->readAllStandardOutput();

        //qDebug() << "Ubertooth::processOutput(" << output.size() << "bytes)" << output;
        // usually capture frequency is ~83 Hz

        // STATS
        //int idx = 0;
        //int count = 0;
        //int lastMsec = 0;

        // alloc
        int *current_values = nullptr;
        if (m_values.size())
        {
            current_values = m_values.last();
        }
        if (!current_values)
        {
            current_values = new int[m_freq_max-m_freq_min+1];
            std::memset(current_values, s_default_raw_rssi, (m_freq_max-m_freq_min+1)*4);
            m_values.push_back(current_values);
        }

        // parsing
        QStringList lines = output.split('\n', Qt::SkipEmptyParts);
        for (const auto &line: lines)
        {
            //qDebug() << "line (" << line.size() << ")" << line;

            QStringList linesplit = line.split(',');
            if (line.size() >= 19 && !line.endsWith('-') && linesplit.size() == 3)
            {
                int freq = linesplit.at(1).toInt();
                int rssi = linesplit.at(2).toInt();

                if (freq < m_freq_min || freq > m_freq_max)
                {
                    qDebug() << "> warning: freq " << freq << " > rssi " << rssi << "(" << m_freq_min << "/" << m_freq_max << ")";
                    continue;
                }

                m_values_latest[freq] = rssi + s_rssi_offset;
                current_values[freq - m_freq_min] = rssi + s_rssi_offset;

                if (freq == m_freq_max)
                {
                    //qDebug() << "allocating " << m_freq_max-m_freq_min << "e table";

                    current_values = new int[m_freq_max-m_freq_min+1];
                    std::memset(current_values, s_default_raw_rssi, (m_freq_max-m_freq_min+1)*4);
                    m_values.push_back(current_values);

                    if (m_values.size() > s_max_stack)
                    {
                        int *t = m_values.first();
                        delete [] t;
                        m_values.pop_front();
                    }

                    // STATS
                    //int msec = linesplit.at(0).toFloat() * 10000.f;
                    //if (lastMsec > 0) {
                    //    float ms = (msec - lastMsec) / 10.f;
                    //    float freq = 1000.f / ms;
                    //    qDebug() << "interval is" << QString::number(ms) << "ms  / " << QString::number(freq) << "Hz";
                    //}
                    //lastMsec = msec;
                    //count++;
                }
            }
            else
            {
                //qDebug() << "> warning:data break at << " << line;
                m_lastLineSplit = line;
            }
        }

        // STATS
        //qDebug() << "we got" << count << "rounds";
    }
}

/* ************************************************************************** */

void Ubertooth::getFrequencyGraphAxis(QValueAxis *axis)
{
    //qDebug() << "Ubertooth::getFrequencyGraphAxis()";

    if (!axis) return;

    axis->setMin(m_freq_min);
    axis->setMax(m_freq_max);
}

void Ubertooth::getFrequencyGraphMax(QLineSeries *serie)
{
    //qDebug() << "Ubertooth::getFrequencyGraphMax()" << serie;

    if (!serie) return;
    serie->clear();

    int *max = new int[m_freq_max-m_freq_min+1];
    std::memset(max, s_default_raw_rssi, (m_freq_max-m_freq_min+1)*4);
    m_max_max = s_default_raw_rssi;

    for (auto table: m_values)
    {
        for (int i = 0, j = m_freq_min; j <= m_freq_max; i++, j++)
        {
            if (table[i] > max[i]) max[i] = table[i];
            if (table[i] > m_max_max) m_max_max = table[i];
        }
    }

    for (int i = 0, j = m_freq_min; j <= m_freq_max; i++, j++)
    {
        serie->append(j, max[i]);
    }

    delete [] max;
}

void Ubertooth::getFrequencyGraphCurrent(QLineSeries *serie)
{
    //qDebug() << "Ubertooth::getFrequencyGraphCurrent()" << serie;

    if (!serie) return;
    serie->clear();

    for (int i = m_freq_min; i <= m_freq_max; i++)
    {
        serie->append(i, m_values_latest[i]);
    }
}

void Ubertooth::getFrequencyGraphData(QLineSeries *serie, int index)
{
    //qDebug() << "Ubertooth::getFrequencyGraphData()" << serie << index;

    if (!serie) return;
    serie->clear();

    if (index > m_values.size() - 1) return;

    int idx = m_values.size() - index - 1;
    int *current = m_values.at(idx);

    for (int i = 0, j = m_freq_min; j <= m_freq_max; i++, j++)
    {
        serie->append(j, current[i]);
    }
}

/* ************************************************************************** */
