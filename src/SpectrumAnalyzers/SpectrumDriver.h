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

#ifndef SPECTRUM_DRIVER_H
#define SPECTRUM_DRIVER_H
/* ************************************************************************** */

#include <QObject>
#include <QString>

#include <atomic>
#include <mutex>
#include <vector>

/* ************************************************************************** */

/*!
 * \brief Abstract interface of a spectrum analyzer driver.
 *
 * A driver talks to one kind of hardware, through one kind of backend:
 * - SpectrumDriver_bin: spawns and parses a command-line tool,
 * - SpectrumDriver_lib: uses a library, from a private worker thread.
 *
 * Drivers produce (frequency, dB) samples, in sweep order.
 * Within a sweep, frequencies are increasing, a lower frequency marks the start of a new sweep.
 *
 * Samples are accumulated in a mutex protected buffer (they can be pushed from any thread),
 * and readyRead() is emitted (queued, coalesced) on the thread owning the driver.
 * Consumers then drain the buffer with takeSamples().
 */
class SpectrumDriver: public QObject
{
    Q_OBJECT

public:
    /*!
     * \brief Capture parameters, common to all drivers.
     *
     * Each driver uses what its hardware and backend support, and ignores the rest.
     */
    struct Config
    {
        int deviceIndex = 0;            //!< Index of the device among the connected ones.
        double freqMinHz = 0.0;         //!< Lower bound of the captured band.
        double freqMaxHz = 0.0;         //!< Upper bound of the captured band.
        double gainDb = -1.0;           //!< Tuner gain, < 0 for automatic.
        double integrationTime = 0.05;  //!< Seconds of signal averaged into one sweep.
    };

    /*!
     * \brief One spectrum measurement.
     */
    struct Sample
    {
        double freqHz = 0.0;
        float db = 0.f;                 //!< Uncalibrated, see defaultFloorDb() / defaultCeilDb().
    };

private:
    static constexpr size_t s_max_pending = 262144; //!< pending samples cap, if the consumer stalls

    std::mutex m_pending_mutex;
    std::vector <Sample> m_pending;
    bool m_notify_posted = false;       //!< guarded by m_pending_mutex

protected:
    std::atomic_bool m_running { false };
    bool m_available = false;
    QString m_lastError;

    /*!
     * \brief Queue samples for the owner thread.
     * \param samples: Samples to append, in sweep order.
     *
     * Thread safe. The first push after a takeSamples() emits readyRead() (queued).
     */
    void pushSamples(std::vector <Sample> &&samples);

    /*!
     * \brief Drop all pending samples (before a new capture).
     */
    void clearSamples();

    /*!
     * \brief Report an error to the owner thread (sets lastError, emits errorOccurred()).
     *
     * Thread safe.
     */
    void postError(const QString &message);

    /*!
     * \brief Update the running state, and emit runningChanged() if needed.
     *
     * Owner thread only.
     */
    void setRunning(bool running);

Q_SIGNALS:
    void runningChanged();
    void readyRead();                           //!< new samples can be fetched with takeSamples()
    void errorOccurred(const QString &message);

public:
    explicit SpectrumDriver(QObject *parent = nullptr);

    /*!
     * \brief Check if this driver can be used on this system.
     * \return true if the backend is usable (tools installed, or supported device connected).
     *
     * Can be expensive, the result is cached and available through isAvailable().
     */
    virtual bool detect() = 0;

    /*!
     * \brief Tell if this driver relies on external command-line tools (which paths can be set by the user).
     */
    virtual bool usesTools() const = 0;

    /*!
     * \brief Search for the backend automatically (ex: tools in the PATH), and save what was found.
     * \return true if found.
     *
     * Default: same as detect().
     */
    virtual bool autodetect() { return detect(); }

    /*!
     * \brief Check if a device is connected and responding.
     * \param deviceIndex: Index of the device among the connected ones.
     * \return true if the device answered.
     *
     * Must not be called while a capture is running.
     */
    virtual bool checkHardware(int deviceIndex) = 0;

    /*!
     * \brief Suggested colormap range for this driver's (uncalibrated) dB scale.
     */
    virtual double defaultFloorDb() const = 0;
    virtual double defaultCeilDb() const = 0;

    /*!
     * \brief Start a capture.
     * \param cfg: Capture parameters.
     * \return false if already running, or if the capture could not be started at all.
     *
     * Later device errors are asynchronous, reported through errorOccurred() then runningChanged().
     */
    virtual bool start(const Config &cfg) = 0;

    /*!
     * \brief Stop the capture, synchronously.
     */
    virtual void stop() = 0;

    bool isAvailable() const { return m_available; }
    bool isRunning() const { return m_running; }
    QString lastError() const { return m_lastError; }

    /*!
     * \brief Fetch all samples received since the previous call, in sweep order.
     */
    std::vector <Sample> takeSamples();
};

/* ************************************************************************** */
#endif // SPECTRUM_DRIVER_H
