# Interesting Frequency Bands: 2300 to 2600 MHz


#### 📱 Cellular & Mobile Broadband

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| LTE Band 7 (UL)   | 2500–2570 MHz     | Very common 4G band worldwide         |
| LTE Band 7 (DL)   | 2620–2690 MHz     | Very common 4G band worldwide         |
| LTE Band 38       | 2570–2620 MHz     | TDD LTE, used heavily in Europe and Asia      |
| LTE Band 40       | 2300–2400 MHz     | TDD LTE, widely deployed in India, Australia  |
| LTE Band 41       | 2496–2690 MHz     | Broad TDD band, used by Sprint (US), T-Mobile |
| 5G NR n7          | 2500–2690 MHz     | 5G on the same frequencies as LTE Band 7      |
| 5G NR n38         | 2570–2620 MHz     | 5G TDD mid-band                               |
| 5G NR n40         | 2300–2400 MHz     | 5G TDD, active in several Asian markets       |
| 5G NR n41         | 2496–2690 MHz     | Key US 5G mid-band (T-Mobile heavily uses it) |

> These are some of the busiest frequencies on the spectrum — a spectrogram here will look very active in urban areas.


#### 📡 WiFi & Unlicensed ISM (industrial, scientific and medical)

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| WiFi (2.4 GHz)    | 2400–2483.5 MHz   | 13 channels (1–13 in EU), heavily congested |
| Bluetooth         | 2402–2480 MHz     | Frequency-hopping across 79 channels, 1 MHz each |
| Zigbee            | 2405–2480 MHz     | IEEE 802.15.4, IoT mesh networks      |
| Thread            | 2405–2480 MHz     | IoT protocol (Matter standard) — same channels as Zigbee |
| Z-Wave (not all)  | ~2450 MHz         | Some newer Z-Wave devices also operate here |

> The 2.4 GHz band is one of the most chaotic parts of the spectrum — WiFi, Bluetooth, microwaves, baby monitors, and wireless cameras all compete here.


#### 🔭 Satellite & Navigation

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| GPS L5            | 1176.45 MHz       | —                                     |
| Galileo E6        | 1278.75 MHz       | —                                     |
| S-Band sat. uplinks   | 2025–2120 MHz | NASA Deep Space Network, satellite ops        |
| S-Band sat. downlinks | 2200–2290 MHz | Telemetry from low Earth orbit satellites     |
| Iridium NEXT      | ~2484 MHz         | Secondary Iridium band (primary is L-Band)    |
| Globalstar S-Band | 2483.5–2500 MHz   | Globalstar mobile satellite service downlink  |


#### 🛰️ Earth Observation & Science

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| NOAA/NASA S-Band  | 2025–2120 MHz | Satellite tracking, telemetry & command   |
| Earth Observation downlinks | 2200–2300 MHz | High-rate data downlinks from imaging satellites |
| Amateur satellite | ~2304 MHz         | 13 cm amateur band satellite segment  |


#### 🎙️ Amateur Radio — 13 cm Band

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| 13 cm (main)      | 2300–2450 MHz     | Microwave amateur band — EME, beacons, ATV    |
| 13 cm weak signal | 2304–2310 MHz     | SSB/CW weak signal calling frequencies        |
| 13 cm FM simplex  | ~2370 MHz         | Local FM activity                             |
| ATV (Analog TV)   | ~2420 MHz         | Amateur television, still used at club events |


#### 📻 Microwave Point-to-Point Links

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| S-Band backhaul   | 2300–2400 MHz     | Fixed microwave links (ISPs, enterprise) |
| 2.5 GHz WiMAX     | 2500–2700 MHz     | Legacy fixed wireless broadband infrastructure |

> These look like narrow, stable carrier peaks on a spectrum analyzer — very different from the wideband LTE signals.


#### 🍳 Interesting Interference Sources

| Band              | Frequency         | Notes                                 |
|-------------------|-------------------|---------------------------------------|
| Microwave ovens   | ~2450 MHz         | Leakage around 2.45 GHz — very visible on a sweep! |
| Analog video tx   | 2400–2483 MHz     | Older wireless AV transmitters        |
| FPV drone video   | 2400–2483 MHz     | Racing drones often use 2.4 GHz video links |
| Baby monitors     | 2400–2483 MHz     | FHSS devices, jumpy activity visible  |
| Wireless CCTV cam | 2400–2483 MHz     | Often narrowband or FHSS              |


#### ⭐ Top Picks in This Range

- **2400–2483 MHz (2.4 GHz ISM)** — the most chaotic 83 MHz in the spectrum; WiFi, Bluetooth, IoT, and interference all at once
- **5G NR n41 (2496–2690 MHz)** — watch for wide 100 MHz 5G carriers in urban areas
- **Microwave oven leakage @ 2450 MHz** — run a sweep while someone heats their lunch
- **Globalstar downlink @ 2483–2500 MHz** — clean narrow carriers if you have line of sight to the sky
- **Amateur 13 cm @ 2304 MHz** — rare but fascinating if a club event is nearby
