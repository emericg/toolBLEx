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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceLogModel.h"

#include "device_utils.h"

/* ************************************************************************** */

DeviceLogModel::DeviceLogModel(int max_log_entries, QObject *parent) : QAbstractListModel(parent)
{
    m_max_log_entries = max_log_entries;
}

/* ************************************************************************** */

QVariant DeviceLogModel::data(const QModelIndex &index, int role) const
{
    LogEvent *e = m_log[index.row()];
    switch (role)
    {
        case Default: return index.row();

        case TimestampRole: return e->getTimestamp();
        case EventRole: return e->getEvent();
        case LogRole: return e->getLog();
    }

    return QVariant();
}

int DeviceLogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_log.count());
}

QHash <int, QByteArray> DeviceLogModel::roleNames() const
{
    return {
        { Default, "default" },
        { TimestampRole, "timestamp" },
        { EventRole, "event" },
        { LogRole, "log" }
    };
}

/* ************************************************************************** */

void DeviceLogModel::append(LogEvent *event)
{
    int rows = m_log.size();

    if (rows >= m_max_log_entries)
    {
        beginRemoveRows({}, 0, 0);
        delete m_log.takeFirst();
        endRemoveRows();
        rows -= 1;
    }

    beginInsertRows({}, rows, rows);
    m_log.append(event);
    endInsertRows();
}

void DeviceLogModel::clear()
{
    if (m_log.isEmpty()) return;

    beginResetModel();
    qDeleteAll(m_log);
    m_log.clear();
    endResetModel();
}

/* ************************************************************************** */

