/*!
 * Copyright (c) 2026 Emeric Grange
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

#include "FpsMonitor.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QDebug>

/* ************************************************************************** */

FpsMonitor *FpsMonitor::getInstance()
{
    static FpsMonitor *instance = new FpsMonitor(QCoreApplication::instance());
    return instance;
}

FpsMonitor *FpsMonitor::create(QQmlEngine *, QJSEngine *)
{
    FpsMonitor *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

FpsMonitor::FpsMonitor(QObject *parent) : QObject(parent)
{
    m_clock.start();

    m_refreshTimer.setInterval(250);
    connect(&m_refreshTimer, &QTimer::timeout, this, &FpsMonitor::refresh);

    // The application window may not exist yet, or be replaced later, so track it through focus changes
    connect(qApp, &QGuiApplication::focusWindowChanged, this, [this](QWindow *) { refreshWindow(); });
    refreshWindow();
}

/* ************************************************************************** */

/*!
 * \brief Tell whether a window can be monitored.
 * \param window: the window to check (may be nullptr).
 * \return the window as a top-level, regular QQuickWindow (not a popup, tooltip, dialog...), or nullptr.
 */
static QQuickWindow *asApplicationWindow(QWindow *window)
{
    if (window && window->isTopLevel() && window->type() == Qt::Window)
    {
        return qobject_cast<QQuickWindow *>(window);
    }

    return nullptr;
}

void FpsMonitor::refreshWindow()
{
    QQuickWindow *window = asApplicationWindow(QGuiApplication::focusWindow());

    // No focus window while the application is in the background, keep monitoring the current one
    if (!window) window = m_window;

    if (!window)
    {
        const QWindowList windows = QGuiApplication::topLevelWindows();
        for (QWindow *w : windows)
        {
            QQuickWindow *qw = asApplicationWindow(w);
            if (qw && qw->isVisible())
            {
                window = qw;
                break;
            }
        }
    }

    if (window == m_window) return;

    QObject::disconnect(m_frameConnection);
    m_window = window;

    if (!m_window)
    {
        qWarning() << "FpsMonitor::refreshWindow() No QQuickWindow available";
    }

    reset();
    refreshConnection();
    Q_EMIT windowChanged();
}

void FpsMonitor::refreshConnection()
{
    QObject::disconnect(m_frameConnection);

    if (m_active && m_window)
    {
        // Emitted from the render thread (threaded render loop), queued to this thread
        m_frameConnection = connect(m_window, &QQuickWindow::frameSwapped,
                                    this, &FpsMonitor::registerSample, Qt::QueuedConnection);
    }
}

/* ************************************************************************** */

void FpsMonitor::setActive(bool active)
{
    if (active == m_active) return;

    m_active = active;
    if (!m_active) reset();
    refreshConnection();

    Q_EMIT activeChanged();
}

/* ************************************************************************** */

void FpsMonitor::registerSample()
{
    if (!m_active) return; // a queued sample may arrive after the monitor was disabled

    m_timestamps.append(m_clock.elapsed());
    refresh();

    if (!m_refreshTimer.isActive()) m_refreshTimer.start();
}

void FpsMonitor::refresh()
{
    const qint64 now = m_clock.elapsed();

    qsizetype expired = 0;
    while (expired < m_timestamps.size() && now - m_timestamps.at(expired) > 1000) expired++;
    m_timestamps.remove(0, expired);

    if (m_timestamps.isEmpty()) m_refreshTimer.stop();

    const int fps = static_cast<int>(m_timestamps.size());
    if (fps != m_fps)
    {
        m_fps = fps;
        Q_EMIT fpsChanged();
    }
}

void FpsMonitor::reset()
{
    m_refreshTimer.stop();
    m_timestamps.clear();

    if (m_fps != 0)
    {
        m_fps = 0;
        Q_EMIT fpsChanged();
    }
}

/* ************************************************************************** */
