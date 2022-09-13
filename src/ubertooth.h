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

#ifndef UBERTOOTH_H
#define UBERTOOTH_H
/* ************************************************************************** */

#include <QObject>
#include <QProcess>

#include <QList>
#include <QMap>

#include <QtCharts/QLineSeries>
#include <QtCharts/QValueAxis>

/* ************************************************************************** */

class Ubertooth: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool toolsAvailable READ isToolsAvailable NOTIFY availableChanged)
    Q_PROPERTY(bool hardwareAvailable READ isHardwareAvailable NOTIFY availableChanged)

    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(int freqMin READ getFreqMin NOTIFY freqChanged)
    Q_PROPERTY(int freqMax READ getFreqMax NOTIFY freqChanged)

    static const int s_default_raw_rssi = -128;
    static const int s_rssi_offset = -52;
    static const int s_max_stack = 240;

    bool m_toolsAvailable = false;
    bool m_hardwareAvailable = false;

    QString m_path_specan;
    QString m_path_util;

    int m_freq_min = 2402;
    int m_freq_max = 2480;

    QProcess *m_childProcess = nullptr;

    int m_idx_values_row = -1;
    int m_idx_values_col = -1;
    QString m_lastLineSplit;

    QList <int *> m_values;
    QMap <int, int> m_values_latest;
    int m_max_max = -128;

    bool isRunning() const { return m_childProcess; }
    bool isToolsAvailable() const { return m_toolsAvailable; }
    bool isHardwareAvailable() const { return m_hardwareAvailable; }
    int getFreqMin() const { return m_freq_min; }
    int getFreqMax() const { return m_freq_max; }

Q_SIGNALS:
    void availableChanged();
    void runningChanged();
    void freqChanged();

private slots:
    void processStarted();
    void processFinished();
    void processOutput();

public:
    Ubertooth(QObject *parent = nullptr);
    ~Ubertooth();

    Q_INVOKABLE bool checkPath();
    Q_INVOKABLE bool checkUbertooth();

    Q_INVOKABLE void startWork();
    Q_INVOKABLE void stopWork();

    Q_INVOKABLE void getFrequencyGraphAxis(QValueAxis *axis);
    Q_INVOKABLE void getFrequencyGraphMax(QLineSeries *serie);
    Q_INVOKABLE void getFrequencyGraphCurrent(QLineSeries *serie);
    Q_INVOKABLE void getFrequencyGraphData(QLineSeries *serie, int index);
};

/* ************************************************************************** */
#endif // UBERTOOTH_H
