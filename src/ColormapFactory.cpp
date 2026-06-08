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
#include <QList>
#include <QQmlEngine>

#include <QtQuick/private/qquickrectangle_p.h>

#include <algorithm>
#include <iterator>

/* ************************************************************************** */

namespace {

// Absolute noise-floor level (dBm) the color schemes are anchored to.
// Magnitudes below this stay in the muted "floor" sub-ramp;
// above it they climb into the vivid "signal" sub-ramp.
constexpr double s_noiseFloorDb = -90.0;

// A colormap stop.
// - position -1 = floorDb (bottom of the muted dark base)
// - position  0 = noiseFloorDb
// - position +1 = ceilDb (top of the vivid signal ramp),
struct Stop { double pos; const char *hex; };

// VIRIDIS (perceptually uniform, colorblind-safe -- nudged a touch more vivid)
const Stop kViridis[] = {
    { -1.000, "#1e0a2e" },  // floor, deep base (dark)
    {  0.000, "#440154" },  // noise floor (purple)
    {  0.256, "#375ea3" },  // blue (slightly more saturated)
    {  0.512, "#16a097" },  // teal (brighter)
    {  0.767, "#5fd552" },  // green (more vivid)
    {  1.000, "#fdee18" },  // yellow (a touch punchier)
};

// TURBO (Google's improved jet; punchy, perceptually smooth)
const Stop kTurbo[] = {
    { -1.000, "#1a0e2e" },  // floor, deep base (dark)
    {  0.000, "#30123b" },  // noise floor (dark purple)
    {  0.186, "#4467f4" },  // blue
    {  0.360, "#1bc7d4" },  // cyan
    {  0.512, "#28ec8b" },  // green
    {  0.674, "#9bfb4d" },  // yellow-green
    {  0.826, "#fdab32" },  // orange
    {  1.000, "#d23105" },  // red
};

// INFERNO (hand-tuned, punchy thermal)
const Stop kInferno[] = {
    { -1.000, "#23263a" },  // floor, deep base (dark)
    {  0.000, "#3a2f6e" },  // noise floor (dark violet)
    {  0.227, "#7d2bc4" },  // vivid violet
    {  0.455, "#e01d74" },  // vivid magenta
    {  0.705, "#ff7a14" },  // vivid orange
    {  1.000, "#ffe61f" },  // brightest yellow
};

// GQRX (black floor > blue > cyan > yellow > red > white hot)
const Stop kGqrx[] = {
    { -1.000, "#111111" },  // floor, deep base (dark)
    {  0.000, "#00004a" },  // noise floor (dark blue)
    {  0.209, "#0000ff" },  // blue
    {  0.419, "#00ffff" },  // cyan
    {  0.628, "#ffff00" },  // yellow
    {  0.826, "#ff0000" },  // red
    {  1.000, "#ffffff" },  // white hot
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

        default:                       return { kViridis, int(std::size(kViridis)) };
    }
}

// A resolved stop in real axis-normalized space: position (0..1 over [floorDb..ceilDb]) -> color.
struct BuiltStop { double pos; QColor color; };

// Composite a scheme onto the live axis range.
QList<BuiltStop> buildStops(ColormapFactory::Scheme scheme, double floorDb, double ceilDb)
{
    const Ramp ramp = rampFor(scheme);

    const double span = ceilDb - floorDb;
    double knee = (span != 0.0) ? (s_noiseFloorDb - floorDb) / span : 0.0;
    knee = std::clamp(knee, 0.0, 1.0);

    QList<BuiltStop> out;
    out.reserve(ramp.count);

    for (int i = 0; i < ramp.count; i++)
    {
        const double p = ramp.stops[i].pos;
        const double norm = knee + p * (p >= 0.0 ? (1.0 - knee) : knee);
        out.push_back({ std::clamp(norm, 0.0, 1.0), QColor(QLatin1String(ramp.stops[i].hex)) });
    }

    return out;
}

} // namespace

/* ************************************************************************** */

void ColormapFactory::fillLut(const Scheme scheme, QRgb lut[256], double floorDb, double ceilDb)
{
    const QList<BuiltStop> stops = buildStops(scheme, floorDb, ceilDb);
    const int count = stops.size();
    if (count <= 0) return;

    for (int i = 0; i < 256; i++)
    {
        const double t = i / 255.0;

        int hi = 1;
        while (hi < count - 1 && stops[hi].pos < t) hi++;
        const QColor &aa = stops[hi - 1].color;
        const QColor &bb = stops[hi].color;

        const double span = (stops[hi].pos - stops[hi - 1].pos);
        const double f = (span > 0.0) ? std::clamp((t - stops[hi - 1].pos) / span, 0.0, 1.0) : 0.0;

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

    const QList<BuiltStop> built = buildStops(scheme, floorDb, ceilDb);
    for (int i = 0; i < built.size(); i++)
    {
        QQuickGradientStop *s = new QQuickGradientStop(g);
        if (s)
        {
            s->setPosition(built[i].pos);
            s->setColor(built[i].color);
            stops.append(&stops, s);
        }
    }

    QQmlEngine::setObjectOwnership(g, QQmlEngine::JavaScriptOwnership);

    return g;
}

/* ************************************************************************** */
