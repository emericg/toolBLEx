# Ubertooth One support in toolBLEx

toolBLEx can use an **Ubertooth One** (RTL2832U-based USB dongle) as a 2.3 - 2.6 GHz spectrum source.  
This document describes what the device can do, which tools drive it, and how the `Ubertooth` backend is wired.  

> https://greatscottgadgets.com/ubertoothone/

> https://ubertooth.readthedocs.io/en/latest/


## How an Ubertooth One works

Ubertooth One is the hardware platform of Project Ubertooth.

- **RP-SMA** RF connector: connects to test equipment, **antenna**, or dummy load.
- **CC2591** RF front end.
- **CC2400** wireless transceiver.
- **LPC175x ARM Cortex-M3** microcontroller with Full-Speed **USB 2.0**.
- **USB A** plug: connects to host computer running Kismet or other host code.


## Frequency range

The Ubertooth One is able to capture and demodulate signals in the **2.4 GHz** ISM band with a bandwidth of **1 MHz**.

Its range for spectrum analysis can be extended a bit, with reduced sensibility. We set these limits to **2300 to 2600 MHz** in toolBLEx, like int the original `ubertooth-specan-ui` tool.


## Capture backend

toolBLEx drives the Ubertooth One with the `ubertooth-specan` command-line tool.
It is spawned as a child process and its oupput parsed line-by-line.

And the default UI is a rip-off `ubertooth-specan-ui` :) It has been expanded with 3D and waterfall graph since then though.

### Setup

* Generic info

> https://ubertooth.readthedocs.io/en/latest/build_guide.html

#### Linux

* ArchLinux

> pikaur -S ubertooth

#### macOS

> brew install ubertooth

### Commands issued by the `Ubertooth` class

> ubertooth-util -v

> ubertooth-specan -l(lowerFreq) -u(higherFreq) [-U deviceIndex]  
> ubertooth-specan -l2300 -u2600 -U 0  

### Output format details

* ubertooth-util -v

```
Firmware version: 2020-12-R1 (API:1.07)
```

* ubertooth-specan

> CSV format: "timestamp (seconds), freq (MHz), rssi (dB)"

```
128.975251, 2402, -44
128.975251, 2403, -43
128.975251, 2404, -41
```


## Known limitations

- Most efficient in the **2.4 GHz** band.
- **The device is not produced anymore...** You can still find some on the Internet though.
