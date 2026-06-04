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

#include <QtGraphs/QLineSeries>
#include <QtGraphs/QValueAxis>

/* ************************************************************************** */

class Ubertooth: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool toolsAvailable READ isToolsAvailable NOTIFY availableChanged)
    Q_PROPERTY(bool hardwareAvailable READ isHardwareAvailable NOTIFY availableChanged)

    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(int freqMin READ getFreqMin NOTIFY freqChanged)
    Q_PROPERTY(int freqMax READ getFreqMax NOTIFY freqChanged)

    Q_PROPERTY(int peakFreq READ getPeakFreq NOTIFY peakChanged)
    Q_PROPERTY(int peakDbm READ getPeakDbm NOTIFY peakChanged)
    Q_PROPERTY(double captureRate READ getCaptureRate NOTIFY captureRateChanged)

    static constexpr int s_rssi_raw_default = -128;
    static constexpr int s_rssi_hole_threshold = -125;
    static constexpr int s_rssi_offset = -52;

    static constexpr int s_max_stack = 512;
    static constexpr int s_max_average_window = 256;

    bool m_toolsAvailable = false;
    bool m_hardwareAvailable = false;

    QString m_path_specan;
    QString m_path_util;

    int m_freq_min = 2400;
    int m_freq_max = 2500;

    QProcess *m_childProcess = nullptr;

    int m_idx_values_row = -1;
    int m_idx_values_col = -1;
    QString m_lastLineSplit;

    QList <int *> m_values;
    QMap <int, int> m_values_latest;
    int m_max_max = -128;
    int m_peak_freq = 0;
    int m_peak_dbm = s_rssi_raw_default;
    double m_capture_rate = 0.0;

    bool isRunning() const { return m_childProcess; }
    bool isToolsAvailable() const { return m_toolsAvailable; }
    bool isHardwareAvailable() const { return m_hardwareAvailable; }

Q_SIGNALS:
    void availableChanged();
    void runningChanged();
    void freqChanged();
    void peakChanged();
    void captureRateChanged();
    void newDataAvailable();

private slots:
    void processStarted();
    void processFinished();

    /*!
     * \brief Process output from the 'ubertooth-specan' utils.
     *
     * Usually capture frequency is around:
     * - ~83 Hz for the default 2402..2480 Mhz WiFi range.
     * - ~66 Hz for our default 2400..2500 Mhz range.
     * - ~22 Hz for the full 2300..2600 Mhz range.
     */
    void processOutput();

public:
    Ubertooth(QObject *parent = nullptr);
    ~Ubertooth();

    int getFreqMin() const { return m_freq_min; }
    int getFreqMax() const { return m_freq_max; }
    int getFreqBinCount() const { return m_freq_max - m_freq_min + 1; }
    const QList <int *> &getValues() const { return m_values; } // Used by the 3D graph

    int getPeakFreq() const { return m_peak_freq; }
    int getPeakDbm() const { return m_peak_dbm; }

    double getCaptureRate() const { return m_capture_rate; }

    Q_INVOKABLE bool checkPath();
    Q_INVOKABLE bool checkUbertooth();

    Q_INVOKABLE void startWork();
    Q_INVOKABLE void stopWork();
    Q_INVOKABLE void restartWork();

    Q_INVOKABLE void getFrequencyGraphAxis(QValueAxis *axis);
    Q_INVOKABLE void getFrequencyGraphMax(QLineSeries *serie);
    Q_INVOKABLE void getFrequencyGraphAverage(QLineSeries *serie);
    Q_INVOKABLE void getFrequencyGraphCurrent(QLineSeries *serie);
    Q_INVOKABLE void getFrequencyGraphData(QLineSeries *serie, int index);
};

/* ************************************************************************** */
#endif // UBERTOOTH_H
