/*!
 * This file is part of toolBLEx.
 * Copyright (c) 2026 Emeric Grange - All Rights Reserved
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

#include "RtlSdrDriver_lib.h"

#include <QDebug>

#include <rtl-sdr.h>

#include <algorithm>
#include <cmath>

/* ************************************************************************** */

namespace {

constexpr double s_pi = 3.14159265358979323846;

/*!
 * \brief In-place iterative radix-2 complex FFT, with precomputed bit reversal and twiddles.
 *
 * Data is stored as interleaved float pairs (re, im). Plain arithmetic is used instead of
 * std::complex multiplications, which are slow without -ffast-math (NaN/Inf recovery path).
 */
class RadixTwoFft
{
    int m_size = 0;
    std::vector <int> m_rev;
    std::vector <float> m_tw;   //!< (cos, -sin) pairs, m_size/2 entries

public:
    explicit RadixTwoFft(int size) : m_size(size), m_rev(size), m_tw(size)
    {
        int bits = 0;
        while ((1 << bits) < size) bits++;

        for (int i = 0; i < size; i++)
        {
            int r = 0;
            for (int b = 0; b < bits; b++) if (i & (1 << b)) r |= 1 << (bits - 1 - b);
            m_rev[i] = r;
        }
        for (int k = 0; k < size / 2; k++)
        {
            const double a = -2.0 * s_pi * k / size;
            m_tw[2*k] = static_cast<float>(std::cos(a));
            m_tw[2*k + 1] = static_cast<float>(std::sin(a));
        }
    }

    void transform(float *x) const
    {
        for (int i = 0; i < m_size; i++)
        {
            const int r = m_rev[i];
            if (i < r) { std::swap(x[2*i], x[2*r]); std::swap(x[2*i + 1], x[2*r + 1]); }
        }

        for (int len = 2; len <= m_size; len <<= 1)
        {
            const int half = len / 2;
            const int step = m_size / len;

            for (int i = 0; i < m_size; i += len)
            {
                for (int j = 0; j < half; j++)
                {
                    const float wr = m_tw[2 * j * step], wi = m_tw[2 * j * step + 1];
                    float *a = x + 2 * (i + j);
                    float *b = x + 2 * (i + j + half);

                    const float vr = b[0] * wr - b[1] * wi;
                    const float vi = b[0] * wi + b[1] * wr;
                    b[0] = a[0] - vr; b[1] = a[1] - vi;
                    a[0] += vr;       a[1] += vi;
                }
            }
        }
    }
};

/*!
 * \brief Build a user-facing error message from a librtlsdr return code, with a per-OS hint.
 * \param what: Operation that failed.
 * \param err: librtlsdr return code (-1 generic, or a forwarded libusb error code).
 */
QString rtlError(const char *what, int err)
{
    QString msg = QStringLiteral("%1 failed (%2)").arg(what).arg(err);

    switch (err)
    {
    case -3: // LIBUSB_ERROR_ACCESS
#if defined(Q_OS_LINUX)
        msg += QStringLiteral(": access denied, missing udev rules for the RTL-SDR?");
#else
        msg += QStringLiteral(": access denied, device used by another application?");
#endif
        break;
    case -4: // LIBUSB_ERROR_NO_DEVICE
        msg += QStringLiteral(": device disconnected");
        break;
    case -6: // LIBUSB_ERROR_BUSY
#if defined(Q_OS_LINUX)
        msg += QStringLiteral(": device busy, is the 'dvb_usb_rtl28xxu' kernel module loaded?");
#else
        msg += QStringLiteral(": device busy, used by another application?");
#endif
        break;
    case -5:  // LIBUSB_ERROR_NOT_FOUND
    case -12: // LIBUSB_ERROR_NOT_SUPPORTED
#if defined(Q_OS_WINDOWS)
        msg += QStringLiteral(": no WinUSB driver, install it with Zadig");
#endif
        break;
    default:
        break;
    }

    return msg;
}

/*!
 * \brief Get a readable tuner name.
 */
QString tunerName(rtlsdr_tuner tuner)
{
    switch (tuner)
    {
    case RTLSDR_TUNER_E4000:  return QStringLiteral("E4000");
    case RTLSDR_TUNER_FC0012: return QStringLiteral("FC0012");
    case RTLSDR_TUNER_FC0013: return QStringLiteral("FC0013");
    case RTLSDR_TUNER_FC2580: return QStringLiteral("FC2580");
    case RTLSDR_TUNER_R820T:  return QStringLiteral("R820T");
    case RTLSDR_TUNER_R828D:  return QStringLiteral("R828D");
    default:                  return QStringLiteral("Unknown");
    }
}

/*!
 * \brief Apply automatic gain, or the supported manual gain closest to the requested one.
 * \return librtlsdr return code.
 */
int applyGain(rtlsdr_dev_t *dev, double gainDb)
{
    if (gainDb < 0.0) return rtlsdr_set_tuner_gain_mode(dev, 0);

    const int count = rtlsdr_get_tuner_gains(dev, nullptr);
    if (count <= 0) return rtlsdr_set_tuner_gain_mode(dev, 0);

    std::vector <int> gains(count);
    rtlsdr_get_tuner_gains(dev, gains.data());

    const int wanted = static_cast<int>(std::lround(gainDb * 10.0)); // tenths of dB
    const int best = *std::min_element(gains.begin(), gains.end(), [wanted](int a, int b) {
        return std::abs(a - wanted) < std::abs(b - wanted);
    });

    const int r = rtlsdr_set_tuner_gain_mode(dev, 1);
    if (r < 0) return r;
    return rtlsdr_set_tuner_gain(dev, best);
}

/*!
 * \brief Snap a sample rate to the RTL2832U valid ranges (225001..300000 and 900001..3200000 Hz).
 */
quint32 snapSampleRate(quint32 rate)
{
    rate = std::clamp<quint32>(rate, 225001, 3200000);
    if (rate > 300000 && rate <= 900000) rate = (rate - 300000 < 900001 - rate) ? 300000 : 900001;
    return rate;
}

/*!
 * \brief Round an FFT size up to a power of two, in 64..16384.
 */
int snapFftSize(int size)
{
    int n = 64;
    while (n < size && n < 16384) n <<= 1;
    return n;
}

} // namespace

