# ![toolBLEx](assets/logos/banner.svg)

[![GitHub action](https://img.shields.io/github/actions/workflow/status/emericg/toolBLEx/builds_desktop_qmake.yml?style=flat-square)](https://github.com/emericg/toolBLEx/actions/workflows/builds_desktop_qmake.yml)
[![GitHub issues](https://img.shields.io/github/issues/emericg/toolBLEx.svg?style=flat-square)](https://github.com/emericg/toolBLEx/issues)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-brightgreen.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)

A Bluetooth Low Energy device scanner and analyzer.

> Available on Linux, macOS, Windows.

- host adapters info
- RSSI graph / proximity graph (BLE and classic)
- device scanner (BLE and classic)
- device advertisement and service explorer (BLE)
- export device info: advertisement packets, services and characteristics (with or without walues)
- frequency analyzer (ONLY if you have an Ubertooth One)


## Screenshots

![GUI_DESKTOP1](https://i.imgur.com/0wAUe0t.png)
![GUI_DESKTOP2](https://i.imgur.com/5IXNUJ3.png)
![GUI_DESKTOP3](https://i.imgur.com/Rkb1pJX.png)
![GUI_DESKTOP4](https://i.imgur.com/BtGO6rG.png)
![GUI_DESKTOP5](https://i.imgur.com/bv2oMz6.png)


## Documentation

#### Dependencies

You will need a C++17 compiler and Qt 6.3+ with the following 'additional librairies':  
- Qt 5 Compatibility Module
- Qt Connectivity
- Qt Charts

For Windows builds, you'll need the MSVC 2019+ compiler. Bluetooth won't work with MinGW.  
For macOS builds, you'll need Xcode 12+ installed.  

#### Building toolBLEx

```bash
$ git clone https://github.com/emericg/toolBLEx.git
$ cd toolBLEx/
$ qmake6
$ make
```

#### Using toolBLEx

##### Linux

Bluetooth support might be a little shaky?!

##### macOS

macOS has various limitations regarding Bluetooth handling:  
- MAC addresses are hidden by the OS, and replaced by randomly generated UUIDs, making proper device identification hard
- Apple iBeacons are hidden by the OS and don't appear in scan results
- Bluetooth Classic scanning doesn't seem to work at the moment

Starting with macOS 11, the application will ask you for permission to use Bluetooth. You can learn more on Apple [developer website](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription).

##### Windows

Bluetooth driver support might be a little shaky...

Windows doesn't have good enough support for the Ubertooth One, and thus the frequency analyzer is disabled.

#### Third party projects used by toolBLEx

* [Qt6](https://www.qt.io) ([LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* [SingleApplication](https://github.com/itay-grudev/SingleApplication) ([MIT](https://opensource.org/licenses/MIT))
* Graphical resources: [assets/COPYING](assets/COPYING)


## Get involved!

#### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

#### Users

You can help us find and report bugs, suggest new features, help with translation, documentation and more! Visit the Issues section of the GitHub page to start!


## License

toolBLEx is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

> Emeric Grange <emeric.grange@gmail.com>
