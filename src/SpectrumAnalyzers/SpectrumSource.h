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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef SPECTRUM_SOURCE_H
#define SPECTRUM_SOURCE_H
/* ************************************************************************** */

#include "SpectrumDriver.h"

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include <QList>
#include <QMap>
#include <QString>
#include <QStringList>
#include <QElapsedTimer>

#include <QtGraphs/QLineSeries>
#include <QtGraphs/QValueAxis>

#include <vector>

/* ************************************************************************** */

/*!
 * \brief Abstract base for a swept-spectrum data source, fed by a SpectrumDriver.
 *
 * Owns everything generic to a spectrum scanner:
 * The rolling ring buffer of sweeps, the capture lifecycle, per-bin max-hold / average / peak extraction,
 * capture-rate measurement, and the methods the various graphs consume.
 *
 * A device class (SpectrumSourceUbertooth, SpectrumSourceRtlSdr) owns its drivers
 * (command-line tool '_bin', and/or library '_lib'), selects the active one,
 * and maps its settings to the driver configuration.
 *
 * Frequency bins are integer values in the source's chosen unit (MHz or kHz):
 * bin index i maps to (freqMin + i) units, getFreqBinCount() == freqMax-freqMin+1.
 *
 * Magnitudes are integer dB (uncalibrated; each source advertises its own floorDb/ceilDb
 * so the colormap can be scaled correctly).
 */
class SpectrumSource: public QObject
{
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(bool toolsAvailable READ areToolsAvailable NOTIFY availableChanged)
    Q_PROPERTY(bool hardwareAvailable READ isHardwareAvailable NOTIFY availableChanged)
    Q_PROPERTY(bool hardwareReady READ isHardwareReady NOTIFY availableChanged)

    Q_PROPERTY(bool hasDriver READ hasDriver NOTIFY availableChanged)
    Q_PROPERTY(bool driverUsesTools READ driverUsesTools NOTIFY availableChanged)

    Q_PROPERTY(int deviceIndex READ deviceIndex WRITE setDeviceIndex NOTIFY deviceIndexChanged)

    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(double captureRate READ getCaptureRate NOTIFY captureRateChanged)

    Q_PROPERTY(int freqMin READ getFreqMin NOTIFY freqChanged)
    Q_PROPERTY(int freqMax READ getFreqMax NOTIFY freqChanged)
    Q_PROPERTY(int freqUnit READ frequencyUnit NOTIFY freqChanged)

    Q_PROPERTY(double floorDb READ floorDb WRITE setFloorDb NOTIFY rangeChanged)
    Q_PROPERTY(double ceilDb READ ceilDb WRITE setCeilDb NOTIFY rangeChanged)

    Q_PROPERTY(int peakFreq READ getPeakFreq NOTIFY peakChanged)
    Q_PROPERTY(int peakDbm READ getPeakDbm NOTIFY peakChanged)

public:
    //! Frequency unit a source bins/labels with. Bin index step is 1 of these.
    enum FrequencyUnit {
        MHz = 0,
        kHz = 1
    };
    Q_ENUM(FrequencyUnit)

protected:
    static constexpr int s_rssi_raw_default = -128;
    static constexpr int s_rssi_hole_threshold = -125;

    static constexpr int s_max_stack = 512;
    static constexpr int s_max_average_window = 256;
    static constexpr int s_max_bins = 16384; //!< guard: refuse absurd bin counts (e.g. a very wide band in kHz)

    bool m_toolsAvailable = false;
    bool m_hardwareAvailable = false;
    bool m_hardwareReady = false; // TODO

    int m_deviceIndex = 0;                  //!< which device to use when several are present

    FrequencyUnit m_unit = MHz;             //!< bin unit (axis label + subclass bucketing)
    int m_freq_min = 2400;                  //!< lower bound, in m_unit
    int m_freq_max = 2500;                  //!< upper bound, in m_unit

    double m_floorDb = -100.0;              //!< colormap low end (per-source, uncalibrated)
    double m_ceilDb = -20.0;                //!< colormap high end (per-source, uncalibrated)

    SpectrumDriver *m_driver = nullptr;     //!< active driver (not owned)
    int m_last_bin = -1;                    //!< last bin frequency seen (sweep-wrap detection)
    int m_fill_prev_idx = -1;               //!< last bucket index written this sweep (sample-and-hold gap fill)

    std::vector <int> m_ring_buffer;
    int m_ring_head = 0;                    //!< raw index of the in-progress (newest) slot
    int m_ring_count = 0;                   //!< number of valid slots (1..s_max_stack)
    int m_ring_bins = 0;                    //!< ints per slot (== getFreqBinCount() at startWork)
    std::vector <int> m_blank_column;       //!< shared "no data" column used to left-pad

    QMap <int, int> m_values_latest;
    int m_max_max = s_rssi_raw_default;

    int m_peak_freq = 0;
    int m_peak_dbm = s_rssi_raw_default;

