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

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>
#include <QString>
#include <QFile>

#include <deque>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief In-memory, bounded list model of structured log entries.
 *
 * Designed to be bound directly to a QML ListView/Repeater: appending an entry
 * emits the proper rowsInserted signal, so only the new delegate is created
 * (no full-buffer rebuild, no log re-parsing).
 *
 * It is exposed to QML through the UtilsLog.logModel property, not instantiated directly.
 * Once it reaches its capacity, the oldest entry is evicted on each append.
 * Entries are stored newest-last (chronological order).
 */
class LogModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("LogModel is exposed through the UtilsLog.logModel property")

    Q_PROPERTY(int count READ count NOTIFY countChanged)

    struct Entry {
        QDateTime timestamp;
        int event = 0;
        QString log;
    };

    std::deque<Entry> m_entries; // O(1) push_back / pop_front for cheap eviction
    int m_maxEntries = 1024;

public:
    enum Roles {
        TimestampRole = Qt::UserRole + 1,
        EventRole,
        LogRole,
    };
    Q_ENUM(Roles)

Q_SIGNALS:
    void countChanged();

public:
    explicit LogModel(int maxEntries = 1024, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return static_cast<int>(m_entries.size()); }

    //! Append a new entry, evicting the oldest one if at capacity
    void append(const QDateTime &timestamp, const int event, const QString &text);

    //! Clear the model
    Q_INVOKABLE void clear();
};

/* ************************************************************************** */

/*!
 * \brief The LogString class
 *
 * It is exposed to QML through the UtilsLog.logString property.
 * Once it reaches its capacity, the oldest entry is evicted on each append.
 * Entries are stored newest-last (chronological order).
 */
class LogString : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString string READ getString CONSTANT)

    QString m_logString;
    int m_entries = 0;
    int m_maxEntries = 1024;

    void append(const QString &logline);

Q_SIGNALS:
    void logUpdated();
    void logLineAppended(const QString &line);

public:
    explicit LogString(int maxEntries = 1024, QObject *parent = nullptr);

    //! Get the whole thing
    Q_INVOKABLE const QString &getString() const { return m_logString; }

    //! Append a new entry, evicting the oldest one if at capacity
    void append(const QDateTime &timestamp, const int event, const QString &text);

    //! Clear the model
    Q_INVOKABLE void clear();
};

/* ************************************************************************** */

/*!
 * \brief The UtilsLog class. Not thread safe.
 */
class UtilsLog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Use the model
    Q_PROPERTY(LogModel *logModel READ getLogModel CONSTANT)

    // Use the less capable "full size" QString
    Q_PROPERTY(LogString *logString READ getLogString CONSTANT)

    bool m_logging = false;
    QString m_logPath;
    QFile m_logFile;

    static const int s_max_entries = 1024;
    int capacity() const { return s_max_entries; }

    LogModel *m_logModel = nullptr;
    LogModel *getLogModel();

    LogString *m_logString = nullptr;
    LogString *getLogString();

    bool openLogFile();
    void closeLogFile();

    // Singleton
    explicit UtilsLog(QObject *parent = nullptr);

public:
    enum EventType {
        Unknown = 0,
        Error,
        Warning,
        Info,
        Debug,
        User,
    };
    Q_ENUM(EventType)

    static QString eventToString(int event);
    static int eventFromString(const QString &label);

    static QString logToString(const QDateTime &timestamp, const int event, const QString &text);

public:
    static UtilsLog *getInstance();
    static UtilsLog *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE void setLogFile(const QString &path);

    bool isEnabled() const { return m_logging; }
    Q_INVOKABLE void setEnabled(const bool enabled, const bool enableModel = false, const bool enableString = false);

    /*!
     * \brief Open (or create) the log file.
     * \param loadModel: true to load data into the model.
     * \param loadString: true to load data into the 'big' QString.
     * \param path: Optional custom path.
     * \return true on success.
     *
     * If seedModel is true, also (re)load the file
     * content into the in-memory model. No-op while logging is disabled.
     */
    Q_INVOKABLE bool loadFromFile(bool loadModel = true, bool loadString = true);

    /*!
     * \brief Append a log line to the file and the models. No-op while logging is disabled.
     * \warning Must be called from the thread that owns UtilsLog (the GUI thread). A debug-build Q_ASSERT catches violations.
     *
     * The LogModel/LogString it feeds have GUI-thread affinity, and the file/string
     * writes are unsynchronized, so calling this from a worker thread is undefined behaviour.
     *
     * To log from another thread, marshal the call (e.g. QMetaObject::invokeMethod(..., Qt::QueuedConnection)).
     */
    Q_INVOKABLE void pushLog(const QString &log, int event = UtilsLog::Unknown);

    //! Delete log entries (and log file content, if possible).
    Q_INVOKABLE void clearLog();

    //! Legacy
    Q_INVOKABLE QString getRawString();
};

/* ************************************************************************** */
#endif // UTILS_LOG_H
