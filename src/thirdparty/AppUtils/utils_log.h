/*!
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
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2022
 */

#ifndef UTILS_LOG_H
#define UTILS_LOG_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QFile>

/* ************************************************************************** */

class UtilsLog : public QObject
{
    Q_OBJECT

    QString m_logPath;
    QFile m_logFile;

    // Singleton
    static UtilsLog *instance;
    UtilsLog();
    ~UtilsLog();

public:
    static UtilsLog *getInstance();

    bool openLogFile(const QString &path = QString());

    Q_INVOKABLE void pushLog(const QString &log);

    Q_INVOKABLE QString getLog();

    Q_INVOKABLE void clearLog();
};

/* ************************************************************************** */
#endif // UTILS_LOG_H
