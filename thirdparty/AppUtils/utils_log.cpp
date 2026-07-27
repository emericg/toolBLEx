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

#include "utils_log.h"

#include <algorithm>

#include <QCoreApplication>
#include <QQmlEngine>
#include <QThread>
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QTextStream>
#include <QDateTime>
#include <QStandardPaths>

/* ************************************************************************** */
/* ************************************************************************** */

LogModel::LogModel(int maxEntries, QObject *parent) : QAbstractListModel(parent)
{
    if (maxEntries > 0) m_maxEntries = maxEntries;
}

/* ************************************************************************** */

int LogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_entries.size());
}

QVariant LogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() ||
        index.row() < 0 ||
        index.row() >= static_cast<int>(m_entries.size()))
    {
        return QVariant();
    }

    const Entry &e = m_entries[index.row()];

    switch (role)
    {
    case TimestampRole: return e.timestamp;
    case EventRole:     return e.event;
    case LogRole:       return e.log;
    default:            return QVariant();
    }
}

QHash<int, QByteArray> LogModel::roleNames() const
{
    return {
        { TimestampRole, "timestamp" },
        { EventRole,     "event" },
        { LogRole,       "log" },
    };
}

/* ************************************************************************** */

void LogModel::append(const QDateTime &timestamp, const int event, const QString &text)
{
    // Evict the oldest entry first if we are at capacity
    if (static_cast<int>(m_entries.size()) >= m_maxEntries)
    {
        beginRemoveRows(QModelIndex(), 0, 0);
        m_entries.pop_front();
        endRemoveRows();
    }

    const int row = static_cast<int>(m_entries.size());
    beginInsertRows(QModelIndex(), row, row);
    m_entries.push_back({ timestamp, event, text });
    endInsertRows();

    Q_EMIT countChanged();
}

void LogModel::clear()
{
    if (m_entries.empty()) return;

    beginResetModel();
    m_entries.clear();
    endResetModel();

    Q_EMIT countChanged();
}

/* ************************************************************************** */
/* ************************************************************************** */

LogString::LogString(int maxEntries, QObject *parent) : QObject(parent)
{
    if (maxEntries > 0) m_maxEntries = maxEntries;
}

/* ************************************************************************** */

void LogString::append(const QDateTime &timestamp, const int event, const QString &text)
{
    append(UtilsLog::logToString(timestamp, event, text));
}

void LogString::append(const QString &logLine)
{
    // Evict the oldest entry first if we are at capacity.
    // Guard the newline lookup: without a trailing '\n' the buffer would grow
    // unbounded while the counter kept shrinking (remove(0, 0) is a no-op).
    if (m_entries >= m_maxEntries)
    {
        const int nl = m_logString.indexOf('\n');
        if (nl >= 0)
        {
            m_logString.remove(0, nl + 1);
            m_entries--;
        }
    }

    m_logString.push_back(logLine);
    m_entries++;
    Q_EMIT logLineAppended(logLine);
    Q_EMIT logUpdated();
}

void LogString::clear()
{
    m_entries = 0;
    m_logString.clear();

    Q_EMIT logUpdated();
}

/* ************************************************************************** */
/* ************************************************************************** */

UtilsLog *UtilsLog::getInstance()
{
    static UtilsLog *instance = new UtilsLog(QCoreApplication::instance());
    return instance;
}

UtilsLog *UtilsLog::create(QQmlEngine *, QJSEngine *)
{
    UtilsLog *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

UtilsLog::UtilsLog(QObject *parent) : QObject(parent)
{
    //
}

/* ************************************************************************** */

QString UtilsLog::eventToString(int event)
{
    switch (event)
    {
    case UtilsLog::Error:   return QStringLiteral("ERROR");
    case UtilsLog::Warning: return QStringLiteral("WARNING");
    case UtilsLog::Info:    return QStringLiteral("INFO");
    case UtilsLog::Debug:   return QStringLiteral("DEBUG");
    case UtilsLog::User:    return QStringLiteral("USER");
    default:                return QStringLiteral("LOG");
    }
}

int UtilsLog::eventFromString(const QString &label)
{
    if (label == QStringLiteral("ERROR"))   return UtilsLog::Error;
    if (label == QStringLiteral("WARNING")) return UtilsLog::Warning;
    if (label == QStringLiteral("INFO"))    return UtilsLog::Info;
    if (label == QStringLiteral("DEBUG"))   return UtilsLog::Debug;
    if (label == QStringLiteral("USER"))    return UtilsLog::User;
    return UtilsLog::Unknown;
}

QString UtilsLog::logToString(const QDateTime &timestamp, const int event, const QString &text)
{
    // sanetize CR/LF in the text
    QString safe = text;
    safe.replace(QLatin1Char('\r'), QLatin1Char(' '));
    safe.replace(QLatin1Char('\n'), QLatin1Char(' '));

    return timestamp.toString("yyyy-MM-dd hh:mm:ss") +
           " | " + UtilsLog::eventToString(event) +
           " | " + safe + '\n';
}

/* ************************************************************************** */

void UtilsLog::setLogFile(const QString &path)
{
    Q_ASSERT(thread() == QThread::currentThread());

    if (path.isEmpty() || path == m_logPath) return;

    m_logPath = path;

    // If we were already logging to another file, switch over to the new one
    if (m_logFile.isOpen())
    {
        closeLogFile();
        openLogFile();
    }
}

void UtilsLog::setEnabled(const bool enabled, const bool enableModel, const bool enableString)
{
    Q_ASSERT(thread() == QThread::currentThread());

    if (m_logging != enabled)
    {
        m_logging = enabled;

        if (m_logging)
        {
            loadFromFile(enableModel, enableString); // R/O

            openLogFile(); // R/W
        }
        else
        {
            closeLogFile();
        }
    }
}

/* ************************************************************************** */

bool UtilsLog::loadFromFile(bool loadModel, bool loadString)
{
    Q_ASSERT(thread() == QThread::currentThread());

    if (!loadModel && ! loadString) return false;
    //if (!m_logging) return false; // can be read only

    if (m_logPath.isEmpty())
    {
        m_logPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        if (!m_logPath.isEmpty())
        {
            m_logPath += "/log.txt";
        }
    }

    if (!m_logPath.isEmpty())
    {
        QFile file(m_logPath);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            const QByteArray content = file.readAll();
            file.close();

            LogModel *m = nullptr;
            if (loadModel)
            {
                m = getLogModel();
                m->clear();
            }
            LogString *s = nullptr;
            if (loadString)
            {
                s = getLogString();
                s->clear();
            }

            const QList<QByteArray> lines = content.split('\n');

            // Only keep the last <capacity> lines (the sinks are bounded anyway)
            const int start = qMax(0, static_cast<int>(lines.size()) - capacity());

            for (int i = start; i < lines.size(); ++i)
            {
                const QString str = QString::fromUtf8(lines.at(i)).trimmed();

                // Only accept the full "yyyy-MM-dd hh:mm:ss | EVENT | text" format,
                // skip anything else (empty, malformed or legacy lines)

                const int p1 = str.indexOf(" | ");
                const int p2 = (p1 < 0) ? -1 : str.indexOf(" | ", p1 + 3);
                if (p2 < 0) continue;

                const QDateTime ts = QDateTime::fromString(str.left(p1), "yyyy-MM-dd hh:mm:ss");
                const int evt = UtilsLog::eventFromString(str.mid(p1 + 3, p2 - (p1 + 3)));
                const QString txt = str.mid(p2 + 3);

                if (m) m->append(ts, evt, txt);
                if (s) s->append(ts, evt, txt);
            }

            return true;
        }
    }

    return false;
}

