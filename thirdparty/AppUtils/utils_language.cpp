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
    // Set a default application name and Qt application instance
    m_appName = QCoreApplication::applicationName();
    m_qt_app = QCoreApplication::instance();
}

UtilsLanguage::~UtilsLanguage()
{
    //
}

/* ************************************************************************** */

void UtilsLanguage::setAppName(const QString &name, const bool forceLowerCase)
{
    if (forceLowerCase) m_appName = name.toLower();
    else m_appName = name;
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

    m_appLanguage = lng;
    if (m_appLanguage == "Chinese (traditional)") m_locale_str_full = "zh_TW";
    else if (m_appLanguage == "Chinese (simplified)") m_locale_str_full = "zh_CN";
    else if (m_appLanguage == "Dansk") m_locale_str_full = "da_DK"; // Danish
    else if (m_appLanguage == "Deutsch") m_locale_str_full = "de_DE";
    else if (m_appLanguage == "English") m_locale_str_full = "en_EN";
    else if (m_appLanguage == "Español") m_locale_str_full = "es_ES";
    else if (m_appLanguage == "Italiano") m_locale_str_full = "it_IT";
    else if (m_appLanguage == "Français") m_locale_str_full = "fr_FR";
    else if (m_appLanguage == "Frysk") m_locale_str_full = "fy_NL";
    else if (m_appLanguage == "Hungarian") m_locale_str_full = "hu_HU";
    else if (m_appLanguage == "Nederlands") m_locale_str_full = "nl_NL"; // Dutch
    else if (m_appLanguage == "Norsk (Bokmål)") m_locale_str_full = "nb_NO"; // Swedish
    else if (m_appLanguage == "Norsk (Nynorsk)") m_locale_str_full = "nn_NO"; // Swedish
    else if (m_appLanguage == "Polski") m_locale_str_full = "pl_PL"; // Polish
    else if (m_appLanguage == "Pусский") m_locale_str_full = "ru_RU"; // Russian
    else
    {
        m_locale_str_full = QLocale::system().name();
        m_appLanguage = "auto";
    }

    m_locale_str_short = m_locale_str_full;
    m_locale_str_short.truncate(m_locale_str_full.lastIndexOf('_'));

    QLocale locale(m_locale_str_full);
    QLocale::setDefault(locale);

    QString translationpath = QLibraryInfo::path(QLibraryInfo::TranslationsPath);

    m_qtTranslator = new QTranslator;
    if (m_qtTranslator) {
        if (m_qtTranslator->load("qt_" + m_locale_str_full, translationpath)) {
            m_qt_app->installTranslator(m_qtTranslator);
        } else {
            qWarning() << "qtTranslator ERROR !";
        }
    }

    m_appTranslator = new QTranslator;
    if (m_appTranslator) {
        if (m_appTranslator->load(":/i18n/" + m_appName + "_" + m_locale_str_short + ".qm")) {
            m_qt_app->installTranslator(m_appTranslator);
        } else {
            qWarning() << "appTranslator ERROR !" << m_appName << m_locale_str_full;
        }
    }

    // Install new language
    if (m_qml_engine) m_qml_engine->retranslate();
}

/* ************************************************************************** */
