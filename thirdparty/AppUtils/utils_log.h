/*!
 * Copyright (c) 2022 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
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

    bool m_logging = false;
    QString m_logPath;
    QFile m_logFile;

    // Singleton
    static UtilsLog *instance;
    UtilsLog(const bool enabled);
    UtilsLog();
    ~UtilsLog();

public:
    static UtilsLog *getInstance(const bool enabled = true);

    void setEnabled(const bool enabled);

    bool openLogFile(const QString &path = QString());

    Q_INVOKABLE void pushLog(const QString &log);

    Q_INVOKABLE QString getLog();

    Q_INVOKABLE void clearLog();
};

/* ************************************************************************** */
#endif // UTILS_LOG_H
