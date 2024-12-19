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

#ifndef UTILS_FPSMONITOR_H
#define UTILS_FPSMONITOR_H
/* ************************************************************************** */

#include <QObject>
#include <QList>
#include <QMutex>
#include <QDateTime>

class QTimer;
class QQuickWindow;

/* ************************************************************************** */

/*!
 * \brief The FrameRateMonitor class
 *
 * This class use the QQuickWindow::frameSwapped method from Luca Carlon.
 * - https://github.com/carlonluca/lqtutils/blob/master/lqtutils_freq.h
 *
 * The FrameMonitor widget uses a simpler and pure QML method from qnanopainter.
 * - https://github.com/QUItCoding/qnanopainter/blob/master/examples/qnanopainter_vs_qpainter_demo/qml/FpsItem.qml
 */
class FrameRateMonitor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int fps READ fps NOTIFY fpsChanged)

    QMutex m_mutex;
    QList <QDateTime> m_timestamps;
    QTimer *m_refreshTimer = nullptr;

    int m_fps = 0;
    int fps() const { return m_fps; }

Q_SIGNALS:
    void fpsChanged();

public:
    FrameRateMonitor(QQuickWindow *window = nullptr, QObject *parent = nullptr);
    Q_INVOKABLE void setQuickWindow(QQuickWindow *window);

public slots:
    void registerSample();
    void refresh();
};

/* ************************************************************************** */
#endif // UTILS_FPSMONITOR_H
