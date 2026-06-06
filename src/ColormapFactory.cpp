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

#include "ColormapFactory.h"

#include <QColor>
#include <QVarLengthArray>
#include <QQmlEngine>

#include <QtQuick/private/qquickrectangle_p.h>

#include <algorithm>
#include <iterator>

/* ************************************************************************** */

namespace {

// A colormap stop: normalized position (0..1) -> color (hex string).
struct Stop { double pos; const char *hex; };

const Stop kViridis[] = { // VIRIDIS (perceptually uniform, colorblind-safe, calm)
    { 0.00, "#1e0a2e" },  // -100, darkened floor
    { 0.14, "#440154" },  // ~-89, noise floor (purple)
    { 0.36, "#3b528b" },  // ~-71, blue
    { 0.58, "#21918c" },  // ~-54, teal
    { 0.80, "#5ec962" },  // ~-36, green
    { 1.00, "#fde725" },  //  -20, yellow
};

const Stop kTurbo[] = {   // TURBO (Google's improved jet; punchy, perceptually smooth)
    { 0.00, "#1a0e2e" },  // -100, darkened floor
    { 0.14, "#30123b" },  // ~-89, noise floor (dark purple)
    { 0.30, "#4467f4" },  // ~-76, blue
    { 0.45, "#1bc7d4" },  // ~-64, cyan
    { 0.58, "#28ec8b" },  // ~-54, green
    { 0.72, "#9bfb4d" },  // ~-42, yellow-green
    { 0.85, "#fdab32" },  // ~-32, orange
    { 1.00, "#d23105" },  //  -20, red
};

const Stop kInferno[] = { // INFERNO (hand-tuned, punchy thermal)
    { 0.00, "#23263a" },  // -100, empty/deep noise (dark)
    { 0.12, "#3a2f6e" },  // ~-89, noise floor (dark violet)
    { 0.32, "#7d2bc4" },  // ~-74, vivid violet
    { 0.52, "#e01d74" },  // ~-58, vivid magenta
    { 0.74, "#ff7a14" },  // ~-41, vivid orange
    { 1.00, "#ffe61f" },  //  -20, brightest yellow
};

const Stop kGqrx[] = {    // GQRX (black floor > blue > cyan > yellow > red > white hot)
    { 0.00, "#111111" },  // -100, dark floor
    { 0.14, "#00004a" },  // ~-89, noise floor (dark blue)
    { 0.32, "#0000ff" },  // ~-74, blue
    { 0.50, "#00ffff" },  // ~-60, cyan
    { 0.68, "#ffff00" },  // ~-45, yellow
    { 0.85, "#ff0000" },  // ~-32, red
    { 1.00, "#ffffff" },  //  -20, white hot
};

struct Ramp { const Stop *stops; int count; };

Ramp rampFor(ColormapFactory::Scheme scheme)
{
    switch (scheme)
    {
        case ColormapFactory::Turbo:   return { kTurbo,   int(std::size(kTurbo)) };
        case ColormapFactory::Inferno: return { kInferno, int(std::size(kInferno)) };
        case ColormapFactory::Gqrx:    return { kGqrx,    int(std::size(kGqrx)) };
        case ColormapFactory::Viridis: return { kViridis, int(std::size(kViridis)) };
        default: return { kViridis, int(std::size(kViridis)) };
    }
}

} // namespace

/* ************************************************************************** */

void ColormapFactory::fillLut(const Scheme scheme, QRgb lut[256], double floorDb, double ceilDb)
{
    const Ramp ramp = rampFor(scheme);

    QVarLengthArray<QColor, 8> cols(ramp.count);
    for (int i = 0; i < ramp.count; i++) cols[i] = QColor(QLatin1String(ramp.stops[i].hex));

    for (int i = 0; i < 256; i++)
    {
        const double t = i / 255.0;

        int hi = 1;
        while (hi < ramp.count - 1 && ramp.stops[hi].pos < t) hi++;
        const QColor &aa = cols[hi - 1];
        const QColor &bb = cols[hi];

        const double span = (ramp.stops[hi].pos - ramp.stops[hi - 1].pos);
        const double f = (span > 0.0) ? std::clamp((t - ramp.stops[hi - 1].pos) / span, 0.0, 1.0) : 0.0;

        const int r = int(aa.red()   + (bb.red()   - aa.red())   * f + 0.5);
        const int g = int(aa.green() + (bb.green() - aa.green()) * f + 0.5);
        const int b = int(aa.blue()  + (bb.blue()  - aa.blue())  * f + 0.5);

        lut[i] = qRgb(r, g, b);
    }
}

/* ************************************************************************** */

QQuickGradient *ColormapFactory::getGradient(const Scheme scheme, double floorDb, double ceilDb)
{
    QQuickGradient *g = new QQuickGradient();
    QQmlListProperty<QQuickGradientStop> stops = g->stops();

    const Ramp ramp = rampFor(scheme);
    for (int i = 0; i < ramp.count; i++)
    {
        QQuickGradientStop *s = new QQuickGradientStop(g);
        if (s)
        {
            s->setPosition(ramp.stops[i].pos);
            s->setColor(QColor(QLatin1String(ramp.stops[i].hex)));
            stops.append(&stops, s);
        }
    }

    QQmlEngine::setObjectOwnership(g, QQmlEngine::JavaScriptOwnership);

    return g;
}

/* ************************************************************************** */
