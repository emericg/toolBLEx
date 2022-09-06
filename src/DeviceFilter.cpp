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
 * \date      2020
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DeviceFilter.h"
#include "SettingsManager.h"

#include "device.h"
#include "device_toolbox.h"

#include <cstdlib>
#include <cmath>

#include <QDebug>

/* ************************************************************************** */

DeviceFilter::DeviceFilter(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    updateBoolFilters();
}

DeviceFilter::~DeviceFilter()
{
    //
}

void DeviceFilter::updateBoolFilters()
{
    sm = SettingsManager::getInstance();
    if (sm)
    {
        m_filterShowBeacon = sm->getScanShowBeacon();
        m_filterShowBlacklisted = sm->getScanShowBlacklisted();
        m_filterShowCached = sm->getScanShowCached();
        m_filterShowBluetoothClassic = sm->getScanShowClassic();
        m_filterShowBluetoothLowEnergy = sm->getScanShowLowEnergy();
    }
}

/* ************************************************************************** */

bool DeviceFilter::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    bool accepted = false;

    Q_UNUSED(sourceRow)
    Q_UNUSED(sourceParent)

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);

    if (m_filterString.isEmpty())
    {
        accepted = true;
    }
    else
    {
        QString address = sourceModel()->data(index, DeviceModel::DeviceAddressRole).toString();
        if (address.contains(m_filterString, Qt::CaseInsensitive)) accepted = true;

        QString name = sourceModel()->data(index, DeviceModel::DeviceNameRole).toString();
        if (name.contains(m_filterString, Qt::CaseInsensitive)) accepted = true;

        QString manufacturer = sourceModel()->data(index, DeviceModel::DeviceManufacturerRole).toString();
        if (manufacturer.contains(m_filterString, Qt::CaseInsensitive)) accepted = true;

        //QString model = sourceModel()->data(index, DeviceModel::DeviceModelRole).toString();
        //if (model.contains(m_filterString, Qt::CaseInsensitive)) accepted = true;
    }

    DeviceToolBLEx *d = static_cast<DeviceToolBLEx *>(static_cast<DeviceModel *>(sourceModel())->device(index));
    if (d)
    {
        if (!m_filterShowBluetoothClassic && d->isBluetoothClassic() && !d->isBluetoothLowEnergy()) accepted = false;
        if (!m_filterShowBluetoothLowEnergy && d->isBluetoothLowEnergy() && !d->isBluetoothClassic()) accepted = false;

        if (!m_filterShowBeacon && d->isBeacon()) accepted = false;
        if (!m_filterShowBlacklisted && d->isBlacklisted()) accepted = false;
        if (!m_filterShowCached && d->isCached()) accepted = false;
    }

    return accepted;
}

/* ************************************************************************** */
/* ************************************************************************** */

DeviceModel::DeviceModel(QObject *parent)
    : QAbstractListModel(parent)
{
    //
}

DeviceModel::DeviceModel(const DeviceModel &other, QObject *parent)
    : QAbstractListModel(parent)
{
    m_devices = other.m_devices;
}

DeviceModel::~DeviceModel()
{
    qDeleteAll(m_devices);
    m_devices.clear();
}

/* ************************************************************************** */

QHash <int, QByteArray> DeviceModel::roleNames() const
{
    QHash <int, QByteArray> roles;

    roles[DeviceAddressRole] = "address";
    roles[DeviceNameRole] = "name";
    roles[DeviceManufacturerRole] = "manufacturer";
    roles[DeviceRssiRole] = "rssi";
    roles[DeviceIntervalRole] = "interval";
    roles[DeviceFirstSeenRole] = "first seen";
    roles[DeviceLastSeenRole] = "last seen";

    roles[DeviceModelRole] = "model";

    roles[PointerRole] = "pointer";

    return roles;
}

int DeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_devices.count();
}

int DeviceModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 6;
}

Device * DeviceModel::device(const QModelIndex &index) const
{
    return m_devices[index.row()];
}

QVariant DeviceModel::data(const QModelIndex &index, int role) const
{
    //qDebug() << "DeviceModel::data(r:" << index.row() << "c:" << index.column();

    if (index.row() < 0 || index.row() >= m_devices.size() || !index.isValid())
        return QVariant();

    DeviceToolBLEx *device = static_cast<DeviceToolBLEx *>(m_devices[index.row()]);
    if (device)
    {
        if (role == DeviceAddressRole)
        {
            return device->getAddress();
        }
        if (role == DeviceNameRole)
        {
            return device->getName();
        }
        if (role == DeviceManufacturerRole)
        {
            return device->getManufacturer();
        }
        if (role == DeviceModelRole)
        {
            return device->getModel();
        }
        if (role == DeviceRssiRole)
        {
            return std::abs(device->getRssi());
        }
        if (role == DeviceIntervalRole)
        {
            return device->getAdvertisementInterval();
        }
        if (role == DeviceFirstSeenRole)
        {
            return 0;
        }
        if (role == DeviceLastSeenRole)
        {
            return 0;
        }

        if (role == PointerRole)
            return QVariant::fromValue(device);

        // If we made it here...
        qWarning() << "Ooops missing DeviceModel role !!! " << role;
    }

    return QVariant();
}

void DeviceModel::getDevices(QList<Device *> &device)
{
    for (auto d: qAsConst(m_devices))
    {
        device.push_back(d);
    }
}

void DeviceModel::addDevice(Device *d)
{
    if (d)
    {
        beginInsertRows(QModelIndex(), getDeviceCount(), getDeviceCount());
        m_devices.push_back(d);
        endInsertRows();
    }
}

void DeviceModel::removeDevice(Device *d)
{
    if (d)
    {
        beginRemoveRows(QModelIndex(), m_devices.indexOf(d), m_devices.indexOf(d));
        m_devices.removeOne(d);
        delete d;
        endRemoveRows();
    }
}

void DeviceModel::sanetize()
{
    //
}

/* ************************************************************************** */
