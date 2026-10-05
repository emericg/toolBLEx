# toolBLEx

## TODO # v0

[x] host is connectable
[x] proper filtering
[x] grid panel
[x] RSSI graph
[x] keyboard navigation
[x] device icons
[x] device icons in listview
[x] device advertisement UI
[x] device services UI
[x] device services+value export
[x] device advertisement export

[x] device BDD (blacklist)
[x] device BDD (addr, mac, name, model, model_id, coreconfig, first seen, last seen)
[x] device is paired
[x] device services cache
[x] proper UUID display?
[x] improve hex/text view (with monospace view)
[x] improve hex/text view (with selection & edition)

[x] CMake build system
[x] macOS BLE permission
[x] macOS exit to dock is broken
[x] new permission system+
[x] switch from Qt Charts to Qt Graphs
[x] textfields: double click to select
[x] keyboard navigation, move elevators
[x] auto theme switch
[-] better beacon detection
[-] r/w/n: red badges on errors?
[-] sanitize old adapters
[-] write data: explicit max size
[-] write data: check max size
[ ] remove ScreenBluetooth

[x] graphs: unify min/max RSSI values (floorDb, ceilDb)
[x] graphs: change clickable marker text position depending on its position onscreen
[x] graphs: 3D graph legend
[ ] graphs: auto/dynamic bands on sub 2 GHz view

[x] add export comment
[x] add scanning in progress in the device scanner
[x] add export button next to cache button
[x] add clear button next to cache button

## TODO # Qt 6.6

[x] other: print errors?
[x] new permission system
[x] connected device, connected line color
[x] proper TableWidget (resize, select, show/hide columns)
[x] sanitize old devices? (new box in adapter view) (not seen in last 90 days?)

## TODO # v1

[ ] DeviceManager singleton

[ ] AdapterManager singleton
[x] select preferred adapter (only works on linux, OS limitations...)
[x] adapter status (linux)
[ ] adapter status (linux DBUS)
[x] adapter status (macOS)
[ ] adapter status (windows API)

[x] device simulator (v1 - with advertising support)

[x] "known" advertising data parsing / device integration
[-] "known" characteristic data parsing

## TODO # v1+

[ ] device list multiselection?
[ ] RSSI graph multiselection?
[ ] show "new" device badge?

[ ] device simulator (v2 - with advertising & services support)
[ ] "known" characteristic data parsing (v2 - with characteristic catalog)

[ ] Use numbers from NordicSemiconductor / bluetooth-numbers-database?
