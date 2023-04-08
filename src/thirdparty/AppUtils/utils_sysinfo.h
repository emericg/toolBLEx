/*!
 * Copyright (c) 2021 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
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
