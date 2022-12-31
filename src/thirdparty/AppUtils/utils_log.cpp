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

#include "utils_log.h"

#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QStandardPaths>

/* ************************************************************************** */

UtilsLog *UtilsLog::instance = nullptr;

UtilsLog *UtilsLog::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsLog();
        return instance;
    }
    else
    {
        return instance;
    }
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

bool UtilsLog::openLogFile(const QString &path)
{
    bool status = false;

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

    return status;
}

/* ************************************************************************** */

void UtilsLog::pushLog(const QString &log)
{
    if (!log.isEmpty())
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
    if (!m_logPath.isEmpty())
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
    if (QFile::exists(m_logPath))
    {
        m_logFile.close();
        m_logFile.remove();
    }
}

/* ************************************************************************** */
