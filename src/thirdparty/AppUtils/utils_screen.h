/*!
 * Copyright (c) 2022 Emeric Grange
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

#ifndef UTILS_SCREEN_H
#define UTILS_SCREEN_H
/* ************************************************************************** */

#include <QObject>
#include <QVariantMap>

class QGuiApplication;
class QScreen;
class QQuickWindow;

/* ************************************************************************** */

/*!
 * \brief The UtilsScreen class
 */
class UtilsScreen: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int screenWidth READ getScreenWidth NOTIFY screenChanged)
    Q_PROPERTY(int screenHeight READ getScreenHeight NOTIFY screenChanged)
    Q_PROPERTY(int screenDepth READ getScreenDepth NOTIFY screenChanged)
    Q_PROPERTY(double screenRefreshRate READ getScreenRefreshRate NOTIFY screenChanged)
    Q_PROPERTY(int screenDpi READ getScreenDpi NOTIFY screenChanged)
    Q_PROPERTY(double screenPar READ getScreenPar NOTIFY screenChanged)
    Q_PROPERTY(double screenSize READ getScreenSize_inch NOTIFY screenChanged)

    int m_screenWidth = -1;
    int m_screenHeight = -1;
    int m_screenDepth = -1;
    double m_screenRefreshRate = -1.0;

    int m_screenDpi = -1;
    double m_screenPar = -1.0;
    double m_screenSizeInch = -1.0;

    uint32_t m_screensaverId = 0;

    int getScreenWidth() { return m_screenWidth; }
    int getScreenHeight() { return m_screenHeight; }
    int getScreenDepth() { return m_screenDepth; }
    double getScreenRefreshRate() { return m_screenRefreshRate; }

    int getScreenDpi() { return m_screenDpi; }
    double getScreenPar() { return m_screenPar; }
    double getScreenSize_inch() { return m_screenSizeInch; }

    QVariantMap getSafeAreaMargins(QQuickWindow *window); // DEPRECATED

    // Actual screen
    const QScreen *m_scr = nullptr;

    // Singleton
    static UtilsScreen *instance;
    UtilsScreen();
    ~UtilsScreen();

Q_SIGNALS:
    void screenChanged();

public slots:
    void getScreenInfos(const QScreen *scr);

public:
    static UtilsScreen *getInstance();

    Q_INVOKABLE void printScreenInfos();

    /*!
     * \brief Screen saver inhibitor.
     * \param on: keep screen on or off.
     * \param application: the name of the application requesting to disable screensaver.
     * \param explanation: the reason why the application is requesting to disable screensaver.
     */
    Q_INVOKABLE void keepScreenOn(bool on,
                                  const QString &application = QString(),
                                  const QString &explanation = QString());

    /*!
     * \brief Simple orientation locker.
     * \param orientation: 0 for portrait, 1 for landscape.
     */
    Q_INVOKABLE void lockScreenOrientation(int orientation);

    enum ScreenOrientation {
        ScreenOrientation_UNLOCKED = 0,

        ScreenOrientation_PORTRAIT              = (1 << 0),
        ScreenOrientation_PORTRAIT_UPSIDEDOWN   = (1 << 1),
        ScreenOrientation_LANDSCAPE             = (1 << 2),
        ScreenOrientation_LANDSCAPE_LEFT        = (1 << 3),
    };
    Q_ENUM(ScreenOrientation)

    /*!
     * \brief Complex orientation locker.
     * \note Work in progress.
     * \param orientation: see ScreenOrientation enum.
     * \param autoRotate: false to disable auto-rotation completely, true to let some degree of auto-rotation.
     *
     * You can also achieve similar functionality through application manifest or plist:
     * - https://developer.android.com/guide/topics/manifest/activity-element.html#screen
     * - https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportedinterfaceorientations
     */
    Q_INVOKABLE void lockScreenOrientation(UtilsScreen::ScreenOrientation orientation, bool autoRotate);
};

/* ************************************************************************** */
#endif // UTILS_SCREEN_H