    QElapsedTimer m_sweep_timer;            //!< wall-clock window for the capture-rate measurement
    int m_sweeps_in_window = 0;             //!< completed sweeps counted in the current window
    double m_capture_rate = 0.0;            //!< exponentially-smoothed sweeps/second
    int m_capture_rate_emit = -1;           //!< last rounded Hz emitted (rate-limits the signal)

    int m_notify_min_interval_ms = 16;      //!< min ms between refreshes; derived from spectrogram_maxSamplingFreq at startWork()
    QElapsedTimer m_notify_timer;           //!< time since the last newDataAvailable emit
    bool m_notify_pending = false;          //!< a coalesced emit is already scheduled

    int *ringSlot(int i) { return m_ring_buffer.data() + static_cast<size_t>(i) * m_ring_bins; }

    bool areToolsAvailable() const { return m_toolsAvailable; }
    bool isHardwareAvailable() const { return m_hardwareAvailable; }
    bool isHardwareReady() const { return m_hardwareReady; }

    bool hasDriver() const { return m_driver; }
    bool driverUsesTools() const { return m_driver && m_driver->usesTools(); }

    bool isRunning() const { return m_driver && m_driver->isRunning(); }

    // Shared ring / parsing logic
    void allocateRing();
    void recordBin(int unitFreq, int dB, int *&current_values, bool &sweepCompleted);
    void advanceSweep(int *&current_values, bool &sweepCompleted);

    // Coalesced graph notification
    void scheduleDataNotification();
    void emitDataNotification();

    //! Convert a frequency in Hz into the current bin unit (MHz or kHz).
    int hzToUnit(double hz) const;

    /*!
     * \brief Select the driver used by the next capture.
     * \param driver: Driver owned by the subclass, or nullptr.
     *
     * Ignored while a capture is running. Applies the driver's default dB range.
     */
    void setActiveDriver(SpectrumDriver *driver);

    // Device-specific hooks
    virtual void configureForStart() {}                     //!< refresh freq range etc. before the ring is (re)allocated
    virtual SpectrumDriver::Config driverConfig() const;    //!< capture parameters (default: device index + freq range)

private slots:
    void driverRunningChanged();
    void driverReadyRead();
    void driverError(const QString &message);

Q_SIGNALS:
    void availableChanged();
    void runningChanged();
    void freqChanged();
    void rangeChanged();
    void deviceIndexChanged();
    void peakChanged();
    void captureRateChanged();
    void newDataAvailable();

public:
    explicit SpectrumSource(QObject *parent = nullptr);
    ~SpectrumSource() override;

    int deviceIndex() const { return m_deviceIndex; }
    void setDeviceIndex(int index);

    int frequencyUnit() const { return m_unit; }

    int getFreqMin() const { return m_freq_min; }
    int getFreqMax() const { return m_freq_max; }
    int getFreqBinCount() const { return m_freq_max - m_freq_min + 1; }

    double floorDb() const { return m_floorDb; }
    void setFloorDb(double v);
    double ceilDb() const { return m_ceilDb; }
    void setCeilDb(double v);

    int getPeakFreq() const { return m_peak_freq; }
    int getPeakDbm() const { return m_peak_dbm; }
    double getCaptureRate() const { return m_capture_rate; }

    /*!
     * \brief getChronologicalValues()
     * \param maxColumns: Maximum number of columns to return, if less than s_max_stack desired, 0 for full depth.
     * \param padHistory: If true, pad the results with blank columns, otherwise, return only the captured columns so far.
     * \return maxColumns of data.
     *
     * Expose the ring as a chronological list (oldest first, newest last).
     * The pointers alias into m_ring and stay valid until the next driverReadyRead()/startWork() on the GUI thread.
     *
     * getChronologicalValues() can left-pads its result with blank (no-data) columns,
     * so the list always has the full s_max_stack entry count.
     * This makes the waterfall / 3D surface render at their full sample width and scroll immediately,
     * instead of starting narrow and stretching until the ring fills, which I believe is more biutiful.
     * All padding entries alias m_blank_column (read-only for consumers), so this stays allocation-free.
     */
    QList <int *> getChronologicalValues(const int maxColumns = s_max_stack, const bool padHistory = true);

    /*!
     * \brief getLatestValues()
     * \return Latest row of data (per-bin), keyed by frequency in m_unit.
     */
    const QMap <int, int> &getLatestValues() const { return m_values_latest; }

    /*!
     * \brief Search for the driver backend automatically (ex: tools in the PATH), and save it to the settings.
     * \return true if found.
     */
    Q_INVOKABLE bool autodetectPaths();

    /*!
     * \brief Check that the driver backend is usable, and update toolsAvailable.
     * \return true if usable (tools installed, or supported device connected for a library driver).
     */
    Q_INVOKABLE bool checkPaths();

    /*!
     * \brief Check that a device is connected and responding, and update hardwareAvailable.
     * \return true if the device answered, or if a capture is already running.
     */
    Q_INVOKABLE bool checkHardware();

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
#endif // SPECTRUM_SOURCE_H
