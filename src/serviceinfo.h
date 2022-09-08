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
 * \date      2022
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef SERVICE_INFO_H
#define SERVICE_INFO_H
/* ****************************************************************************/

#include <QtBluetooth/QLowEnergyService>

/* ****************************************************************************/

class ServiceInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString serviceName READ getName NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceUuid READ getUuid NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceUuidFull READ getUuidFull NOTIFY serviceUpdated)
    Q_PROPERTY(QString serviceType READ getType NOTIFY serviceUpdated)

    Q_PROPERTY(QVariant characteristicList READ getCharacteristics NOTIFY characteristicsUpdated)

    QLowEnergyService *m_service = nullptr;

    QList <QObject *> m_characteristics;
    QVariant getCharacteristics() { return QVariant::fromValue(m_characteristics); }

    void connectToService();

Q_SIGNALS:
    void serviceUpdated();
    void characteristicsUpdated();

private slots:
    void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

public:
    ServiceInfo() = default;
    ServiceInfo(QLowEnergyService *service);
    ~ServiceInfo();

    const QLowEnergyService *service() const;
    const QList<QObject *> characteristics() const;

    QString getUuid() const;
    QString getUuidFull() const;
    QString getName() const;
    QString getType() const;
};

/* ****************************************************************************/
#endif // SERVICE_INFO_H