/* ************************************************************************** */
/* ************************************************************************** */

RtlSdrDriver_lib::RtlSdrDriver_lib(QObject *parent) : SpectrumDriver_lib(parent)
{
    //
}

RtlSdrDriver_lib::~RtlSdrDriver_lib()
{
    stop();
}

/* ************************************************************************** */
/* ************************************************************************** */

void RtlSdrDriver_lib::setFftSize(int size)
{
    m_fftSize = snapFftSize(size);
}

/* ************************************************************************** */
/* ************************************************************************** */

int RtlSdrDriver_lib::deviceCount()
{
    return static_cast<int>(rtlsdr_get_device_count());
}

QString RtlSdrDriver_lib::deviceName(int deviceIndex)
{
    if (deviceIndex < 0) return QString();
    return QString::fromUtf8(rtlsdr_get_device_name(static_cast<uint32_t>(deviceIndex)));
}

/* ************************************************************************** */

bool RtlSdrDriver_lib::probeDevice(int deviceIndex, QString *tuner, QString *error)
{
    if (deviceIndex < 0 || deviceIndex >= deviceCount())
    {
        if (error) *error = QStringLiteral("No RTL-SDR device found (index %1)").arg(deviceIndex);
        return false;
    }

    rtlsdr_dev_t *dev = nullptr;
    const int r = rtlsdr_open(&dev, static_cast<uint32_t>(deviceIndex));
    if (r < 0 || !dev)
    {
        if (error) *error = rtlError("rtlsdr_open", r);
        return false;
    }

    if (tuner) *tuner = tunerName(rtlsdr_get_tuner_type(dev));
    rtlsdr_close(dev);

    return true;
}

/* ************************************************************************** */
/* ************************************************************************** */

bool RtlSdrDriver_lib::detect()
{
    m_available = (deviceCount() > 0);
    return m_available;
}

/* ************************************************************************** */

bool RtlSdrDriver_lib::checkHardware(int deviceIndex)
{
    QString tuner, error;
    const bool status = probeDevice(deviceIndex, &tuner, &error);

    if (status) qDebug() << "RtlSdrDriver_lib::checkHardware()" << deviceName(deviceIndex) << "tuner:" << tuner;
    else qWarning() << "RtlSdrDriver_lib::checkHardware()" << error;

    return status;
}

/* ************************************************************************** */
/* ************************************************************************** */

