# ![toolBLEx](assets/gfx/banner.svg)

[![GitHub release](https://img.shields.io/badge/release-0.14-blue?style=flat-square)](https://github.com/emericg/toolBLEx/releases)
[![GitHub action](https://img.shields.io/github/actions/workflow/status/emericg/toolBLEx/builds_desktop.yml?style=flat-square)](https://github.com/emericg/toolBLEx/actions/workflows/builds_desktop.yml)
[![GitHub issues](https://img.shields.io/github/issues/emericg/toolBLEx.svg?style=flat-square)](https://github.com/emericg/toolBLEx/issues)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-brightgreen.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)

A multiplatform Bluetooth Low Energy (and Classic) device scanner and analyzer.

> Available on Linux, macOS, Windows.

#### Features

- Bluetooth host adapters info
- RSSI graph / proximity graph (BLE and classic)
- Device scanner (BLE and classic)
- Device advertisement and services explorer (BLE)
- Read/write on device characteristics data (BLE)
- Export device info: advertisement packets, services and characteristics (with or without values)
- Frequency analyzer (ONLY if you have an Ubertooth One)

#### Download

<a href='https://flathub.org/apps/io.emeric.toolblex'><img width='200' alt='Download on Flathub' src='https://dl.flathub.org/assets/badges/flathub-badge-en.png'/></a>

## Screenshots

![Bluetooth scanner](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/toolBLEx/list1.png)
![BLE device info](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/toolBLEx/list2.png)
![BLE device advertisement](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/toolBLEx/adv1.png)
![BLE device service read](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/toolBLEx/srv1.png)
![GUI dark mode](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/toolBLEx/theme2.png)


## Frequency analyzer (with an Ubertooth One)

![frequency analyzer](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/toolBLEx/freqanalyzer1.webp)


## Documentation

#### Build dependencies

You will need a C++17 compiler and Qt 6.8+ with the following 'additional librairies':  
- Qt Connectivity
- Qt Charts

For macOS builds, you'll need Xcode (15+) installed.  
For Windows builds, you'll need the MSVC (2022) installed. Bluetooth won't work with MinGW.  

#### Building toolBLEx

```bash
$ git clone https://github.com/emericg/toolBLEx.git
$ cd toolBLEx/
$ cmake -B build/
$ cmake --build build/
```

#### Using toolBLEx

##### Linux

Bluetooth driver support might be a little shaky...

- Apple iBeacons are hidden by the OS and don't appear in scan results?

##### macOS

macOS has various limitations regarding Bluetooth handling:  

- Apple iBeacons are hidden by the OS and don't appear in scan results?
- Bluetooth Classic scanning doesn't seem to work at the moment
- MAC addresses are hidden by the OS, and replaced by randomly generated UUIDs, making proper device identification hard

Starting with macOS 11, the application will ask you for permission to use Bluetooth. You can learn more on Apple [developer website](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription).

##### Windows

Bluetooth driver support might be a little shaky...

- Windows doesn't have good enough support for the Ubertooth One, and thus the frequency analyzer is disabled.

#### Third party projects used by toolBLEx

* [Qt6](https://www.qt.io) ([LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* [AppUtils](thirdparty/AppUtils/README.md) ([MIT](https://opensource.org/licenses/MIT))
* [SingleApplication](thirdparty/SingleApplication/README.md) ([MIT](https://opensource.org/licenses/MIT))
* [ComponentLibrary](thirdparty/ComponentLibrary/) ([MIT](https://opensource.org/licenses/MIT))
* [IconLibrary](thirdparty/IconLibrary/) uses a combinaison of licenses, see [COPYING](thirdparty/IconLibrary/COPYING)
* Graphical resources: [assets/COPYING](assets/COPYING)


## Get involved!

#### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

#### Users

You can help us find and report bugs, suggest new features, help with translation, documentation and more! Visit the Issues section of the GitHub page to start!


## License

toolBLEx is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE.md) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

> Emeric Grange <emeric.grange@gmail.com>
