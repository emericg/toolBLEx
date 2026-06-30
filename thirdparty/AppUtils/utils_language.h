/*!
 * Copyright (c) 2020 Emeric Grange
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

#ifndef UTILS_LANGUAGE_H
#define UTILS_LANGUAGE_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QString>
#include <QStringList>
#include <QList>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

class UtilsLanguage : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QString m_appName;
    QString m_appLanguage;

    QString m_locale_str_full;
    QString m_locale_str_short;

    QString m_translation_prefix;

    QCoreApplication *m_qt_app = nullptr;
    QQmlApplicationEngine *m_qml_engine = nullptr;

    QTranslator *m_qtTranslator = nullptr;
    QTranslator *m_appTranslator = nullptr;

    QStringList m_extraCatalogs;
    QList<QTranslator *> m_extraTranslators;

    // Singleton
    explicit UtilsLanguage(QObject *parent = nullptr);

public:
    static UtilsLanguage *getInstance();
    static UtilsLanguage *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    void setAppName(const QString &name, const bool forceLowerCase = false);
    void setAppInstance(QCoreApplication *app);
    void setTranslationPrefix(const QString &prefix);
    void setQmlEngine(QQmlApplicationEngine *engine);

    /*!
     * \brief Register extra catalogs.
     * \param catalog: The catalog name.
     *
     * Register extra catalogs (":/<prefix>/<catalog>_<locale>.qm") from libraries or
     * QML modules shipping their own translations, to be installed together with
     * the application translation.
     */
    void addTranslationCatalog(const QString &catalog);

    Q_INVOKABLE void loadLanguage(const QString &lng);

    Q_INVOKABLE QString getCurrentLanguage() const { return m_appLanguage; }
    Q_INVOKABLE QString getCurrentLanguageCode_full() const { return m_locale_str_full; }
    Q_INVOKABLE QString getCurrentLanguageCode_short() const { return m_locale_str_short; }
};

/* ************************************************************************** */
#endif // UTILS_LANGUAGE_H