void RtlSdrDriver_lib::workerLoop(const Config cfg)
{
    const quint32 centerHz = static_cast<quint32>(std::llround((cfg.freqMinHz + cfg.freqMaxHz) / 2.0));
    const quint32 sampleRateHz = snapSampleRate(static_cast<quint32>(std::llround(cfg.freqMaxHz - cfg.freqMinHz)));
    const int N = snapFftSize(m_fftSize);
    const int ppm = m_ppm;
    const bool dcRemoval = m_dcRemoval;
    const double integrationTime = std::clamp(cfg.integrationTime, 0.005, 10.0);

    if (cfg.deviceIndex < 0 || centerHz == 0)
    {
        postError(QStringLiteral("Invalid RTL-SDR capture parameters"));
        return;
    }

    rtlsdr_dev_t *dev = nullptr;
    int r = rtlsdr_open(&dev, static_cast<uint32_t>(cfg.deviceIndex));
    if (r < 0 || !dev)
    {
        postError(rtlError("rtlsdr_open", r));
        return;
    }
    struct DeviceCloser { rtlsdr_dev_t *d; ~DeviceCloser() { rtlsdr_close(d); } } closer { dev };

    if ((r = rtlsdr_set_sample_rate(dev, sampleRateHz)) < 0)
    {
        postError(rtlError("rtlsdr_set_sample_rate", r));
        return;
    }
    if (ppm != 0) rtlsdr_set_freq_correction(dev, ppm); // -2 means "already set"
    if ((r = rtlsdr_set_center_freq(dev, centerHz)) < 0)
    {
        postError(rtlError("rtlsdr_set_center_freq", r));
        return;
    }
    if ((r = applyGain(dev, cfg.gainDb)) < 0)
    {
        postError(rtlError("rtlsdr_set_tuner_gain", r));
        return;
    }
    if ((r = rtlsdr_reset_buffer(dev)) < 0)
    {
        postError(rtlError("rtlsdr_reset_buffer", r));
        return;
    }

    const RadixTwoFft fft(N);

    // Hann window, normalized so that a full-scale complex tone reads ~0 dBFS
    std::vector <float> window(N);
    double wsum = 0.0;
    for (int k = 0; k < N; k++)
    {
        window[k] = static_cast<float>(0.5 - 0.5 * std::cos(2.0 * s_pi * k / N));
        wsum += window[k];
    }
    const double norm = wsum * wsum;

    float lut[256];
    for (int i = 0; i < 256; i++) lut[i] = (i - 127.5f) / 127.5f;

    // ~10 ms of samples per read, power of two bytes (multiple of 512 and of 2*N)
    int bufBytes = 16384;
    while (bufBytes < 262144 && bufBytes < static_cast<int>(sampleRateHz / 50)) bufBytes <<= 1;
    bufBytes = std::max(bufBytes, 2 * N);

    const int fftsPerFrame = std::max(1, static_cast<int>(std::lround(integrationTime * sampleRateHz / N)));

    const double binHz = double(sampleRateHz) / N;

    std::vector <quint8> buf(bufBytes);
    std::vector <float> x(2 * N);
    std::vector <double> acc(N, 0.0);
    int accCount = 0;

    while (!stopRequested())
    {
        int nRead = 0;
        r = rtlsdr_read_sync(dev, buf.data(), bufBytes, &nRead);
        if (r < 0)
        {
            postError(rtlError("rtlsdr_read_sync", r));
            break;
        }

        const int samples = nRead / 2;
        if (samples < N) continue;

        float dcI = 0.f, dcQ = 0.f;
        if (dcRemoval)
        {
            double si = 0.0, sq = 0.0;
            for (int s = 0; s < samples; s++) { si += lut[buf[2*s]]; sq += lut[buf[2*s + 1]]; }
            dcI = static_cast<float>(si / samples);
            dcQ = static_cast<float>(sq / samples);
        }

        for (int s0 = 0; s0 + N <= samples; s0 += N)
        {
            const quint8 *iq = buf.data() + 2 * s0;
            for (int k = 0; k < N; k++)
            {
                x[2*k] = (lut[iq[2*k]] - dcI) * window[k];
                x[2*k + 1] = (lut[iq[2*k + 1]] - dcQ) * window[k];
            }

            fft.transform(x.data());

            for (int k = 0; k < N; k++) acc[k] += double(x[2*k]) * x[2*k] + double(x[2*k + 1]) * x[2*k + 1];

            if (++accCount < fftsPerFrame) continue;

            std::vector <Sample> sweep(N);
            const double scale = 1.0 / (accCount * norm);
            for (int k = 0; k < N; k++)
            {
                const int shifted = (k + N / 2) % N; // FFT order -> increasing frequency
                sweep[shifted].freqHz = centerHz + (shifted - N / 2) * binHz;
                sweep[shifted].db = static_cast<float>(10.0 * std::log10(acc[k] * scale + 1e-20));
            }
            if (dcRemoval)
            {
                sweep[N / 2].db = 0.5f * (sweep[N / 2 - 1].db + sweep[N / 2 + 1].db);
            }

            pushSamples(std::move(sweep));

            std::fill(acc.begin(), acc.end(), 0.0);
            accCount = 0;
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

