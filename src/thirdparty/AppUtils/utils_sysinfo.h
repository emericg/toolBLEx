/*!
 * COPYRIGHT (C) 2022 Emeric Grange - All Rights Reserved
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
 * \date      2021
 */

#ifndef UTILS_SYSINFO_H
#define UTILS_SYSINFO_H
/* ************************************************************************** */

#include <QObject>
#include <QVariantMap>

/* ************************************************************************** */

/*!
 * \brief The UtilsSysinfo class
 */
class UtilsSysinfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString cpu_arch READ getCpuArch CONSTANT)
    Q_PROPERTY(int cpu_coreCount_physical READ getCpuCoreCountPhysical CONSTANT)
    Q_PROPERTY(int cpu_coreCount_logical READ getCpuCoreCountLogical CONSTANT)
    Q_PROPERTY(quint64 ram_total READ getRamTotal CONSTANT)
    Q_PROPERTY(QString os_name READ getOs CONSTANT)

    QString m_cpu_arch;
    int m_cpu_core_physical = 0;
    int m_cpu_core_logical = 0;

    uint64_t m_ram_total = 0;

    QString m_os_name;

    // Singleton
    static UtilsSysinfo *instance;
    UtilsSysinfo();
    ~UtilsSysinfo();

    void getCpuInfos();
    void getRamInfos();

public:
    static UtilsSysinfo *getInstance();

    void printInfos();

    Q_INVOKABLE QString getCpuArch() const { return m_cpu_arch; };

    Q_INVOKABLE int getCpuCoreCountPhysical() const { return m_cpu_core_physical; };

    Q_INVOKABLE int getCpuCoreCountLogical() const { return m_cpu_core_logical; };

    Q_INVOKABLE uint64_t getRamTotal() const  { return m_ram_total; };

    Q_INVOKABLE QString getOs() const { return m_os_name; };
};

/* ************************************************************************** */
#endif // UTILS_SYSINFO_H
