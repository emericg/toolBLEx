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

#ifndef SPECTRUM_DRIVER_BIN_H
#define SPECTRUM_DRIVER_BIN_H
/* ************************************************************************** */

#include "SpectrumDriver.h"

#include <QProcess>
#include <QString>
#include <QStringList>

/* ************************************************************************** */

/*!
 * \brief Base for drivers spawning a command-line tool, and parsing its text output.
 *
 * Owns the QProcess lifecycle and the stdout line splitting.
 * A device driver only implements which binary to run, how to build its arguments,
 * and how to parse one line of its output.
 *
 * Not supported on Windows (not built there, see TOOLBLEX_SPECTRUM_* in CMakeLists.txt).
 */
class SpectrumDriver_bin: public SpectrumDriver
{
    Q_OBJECT

    QProcess *m_process = nullptr;
    QString m_buffer;               //!< accumulates partial stdout lines between reads

    /*!
     * \brief Release the process, once it finished or failed to start.
     */
    void cleanupProcess();

private slots:
    void processOutput();
    void processStderr();
    void processFinished();
    void processErrorOccurred(QProcess::ProcessError error);

protected:
    /*!
     * \brief Binary to spawn.
     * \return Full path, or empty if unavailable.
     */
    virtual QString binaryPath() const = 0;

    /*!
     * \brief Build the child process arguments.
     * \param cfg: Capture parameters.
     */
    virtual QStringList buildArguments(const Config &cfg) const = 0;

    /*!
     * \brief Parse one line of the child output.
     * \param line: Trimmed line, never empty nor a '#' comment.
     * \param out: Receives the samples found in that line.
     */
    virtual void parseLine(const QString &line, std::vector <Sample> &out) = 0;

    /*!
     * \brief Ask the child process to stop (default: SIGTERM).
     */
    virtual void requestStop(QProcess *process);

public:
    explicit SpectrumDriver_bin(QObject *parent = nullptr);
    ~SpectrumDriver_bin() override;

    bool usesTools() const override { return true; }

    bool start(const Config &cfg) override;
    void stop() override;
};

/* ************************************************************************** */
#endif // SPECTRUM_DRIVER_BIN_H
