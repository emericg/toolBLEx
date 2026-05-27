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

#ifndef DEVICE_ADV_MODEL_H
#define DEVICE_ADV_MODEL_H
/* ************************************************************************** */

#include "device_toolblex_adv.h"

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QList>
#include <QMap>
#include <QPair>

/* ************************************************************************** */

class AdvertisementDataModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QVariantList latestEntriesSvd READ latestEntriesVariant_svd NOTIFY latestEntriesChanged)
    Q_PROPERTY(QVariantList latestEntriesMfd READ latestEntriesVariant_mfd NOTIFY latestEntriesChanged)

public:
    AdvertisementDataModel(QObject *parent = nullptr);
    ~AdvertisementDataModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash <int, QByteArray> roleNames() const override;

    enum AdvertisementDataRoles {
        Default = Qt::UserRole+1,

        AdvertisementDataRole,
        TimestampRole,
        AdvModeRole,
        AdvUUIDRole,
        AdvUUIDStrRole,
        AdvUUIDVendorRole,
        AdvDataHexRole,
        AdvDataHexListRole,
        AdvDataAsciiRole,
        AdvDataAsciiListRole,
        AdvDataSizeRole,
    };
    Q_ENUM(AdvertisementDataRoles)

public:
    QList <AdvertisementData *> m_advertisements;

    QList <AdvertisementData *> m_advertisements_mfd;
    QList <AdvertisementData *> m_advertisements_svd;
    QMap <QPair<uint16_t, uint16_t>, AdvertisementData *> m_advertisements_latest;

    int getAdvertisementCount() const { return m_advertisements.count(); }
    int getAdvertisementMfdCount() const { return m_advertisements_mfd.count(); }
    int getAdvertisementSvdCount() const { return m_advertisements_svd.count(); }

    bool addEntry(AdvertisementData *entry);
    bool addEntry(uint16_t mode, uint16_t uuid, const QByteArray &data, const QDateTime &timestamp);
    void clear();

    Q_INVOKABLE AdvertisementData *latestEntry(uint16_t mode, uint16_t uuid) const;
    Q_INVOKABLE AdvertisementData *latestEntry(int mode, int uuid) const;

    QVariantList latestEntriesVariant_svd() const;
    QVariantList latestEntriesVariant_mfd() const;

Q_SIGNALS:
    void latestEntriesChanged();
};

/* ************************************************************************** */

class AdvertisementFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit AdvertisementFilterModel(QObject *parent = nullptr);
    ~AdvertisementFilterModel() override = default;

    Q_INVOKABLE void setUuidSelected(uint16_t mode, uint16_t uuid, bool selected);
    Q_INVOKABLE void setUuidSelected(int mode, int uuid, bool selected);
    Q_INVOKABLE void syncUuid(AdvertisementUUID *uuidObj);

    Q_INVOKABLE bool isUnfiltered() const;
    Q_INVOKABLE void selectAll(); // TODO
    Q_INVOKABLE void clearFilter();

Q_SIGNALS:
    void countChanged();
    void selectedUuidsChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    QSet <uint16_t> m_selectedUuids_svd;
    QSet <uint16_t> m_selectedUuids_mfd;
};

/* ************************************************************************** */
#endif // DEVICE_ADV_MODEL_H
