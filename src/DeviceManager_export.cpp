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

#include "DeviceManager.h"
#include "SettingsManager.h"

#include "device_toolblex.h"

#include <QDir>
#include <QSaveFile>
#include <QTextStream>

/* ************************************************************************** */

/*!
 * \brief Format a value as a CSV field (RFC 4180).
 * \param value: the raw value.
 * \return the value, quoted if it contains a separator, a quote or a line break.
 */
static QString csvField(const QString &value)
{
    if (!value.contains(QLatin1Char(',')) && !value.contains(QLatin1Char('"')) &&
        !value.contains(QLatin1Char('\n')) && !value.contains(QLatin1Char('\r')))
    {
        return value;
    }

    QString quoted = value;
    quoted.replace(QLatin1Char('"'), QLatin1String("\"\""));
    return QLatin1Char('"') + quoted + QLatin1Char('"');
}

/*!
 * \brief Format a date as a CSV field.
 * \param dt: the date.
 * \return the date in ISO 8601 format, or an empty string if invalid.
 */
static QString csvDate(const QDateTime &dt)
{
    return dt.isValid() ? dt.toString(Qt::ISODate) : QString();
}

/* ************************************************************************** */

bool DeviceManager::exportResults(const QString &filename, int exportMode,
                                  bool withManuf, bool withComment, bool withSeen,
                                  const QString &comment)
{
    // Devices to export
    QList <DeviceToolBLEx *> devices;

    if (exportMode == 2)
    {
        for (int row = 0; row < m_devices_filter->rowCount(); row++)
        {
            const QModelIndex index = m_devices_filter->mapToSource(m_devices_filter->index(row, 0));
            DeviceToolBLEx *d = qobject_cast<DeviceToolBLEx *>(m_devices_model->device(index));
            if (d) devices.push_back(d);
        }
    }
    else
    {
        for (auto dd: std::as_const(m_devices_model->m_devices))
        {
            DeviceToolBLEx *d = qobject_cast<DeviceToolBLEx *>(dd);
            if (!d) continue;
            if (exportMode == 1 && d->getRssi() == 0) continue;

            devices.push_back(d);
        }
    }

    // Export file
    QString exportFilePath = filename;
    if (!getExportFile(exportFilePath)) return false;

    QSaveFile efile(exportFilePath);
    if (!efile.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qWarning() << "DeviceManager::exportResults() cannot open" << exportFilePath << ":" << efile.errorString();
        return false;
    }

    QTextStream eout(&efile);
    eout.setEncoding(QStringConverter::Utf8);

    // Capture comment, as commented out lines above the CSV content
    if (!comment.trimmed().isEmpty())
    {
        eout << "# Capture comment:\n";
        const QStringList lines = comment.trimmed().split(QLatin1Char('\n'));
        for (const auto &line: lines)
        {
            eout << "# " << line.trimmed() << '\n';
        }
    }

    // Legend
    QStringList fields = { "Device Address", "Device Name" };
    if (withManuf) fields << "Device Manufacturer";
    if (withComment) fields << "User Comment";
    if (withSeen) fields << "First Seen" << "Last Seen";
    eout << fields.join(QLatin1Char(',')) << '\n';

    // Device list
    for (const DeviceToolBLEx *d: std::as_const(devices))
    {
        fields = { csvField(d->getAddr_display()), csvField(d->getName_display()) };
        if (withManuf) fields << csvField(d->getManufacturer());
        if (withComment) fields << csvField(d->getUserComment());
        if (withSeen) fields << csvDate(d->getFirstSeen()) << csvDate(d->getLastSeen());
        eout << fields.join(QLatin1Char(',')) << '\n';
    }

    eout.flush();
    if (eout.status() != QTextStream::Ok || !efile.commit())
    {
        qWarning() << "DeviceManager::exportResults() cannot write" << exportFilePath << ":" << efile.errorString();
        return false;
    }

    qDebug() << "DeviceManager::exportResults(" << exportFilePath << ")";
    return true;
}

/* ************************************************************************** */

bool DeviceManager::getExportFile(QString &filename) const
{
    bool status = false;

    // No path given by the UI? Generate a "default" path
    if (filename.isEmpty())
    {
        filename = SettingsManager::getInstance()->getExportDirectory_str();
        filename += "/devicelist_";
        filename += QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm");
        filename += ".csv";
    }

    // Check if the directory exist, or try to create it
    QDir exportDirectory = QFileInfo(filename).dir();
    if (!exportDirectory.exists())
    {
        exportDirectory.mkpath(exportDirectory.path());
    }

    if (exportDirectory.exists())
    {
        status = true;
    }
    else
    {
        filename.clear();
        status = false;
    }

    return status;
}

/* ************************************************************************** */
