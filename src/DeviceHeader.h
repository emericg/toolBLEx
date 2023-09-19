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
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_HEADER_H
#define DEVICE_HEADER_H
/* ************************************************************************** */

#include <QObject>


/* ************************************************************************** */

/*!
 * \brief The DeviceHeader class
 */
class DeviceHeader: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int width READ getWidth NOTIFY widthChanged)

    Q_PROPERTY(int margin READ getMargin CONSTANT)
    Q_PROPERTY(int spacing READ getSpacing CONSTANT)
    Q_PROPERTY(int minSize READ getMinSize CONSTANT)
    Q_PROPERTY(int maxSize READ getMaxSize CONSTANT)

    Q_PROPERTY(int colColor READ getColColor CONSTANT)
    Q_PROPERTY(int colAddress READ getColAddr WRITE setColAddr NOTIFY colAddrChanged)
    Q_PROPERTY(int colName READ getColName WRITE setColName NOTIFY colNameChanged)
    Q_PROPERTY(int colManuf READ getColManuf WRITE setColManuf NOTIFY colManufChanged)
    Q_PROPERTY(int colRssi READ getColRssi WRITE setColRssi NOTIFY colRssiChanged)
    Q_PROPERTY(int colInterval READ getColInterval WRITE setColInterval NOTIFY colIntervalChanged)
    Q_PROPERTY(int colFirstSeen READ getColFirstSeen WRITE setColSeen NOTIFY colRssiChanged)
    Q_PROPERTY(int colLastSeen READ getColLastSeen WRITE setColSeen NOTIFY colSeenChanged)

    int m_margin = 12;
    int m_spacing = 16;
    int m_minSize = 16;
    int m_maxSize = 256;

    int m_color = 12;
    int m_addr = 180;
    int m_name = 220;
    int m_manuf = 220;
    int m_rssi = 180;
    int m_interval = 100;
    int m_firstseen = 100;
    int m_lastseen = 100;

Q_SIGNALS:
    void widthChanged();
    void colAddrChanged();
    void colNameChanged();
    void colManufChanged();
    void colRssiChanged();
    void colIntervalChanged();
    void colSeenChanged();

public:
    DeviceHeader(QObject *parent = nullptr): QObject(parent) {}
    ~DeviceHeader() = default;

    int getWidth() const {
        int w = m_margin*2 + m_spacing*5;
        w += m_color;
        w += m_name;
#if !defined(Q_OS_MACOS)
        w += m_spacing*2;
        w += m_addr;
        w += m_manuf;
#endif
        w += m_rssi;
        w += m_interval;
        w += m_firstseen;
        w += m_lastseen;
        return w;
    };

    int getMargin() const { return m_margin; };
    int getSpacing() const { return m_spacing; };
    int getMinSize() const { return m_minSize; };
    int getMaxSize() const { return m_maxSize; };

    int getColColor() const { return m_color; };
    int getColAddr() const { return m_addr; };
    int getColName() const { return m_name; };
    int getColManuf() const { return m_manuf; };
    int getColRssi() const { return m_rssi; };
    int getColInterval() const { return m_interval; };
    int getColFirstSeen() const { return m_firstseen; };
    int getColLastSeen() const { return m_lastseen; };

    void setColAddr(int value) {
        if (value != m_addr) {
            if (value < m_minSize) value = m_minSize;
            if (value > 512) value = 512;
            m_addr = value;

            Q_EMIT colAddrChanged();
            Q_EMIT widthChanged();
        }
    }
    void setColName(int value) {
        if (value != m_name) {
            if (value < m_minSize) value = m_minSize;
            if (value > 512) value = 512;
            m_name = value;

            Q_EMIT colNameChanged();
            Q_EMIT widthChanged();
        }
    }
    void setColManuf(int value) {
        if (value != m_manuf) {
            if (value < m_minSize) value = m_minSize;
            if (value > 512) value = 512;
            m_manuf = value;

            Q_EMIT colManufChanged();
            Q_EMIT widthChanged();
        }
    }
    void setColRssi(int value) {
        if (value != m_rssi) {
            if (value < m_minSize) value = m_minSize;
            if (value > 256) value = 256;
            m_rssi = value;

            Q_EMIT colRssiChanged();
            Q_EMIT widthChanged();
        }
    }
    void setColInterval(int value) {
        if (value != m_interval) {
            if (value < m_minSize) value = m_minSize;
            if (value > 256) value = 256;
            m_interval = value;

            Q_EMIT colIntervalChanged();
            Q_EMIT widthChanged();
        }
    }
    void setColSeen(int value) {
        if (value != m_firstseen) {
            if (value < m_minSize) value = m_minSize;
            if (value > 256) value = 256;
            m_firstseen = value;
            m_lastseen = value;

            Q_EMIT colSeenChanged();
            Q_EMIT widthChanged();
        }
    }
};

/* ************************************************************************** */
#endif // DEVICE_HEADER_H
