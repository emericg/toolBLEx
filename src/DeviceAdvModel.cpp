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

#include "DeviceAdvModel.h"
#include "device_utils.h"

/* ************************************************************************** */
/* ************************************************************************** */

AdvertisementDataModel::AdvertisementDataModel(QObject *parent)
    : QAbstractListModel(parent)
{
    //
}

AdvertisementDataModel::~AdvertisementDataModel()
{
    clear();
}

/* ************************************************************************** */

int AdvertisementDataModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return static_cast<int>(m_advertisements.size());
}

int AdvertisementDataModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return 1;
}

QVariant AdvertisementDataModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_advertisements.size() || !index.isValid())
        return QVariant();

    AdvertisementData *adv = m_advertisements.at(index.row());
    if (adv)
    {
        switch (static_cast<AdvertisementDataRoles>(role))
        {
            case Default: return index.row();
            case AdvertisementDataRole: return QVariant::fromValue(adv);

            case TimestampRole: return adv->getTimestamp();
            case AdvModeRole: return adv->getMode();
            case AdvUUIDRole: return adv->getUUID_int();
            case AdvUUIDStrRole: return adv->getUUID_str();
            case AdvUUIDVendorRole: return adv->getUUID_vendor();
            case AdvDataHexRole: return adv->getDataHex();
            case AdvDataHexListRole: return adv->getDataHex_list();
            case AdvDataAsciiRole: return adv->getDataAscii();
            case AdvDataAsciiListRole: return adv->getDataAscii_list();
            case AdvDataSizeRole: return adv->getDataSize();
        }
    }

    return QVariant();
}

QHash <int, QByteArray> AdvertisementDataModel::roleNames() const
{
    return {
        { Default, "default" },
        { AdvertisementDataRole, "advertisementData" },
        { TimestampRole, "timestamp" },
        { AdvModeRole, "advMode" },
        { AdvUUIDRole, "advUUID" },
        { AdvUUIDStrRole, "advUUIDstr" },
        { AdvUUIDVendorRole, "advUUIDvendor" },
        { AdvDataHexRole, "advDataHex" },
        { AdvDataHexListRole, "advDataHex_list" },
        { AdvDataAsciiRole, "advDataAscii" },
        { AdvDataAsciiListRole, "advDataAscii_list" },
        { AdvDataSizeRole, "advDataSize" },
    };
}

/* ************************************************************************** */

bool AdvertisementDataModel::addEntry(AdvertisementData *entry)
{
    if (!entry) return false;

    // Is it a duplicate entry?
    AdvertisementData *last = m_advertisements_latest.value({ entry->getMode(), entry->getUUID_int() }, nullptr);
    if (last && last->compare(entry->getDataBA()))
    {
        delete entry;
        return false;
    }

    // Re-parent so the model owns the object
    entry->setParent(this);

    // Add it to the model
    const int row = m_advertisements.size();
    beginInsertRows(QModelIndex(), row, row);
    m_advertisements.append(entry);
    endInsertRows();

    // To count svd/mfd
    if (entry->getMode() == DeviceUtils::BLE_ADV_SERVICEDATA) m_advertisements_svd.append(entry);
    else if (entry->getMode() == DeviceUtils::BLE_ADV_MANUFACTURERDATA) m_advertisements_mfd.append(entry);

    // To get the latest svd/mfd (per uuid)
    const QPair<uint16_t, uint16_t> key { static_cast<uint16_t>(entry->getMode()), entry->getUUID_uint() };
    m_advertisements_latest.insert(key, entry); // insert() replaces an existing key
    Q_EMIT latestEntriesChanged();

    return true;
}

bool AdvertisementDataModel::addEntry(uint16_t mode, uint16_t uuid,
                                      const QByteArray &data,
                                      const QDateTime &timestamp)
{
    return addEntry(new AdvertisementData(mode, uuid, data, timestamp, this));
}

void AdvertisementDataModel::clear()
{
    if (m_advertisements.isEmpty()) return;

    beginResetModel();
    qDeleteAll(m_advertisements);
    m_advertisements.clear();
    m_advertisements_mfd.clear();
    m_advertisements_svd.clear();
    m_advertisements_latest.clear();
    endResetModel();

    Q_EMIT latestEntriesChanged();
}

/* ************************************************************************** */

