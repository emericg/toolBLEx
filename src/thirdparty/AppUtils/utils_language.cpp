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

#include "utils_language.h"

#include <QCoreApplication>
#include <QLibraryInfo>
#include <QTranslator>
#include <QLocale>
#include <QDebug>

/* ************************************************************************** */

UtilsLanguage *UtilsLanguage::instance = nullptr;

UtilsLanguage *UtilsLanguage::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsLanguage();
    }

    return instance;
}

UtilsLanguage::UtilsLanguage()
{
    // Set a default application name and instance
    m_appName = QCoreApplication::applicationName().toLower();
    m_qt_app = QCoreApplication::instance();
}

UtilsLanguage::~UtilsLanguage()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void UtilsLanguage::setAppName(const QString &name)
{
    m_appName = name;
}

void UtilsLanguage::setAppInstance(QCoreApplication *app)
{
    m_qt_app = app;
}

void UtilsLanguage::setQmlEngine(QQmlApplicationEngine *engine)
{
    m_qml_engine = engine;
}

/* ************************************************************************** */

void UtilsLanguage::loadLanguage(const QString &lng)
{
    //qDebug() << "UtilsLanguage::loadLanguage(" << lng << ")";

    if (!m_qt_app) return;
    if (m_appLanguage == lng) return;

    // Remove old language
    if (m_qtTranslator)
    {
        m_qt_app->removeTranslator(m_qtTranslator);
        delete m_qtTranslator;
    }
    if (m_appTranslator)
    {
        m_qt_app->installTranslator(m_appTranslator);
        delete m_appTranslator;
    }

    QString locale_str_full;
    QString locale_str_short;

    m_appLanguage = lng;
    if (m_appLanguage == "Chinese (traditional)") locale_str_full = "zh_TW";
    else if (m_appLanguage == "Chinese (simplified)") locale_str_full = "zh_CN";
    else if (m_appLanguage == "Dansk") locale_str_full = "da_DK";
    else if (m_appLanguage == "Deutsch") locale_str_full = "de_DE";
    else if (m_appLanguage == "English") locale_str_full = "en_EN";
    else if (m_appLanguage == "Español") locale_str_full = "es_ES";
    else if (m_appLanguage == "Français") locale_str_full = "fr_FR";
    else if (m_appLanguage == "Frysk") locale_str_full = "fy_NL";
    else if (m_appLanguage == "Nederlands") locale_str_full = "nl_NL";
    else if (m_appLanguage == "Norsk (Bokmål)") locale_str_full = "nb_NO";
    else if (m_appLanguage == "Norsk (Nynorsk)") locale_str_full = "nn_NO";
    else if (m_appLanguage == "Pусский") locale_str_full = "ru_RU";
    else
    {
        locale_str_full = QLocale::system().name();
        m_appLanguage = "auto";
    }

    locale_str_short = locale_str_full;
    locale_str_short.truncate(locale_str_full.lastIndexOf('_'));

    QLocale locale(locale_str_full);
    QLocale::setDefault(locale);

#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
    QString translationpath = QLibraryInfo::path(QLibraryInfo::TranslationsPath);
#else
    QString translationpath = QLibraryInfo::location(QLibraryInfo::TranslationsPath);
#endif

    m_qtTranslator = new QTranslator;
    if (m_qtTranslator)
        if (m_qtTranslator->load("qt_" + locale_str_full, translationpath))
            m_qt_app->installTranslator(m_qtTranslator);

    m_appTranslator = new QTranslator;
    if (m_qtTranslator)
        if (m_appTranslator->load(":/i18n/" + m_appName + "_" + locale_str_full + ".qm"))
            m_qt_app->installTranslator(m_appTranslator);

    // Install new language
    if (m_qml_engine) m_qml_engine->retranslate();
}

/* ************************************************************************** */