/* ************************************************************************** */

void UtilsLog::pushLog(const QString &log, int event)
{
    Q_ASSERT(thread() == QThread::currentThread());

    if (!m_logging || log.isEmpty()) return;

    const QDateTime now = QDateTime::currentDateTime();

    // Persist to the log file
    if (!m_logFile.isOpen())
    {
        // lazy opening
        openLogFile();
    }
    if (m_logFile.isOpen())
    {
        QTextStream out(&m_logFile);
        out << UtilsLog::logToString(now, event, log);
        out.flush();
    }

    // Push to the log models
    if (m_logString) m_logString->append(now, event, log);
    if (m_logModel) m_logModel->append(now, event, log);
}

/* ************************************************************************** */

void UtilsLog::clearLog()
{
    Q_ASSERT(thread() == QThread::currentThread());

    if (m_logging && m_logFile.isOpen())
    {
        // Truncating the shared inode is seen by all "append" file handles at once.
        m_logFile.resize(0);
        m_logFile.flush();
    }
    else if (!m_logPath.isEmpty() && QFile::exists(m_logPath))
    {
        // Simple remove. If more than one file handle is open, this won't really work.
        QFile::remove(m_logPath);
    }

    if (m_logString) m_logString->clear();
    if (m_logModel) m_logModel->clear();
}

/* ************************************************************************** */

LogModel *UtilsLog::getLogModel()
{
    if (!m_logModel)
    {
        // lazy loading
        m_logModel = new LogModel(s_max_entries, this);
    }

    return m_logModel;
}

LogString *UtilsLog::getLogString()
{
    if (!m_logString)
    {
        // lazy loading
        m_logString = new LogString(s_max_entries, this);
    }

    return m_logString;
}

/* ************************************************************************** */

bool UtilsLog::openLogFile()
{
    if (m_logFile.isOpen()) return true;

    // path
    if (m_logPath.isEmpty())
    {
        m_logPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        if (!m_logPath.isEmpty())
        {
            m_logPath += "/log.txt";
        }
    }

    // open
    if (!m_logPath.isEmpty())
    {
        const QDir dir = QFileInfo(m_logPath).absoluteDir();
        if (!dir.exists())
        {
            dir.mkpath(QStringLiteral("."));
        }

        m_logFile.setFileName(m_logPath);
        if (m_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
        {
            qDebug() << "UtilsLog() log file opened:" << m_logPath;
            return true;
        }
        else
        {
            qWarning() << "UtilsLog() cannot open log file!" << m_logPath;
            return false;
        }
    }

    return false;
}

void UtilsLog::closeLogFile()
{
    if (m_logFile.isOpen())
    {
        m_logFile.close();
    }
}

/* ************************************************************************** */

QString UtilsLog::getRawString()
{
    Q_ASSERT(thread() == QThread::currentThread());

    QString logPath = m_logPath;

    if (logPath.isEmpty())
    {
        logPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        if (!logPath.isEmpty())
        {
            logPath += "/log.txt";
        }
    }

    if (!logPath.isEmpty())
    {
        QFile file(logPath);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            // Return the whole content, newest-line-first, in a single O(n) pass

            QByteArray content = file.readAll();
            if (content.endsWith('\n')) content.chop(1); // avoid a leading blank line

            QList<QByteArray> lines = content.split('\n');
            std::reverse(lines.begin(), lines.end());
            return QString::fromUtf8(lines.join('\n'));
        }
    }

    return QString();
}

/* ************************************************************************** */
/* ************************************************************************** */
