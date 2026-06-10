# RTL-SDR support in toolBLEx

toolBLEx can use an **RTL-SDR** (RTL2832U-based USB dongle) as a sub-GHz spectrum source.  
This document describes what these devices can do, which tools drive them, and how the `RtlSdr` backend is wired.  

> https://www.rtl-sdr.com/about-rtl-sdr/


## How an RTL-SDR works

An RTL-SDR is two chips:

- The **RTL2832U** — the USB ADC / demodulator. *Same in every dongle.* It sets the **sample rate** (and therefore the instantaneous bandwidth) and the USB 2.0 link.
- The **tuner** — a separate RF front-end chip that sets which frequencies you can reach. *This is what differs between dongles.*

So: the **tuner determines your frequency reach**, and the **RTL2832U determines your bandwidth.**
Two dongles with different tuners have different ranges but the *same* instantaneous bandwidth.

### Common boards / dongles

| Board                       | Tuner           | Notes                         |
|-----------------------------|-----------------|-------------------------------|
| RTL-SDR Blog V3 / V4        | R820T2 / R860   | Best general-purpose; direct sampling, TCXO, bias-tee |
| Generic "RTL2832U + R820T2" | R820T2          | The ubiquitous cheap stick    |
| NooElec NESDR (various)     | R820T2 / E4000  |                               |
| Older DVB-T sticks (Terratec, ezcap, ...) | E4000 / FC0012/13 | The "classic" first-gen SDR sticks |

The only dongle tested with toolBLEx is a *TerraTec (RTL2838UHIDIR) with an Elonics E4000 tuner*. Had this one in my drawer for more than a decade :)

### Tuner chipsets — frequency range

| Tuner                     | Frequency range       | Notes                                                         |
|---------------------------|-----------------------|---------------------------------------------------------------|
| **R820T / R820T2 / R860** | ~24 MHz – 1.766 GHz   | RTL-SDR Blog V3/V4 is the GOAT (beware of cheap clones)       |
| **E4000 (Elonics)**       | ~52 MHz – 2.2 GHz     | Reaches highest, but has a **gap ~1100–1250 MHz**             |
| **FC0013 (Fitipower)**    | ~22 MHz – 1.1 GHz     |                                                               |
| **FC0012 (Fitipower)**    | ~22 MHz – 948 MHz     |                                                               |
| **FC2580 (FCI)**          | ~146–308 & 438–924 MHz| Two bands with a gap                                          |
| **R828D**                 | ~24 MHz – 1.766 GHz   | R820T2 sibling, used in some triple-tuner boards              |

### Instantaneous bandwidth — the same on every RTL dongle

The instantaneous bandwidth is set by the **RTL2832U + USB 2.0**, *not* the tuner, so it is **identical across all RTL-SDR dongles**:

- Sample rate: up to **3.2 MS/s** in theory, but **~2.4–2.56 MS/s** is the
  reliable maximum before USB 2.0 drops samples.
- Because sampling is **complex (I/Q)**, usable spectrum width ≈ sample rate →
  **~2.4 MHz visible at one tuning.**

The tuner's IF filter may be wider than 2.4 MHz, but it doesn't help — you can
only *digitize* what the ADC + USB carry.

> **Anything wider than ~2.4 MHz requires sweeping** (retuning across the band and stitching).
> Wide spans are therefore slow (too slow to be usefull, especially on the E4000's sluggish PLL).
> Narrow windows (≤ 2.4 MHz, one tune) are the RTL-SDR's sweet spot.

### How the common dongles compares to other SDRs platforms

| SDR               | Instantaneous BW  | Why                                   |
|-------------------|-------------------|---------------------------------------|
| **Any RTL-SDR**   | **~2.4 MHz**      | RTL2832U + USB 2.0                    |
| Airspy Mini / R2  | ~6 / ~10 MHz      | faster ADC                            |
| HackRF One        | ~20 MHz           | faster ADC, USB 2.0 (8-bit)           |
| LimeSDR / USRP    | 30–60+ MHz        | USB 3.0 / GbE                         |

These are all drivable via **SoapySDR**, so the `soapy_power` backend already makes their support possible in toolBLEx. Completely untested though...


## Capture backends

toolBLEx drives one of three command-line scanners (selectable via the `backend` property).
All are spawned as child processes and outputs parsed line-by-line.

| Backend         | Tool / package            | Output format               | Notes |
|-----------------|---------------------------|-----------------------------|-------|
| `SoapyPower`    | `soapy_power` (SoapySDR)  | rtl_power CSV               | Scales with integration time, **~10 Hz** plateau; multi-SDR |
| `RtlPowerFftw`  | `rtl_power_fftw`          | `freq_hz power_db` columns  | Fastest continuous FFT; PSD units (dB/Hz) |
| `RtlPower`      | `rtl_power` (rtl-sdr)     | rtl_power CSV               | Simplest, but **~1 Hz** regardless of settings; Should NOT be used |

### Commands issued by the `RtlSdr` class

> TODO

### Output format details

> TODO


## Known limitations

- **~2.4 MHz instantaneous bandwidth** — fundamental to all RTL2832U dongles.
- **E4000 retunes slowly** — wide swept spans are sluggish; prefer narrow windows.
- **Command-line tools cap at ~1–10 Hz** — for real-time wideband, an in-process `librtlsdr` + FFT backend is the future direction.
- **kHz mode is narrowband-only** (memory guard at 16384 bins).
- **Uncalibrated power** — readings are relative dB, not absolute dBm.
