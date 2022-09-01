/*!
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2020
 */

#ifndef UTILS_LANGUAGE_H
#define UTILS_LANGUAGE_H
/* ************************************************************************** */

#include <QObject>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QString>

/* ************************************************************************** */

class UtilsLanguage : public QObject
{
    Q_OBJECT

    QString m_appName;
    QString m_appLanguage;

    QCoreApplication *m_qt_app = nullptr;
    QQmlApplicationEngine *m_qml_engine = nullptr;

    QTranslator *m_qtTranslator = nullptr;
    QTranslator *m_appTranslator = nullptr;

    // Singleton
    static UtilsLanguage *instance;
    UtilsLanguage();
    ~UtilsLanguage();

public:
    static UtilsLanguage *getInstance();

    void setAppName(const QString &name);
    void setAppInstance(QCoreApplication *app);
    void setQmlEngine(QQmlApplicationEngine *engine);

    QString getCurrentLanguage() const { return m_appLanguage; }
    Q_INVOKABLE void loadLanguage(const QString &lng);
};

/* ************************************************************************** */
#endif // UTILS_LANGUAGE_H
