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

#ifndef FPS_MONITOR_H
#define FPS_MONITOR_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QPointer>
#include <QList>
#include <QTimer>
#include <QElapsedTimer>
#include <QQuickWindow>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief Frame rate monitor singleton, shared between C++ and QML.
 *
 * Counts the QQuickWindow::frameSwapped() signals received during the last second.
 *
 * The monitored window is tracked automatically:
 * the focused application window, or the current one while there is no focus window
 * (application in the background), or the first visible top-level QQuickWindow.
 */
class FpsMonitor : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int fps READ getFps NOTIFY fpsChanged FINAL)
    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged FINAL)
    Q_PROPERTY(QQuickWindow *window READ getWindow NOTIFY windowChanged FINAL)

    bool m_active = true;
    int m_fps = 0;

    QPointer<QQuickWindow> m_window;
    QMetaObject::Connection m_frameConnection;

    //! Timestamps of the frames presented during the last second, in milliseconds since m_clock start.
    QList<qint64> m_timestamps;
    QElapsedTimer m_clock;

    //! Keeps refreshing the frame rate when the window stops rendering, so it decays to 0.
    QTimer m_refreshTimer;

    //! Get the monitored window (may be nullptr).
    QQuickWindow *getWindow() const { return m_window; }

    /*!
     * \brief Select the window to monitor.
     *
     * Prefers the focus window, then keeps the current one (there is no focus window while
     * the application is in the background), then falls back to the first visible top-level window.
     */
    void refreshWindow();

    //! Connect to (or disconnect from) the monitored window frameSwapped() signal, depending on m_active.
    void refreshConnection();

    //! Record a frame timestamp, then update the frame rate.
    void registerSample();

    //! Drop the timestamps older than one second, and update the frame rate.
    void refresh();

    //! Drop every timestamp, and reset the frame rate.
    void reset();

    // Singleton
    explicit FpsMonitor(QObject *parent = nullptr);

Q_SIGNALS:
    void fpsChanged();      //!< Emitted when the frame rate changes.
    void activeChanged();   //!< Emitted when the monitor is enabled or disabled.
    void windowChanged();   //!< Emitted when the monitored window changes.

public:
    static FpsMonitor *getInstance();
    static FpsMonitor *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    /*!
     * \brief Get the number of frames presented by the monitored window during the last second.
     * \return the frame rate, or 0 while inactive or without a window.
     */
    int getFps() const { return m_fps; }

    /*!
     * \brief Tell whether the monitor is counting frames.
     */
    bool isActive() const { return m_active; }

    /*!
     * \brief Enable or disable the monitor.
     * \param active: true to count frames (default), false to stop listening to the window.
     *
     * While inactive, the monitored window is still tracked, but its frames are not counted.
     */
    void setActive(bool active);
};

/* ************************************************************************** */
#endif // FPS_MONITOR_H
