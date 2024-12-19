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

#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QStandardPaths>

/* ************************************************************************** */

UtilsLog *UtilsLog::instance = nullptr;

UtilsLog *UtilsLog::getInstance(const bool enabled)
{
    if (instance == nullptr)
    {
        instance = new UtilsLog(enabled);
        return instance;
    }
    else
    {
        return instance;
    }
}

UtilsLog::UtilsLog(const bool enabled)
{
    m_logging = enabled;
    openLogFile();
}

UtilsLog::UtilsLog()
{
    openLogFile();
}

UtilsLog::~UtilsLog()
{
    //
}

/* ************************************************************************** */

void UtilsLog::setEnabled(const bool enabled)
{
    m_logging = enabled;
    openLogFile();
}

bool UtilsLog::openLogFile(const QString &path)
{
    bool status = false;

    if (m_logging)
    {
        if (path.isEmpty())
        {
            m_logPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
            if (!m_logPath.isEmpty())
            {
                m_logPath += "/log.txt";
            }
        }
        else
        {
            m_logPath = path;
        }

        m_logFile.setFileName(m_logPath);
        if (m_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
        {
            qDebug() << "UtilsLog() open log file" << m_logPath;
            status = true;
        }
        else
        {
            qWarning() << "UtilsLog() cannot open log file" << m_logPath;
            m_logPath.clear();
            status = false;
        }
    }

    return status;
}

/* ************************************************************************** */

void UtilsLog::pushLog(const QString &log)
{
    if (m_logging && !log.isEmpty())
    {
        if (!m_logFile.isOpen())
        {
            openLogFile();
        }

        if (m_logFile.isOpen())
        {
            QTextStream out(&m_logFile);
            out << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss") << " | " << log << Qt::endl;
        }
    }
}

QString UtilsLog::getLog()
{
    if (m_logging && !m_logPath.isEmpty())
    {
        QFile file(m_logPath);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            //QByteArray content = file.readAll();
            //return content;

            QByteArray content;
            while (!file.atEnd())
            {
                content.push_front(file.readLine());
            }

            return content;
        }
    }

    return QString();
}

void UtilsLog::clearLog()
{
    if (!m_logPath.isEmpty() && QFile::exists(m_logPath))
    {
        m_logFile.close();
        m_logFile.remove();
    }
}

/* ************************************************************************** */
