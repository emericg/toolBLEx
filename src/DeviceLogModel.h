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

#ifndef DEVICE_LOG_MODEL_H
#define DEVICE_LOG_MODEL_H
/* ************************************************************************** */

#include <QObject>
#include <QAbstractListModel>

class LogEvent;

class DeviceLogModel : public QAbstractListModel
{
    Q_OBJECT

    QList <LogEvent *> m_log;
    int m_max_log_entries = 1024;

public:
    enum Roles {
        TimestampRole = Qt::UserRole+1,
        EventRole,
        LogRole
    };

    explicit DeviceLogModel(int max_log_entries = 1024, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void append(LogEvent *event);
    void clear();
};

/* ************************************************************************** */
#endif // DEVICE_LOG_MODEL_H
