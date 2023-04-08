/*!
 * Copyright (c) 2022 Luca Carlon
 * Copyright (c) 2023 Emeric Grange
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

#include "utils_fpsmonitor.h"

#include <QMutableListIterator>
#include <QQuickWindow>
#include <QTimer>
#include <QDebug>

/* ************************************************************************** */

FrameRateMonitor::FrameRateMonitor(QQuickWindow *window, QObject *parent) : QObject(parent)
{
    setWindow(window);

    m_refreshTimer = new QTimer(this);
    connect(m_refreshTimer, &QTimer::timeout, this, &FrameRateMonitor::refresh);

    m_refreshTimer->setInterval(1000);
    m_refreshTimer->setSingleShot(true);
}

/* ************************************************************************** */

void FrameRateMonitor::setWindow(QQuickWindow *window)
{
    if (window)
    {
        connect(window, &QQuickWindow::frameSwapped, this, &FrameRateMonitor::registerSample);
    }
    else
    {
        qWarning() << "FrameRateMonitor::setWindow() No QQuickWindow available";
    }
}

void FrameRateMonitor::registerSample()
{
    QMutexLocker locker(&m_mutex);
    m_timestamps.append(QDateTime::currentDateTime());
    QTimer::singleShot(0, this, &FrameRateMonitor::refresh);
}

void FrameRateMonitor::refresh()
{
    QMutexLocker locker(&m_mutex);
    QDateTime now = QDateTime::currentDateTime();

    QMutableListIterator <QDateTime> it(m_timestamps);
    while (it.hasNext()) {
        if (it.next().msecsTo(now) > 1000) {
            it.remove();
        } else {
            break;
        }
    }

    m_fps = m_timestamps.size();
    Q_EMIT fpsChanged();

    m_refreshTimer->start();
}

/* ************************************************************************** */