AdvertisementData *AdvertisementDataModel::latestEntry(uint16_t mode, uint16_t uuid) const
{
    return m_advertisements_latest.value({ mode, uuid }, nullptr);
}

AdvertisementData *AdvertisementDataModel::latestEntry(int mode, int uuid) const
{
    return latestEntry(static_cast<uint16_t>(mode), static_cast<uint16_t>(uuid));
}

QVariantList AdvertisementDataModel::latestEntriesVariant_svd() const
{
    QVariantList out;
    //out.reserve(m_advertisements_latest.size());

    for (AdvertisementData *entry: std::as_const(m_advertisements_latest))
    {
        if (entry->getMode() == DeviceUtils::BLE_ADV_SERVICEDATA)
        {
            out.append(QVariant::fromValue(entry));
        }
    }

    return out;
}

QVariantList AdvertisementDataModel::latestEntriesVariant_mfd() const
{
    QVariantList out;
    //out.reserve(m_advertisements_latest.size());

    for (AdvertisementData *entry: std::as_const(m_advertisements_latest))
    {
        if (entry->getMode() == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
        {
            out.append(QVariant::fromValue(entry));
        }
    }

    return out;
}

/* ************************************************************************** */
/* ************************************************************************** */

AdvertisementFilterModel::AdvertisementFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    //
}

/* ************************************************************************** */

void AdvertisementFilterModel::setUuidSelected(uint16_t mode, uint16_t uuid, bool selected)
{
    if (selected)
    {
        if (mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
        {
            if (m_selectedUuids_mfd.contains(uuid)) return;
            m_selectedUuids_mfd.insert(uuid);
        }
        else if (mode == DeviceUtils::BLE_ADV_SERVICEDATA)
        {
            if (m_selectedUuids_svd.contains(uuid)) return;
            m_selectedUuids_svd.insert(uuid);
        }
    }
    else
    {
        if (mode == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
        {
            if (!m_selectedUuids_mfd.contains(uuid)) return;
            m_selectedUuids_mfd.remove(uuid);
        }
        else if (mode == DeviceUtils::BLE_ADV_SERVICEDATA)
        {
            if (!m_selectedUuids_svd.contains(uuid)) return;
            m_selectedUuids_svd.remove(uuid);
        }
    }

    invalidateFilter();
    Q_EMIT selectedUuidsChanged();
}

void AdvertisementFilterModel::setUuidSelected(int mode, int uuid, bool selected)
{
    setUuidSelected(static_cast<uint16_t>(mode), static_cast<uint16_t>(uuid), selected);
}

void AdvertisementFilterModel::syncUuid(AdvertisementUUID *uuidObj)
{
    if (uuidObj) setUuidSelected(uuidObj->getAdvMode(), uuidObj->getUuid(), uuidObj->getSelected());
}

/* ************************************************************************** */

bool AdvertisementFilterModel::isUnfiltered() const
{
    return (m_selectedUuids_svd.isEmpty() && m_selectedUuids_mfd.isEmpty());
}

void AdvertisementFilterModel::selectAll()
{
    if (!sourceModel()) return;

    // TODO

    if (changed)
    {
        invalidateFilter();
        Q_EMIT selectedUuidsChanged();
    }
}

void AdvertisementFilterModel::clearFilter()
{
    if (isUnfiltered()) return;
    m_selectedUuids_svd.clear();
    m_selectedUuids_mfd.clear();

    invalidateFilter();
    Q_EMIT selectedUuidsChanged();
}

/* ************************************************************************** */

bool AdvertisementFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (!sourceModel()) return false;

    const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    const uint16_t uuid = static_cast<uint16_t>(sourceModel()->data(index, AdvertisementDataModel::AdvUUIDRole).toUInt());

    if (sourceModel()->data(index, AdvertisementDataModel::AdvModeRole).toInt() == DeviceUtils::BLE_ADV_SERVICEDATA)
    {
        return m_selectedUuids_svd.contains(uuid);
    }
    else // if (sourceModel()->data(index, AdvertisementDataModel::AdvModeRole).toInt() == DeviceUtils::BLE_ADV_MANUFACTURERDATA)
    {
        return m_selectedUuids_mfd.contains(uuid);
    }
}

/* ************************************************************************** */
/* ************************************************************************** */
