/*!
 * This file is part of toolBLEx.
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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef COLORMAP_FACTORY_H
#define COLORMAP_FACTORY_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QRgb>

class QQuickGradient;

/* ************************************************************************** */

/*!
 * \brief Single source of truth for the spectrum color schemes.
 *
 * The waterfall graph (WaterfallGraph_QuickItem.cpp) needs a 256-entry QRgb LUT.
 * The 3D surface graph (SpectrumGraph3D.qml) needs a QML Gradient for its GraphsTheme.baseGradients.
 * Both are generated here from the same stop tables, so a color scheme is defined in exactly one place.
 *
 * Stop positions assume the magnitude axis of our graphs spans -100..-20 dB, i.e. position = (value + 100) / 80.
 * Every color scheme keeps a thin dark base at the bottom so the ~-90 dB noise floor stays muted and signals climb into vivid color.
 *
 * Exposed to QML as a singleton: ColormapFactory.getGradient(ColormapFactory.Inferno)
 */
class ColormapFactory: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_MOC_INCLUDE("QtQuick/private/qquickrectangle_p.h")

public:
    enum Scheme {
        Viridis = 0,    //!< perceptually uniform, colorblind-safe, calm
        Turbo,          //!< Google's improved jet; punchy, perceptually smooth
        Inferno,        //!< hand-tuned punchy thermal
        Gqrx,           //!< black floor > blue > cyan > yellow > red > white hot
    };
    Q_ENUM(Scheme)

    explicit ColormapFactory(QObject *parent = nullptr) : QObject(parent) {}

    /*!
     * \brief Fill a 256-entry LUT by interpolating the color scheme (used by the 'waterfall' graph).
     * \param[in] scheme: The choosen ColormapFactory::Scheme.
     * \param[out] lut: A 256-entry LUT generated from the choosen scheme.
     */
    static void fillLut(const Scheme scheme, QRgb lut[256]);

    /*!
     * \brief Build a QML Gradient for GraphsTheme.baseGradients (used by the 3D surface graph).
     * \param scheme: The choosen ColormapFactory::Scheme.
     * \return QQuickGradient with stops from the choosen scheme.
     *
     * Notes about QQuickGradient:
     * - QQuickGradient / QQuickGradientStop are the C++ backing of the QML Gradient / GradientStop elements.
     * - They live in a QtQuick private header (linked via Qt6::QuickPrivate),
     *   but the API used here (stops list + position/color) is stable.
     * - QQuickGradient stays forward-declared (its definition lives in a QtQuick private header).
     *   Q_MOC_INCLUDE pulls that header into the generated moc only, so moc can register the gradient()
     *   return type without every consumer of this header having to see the private definition.
     * - The returned object is handed to the QML engine (JavaScriptOwnership).
     */
    Q_INVOKABLE QQuickGradient *getGradient(const Scheme scheme);
};

/* ************************************************************************** */
#endif // COLORMAP_FACTORY_H
