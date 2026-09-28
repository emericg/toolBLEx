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

#ifndef LOREM_IPSUM_H
#define LOREM_IPSUM_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>

class QQmlEngine;
#include <QCoreApplication>
#include <QQmlEngine>
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The LoremIpsum class
 */
class LoremIpsum: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString title READ getTitle CONSTANT)
    Q_PROPERTY(QString subtitle READ getSubTitle CONSTANT)
    Q_PROPERTY(QString sentence READ getSentence CONSTANT)
    Q_PROPERTY(QString paragraph READ getParagraph CONSTANT)

    QString m_title = "Lorem Ipsum";
    QString m_subtitle = "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...";

    QString m_sentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.";

    QString m_paragraph = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. "
                          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
                          "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    QString m_paragraph2 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                           "Integer mollis porttitor elit vitae auctor. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; "
                           "Vestibulum consequat purus vel massa fermentum feugiat. Proin sed magna sed tortor egestas consectetur. Nunc auctor eros id dignissim molestie. "
                           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi in diam nec mi vehicula semper sed ut turpis. Suspendisse vitae consectetur elit. "
                           "Etiam nec justo in eros ultricies pharetra eget ac justo.";

    QString m_paragraph3 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                           "Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. "
                           "Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. "
                           "Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. "
                           "Ad litora torquent per conubia nostra inceptos himenaeos.";

    explicit LoremIpsum(QObject *parent = nullptr) { };

public:
    static LoremIpsum *getInstance() {
        static LoremIpsum *instance = new LoremIpsum(QCoreApplication::instance());
        return instance;
    }
    static LoremIpsum *create(QQmlEngine *engine, QJSEngine *scriptEngine) {
        LoremIpsum *instance = getInstance();
        QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
        return instance;
    }

    Q_INVOKABLE QString getTitle() const { return m_title; }
    Q_INVOKABLE QString getSubTitle() const { return m_subtitle; }
    Q_INVOKABLE QString getSentence() const { return m_sentence; }
    Q_INVOKABLE QString getParagraph() const { return m_paragraph; }
};

/* ************************************************************************** */
#endif // LOREM_IPSUM_H
