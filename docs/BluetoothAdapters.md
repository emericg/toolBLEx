# Bluetooth Adapters

#### good

* CSR8510A10 - this is a quite old chipset with Bluetooth 4.0 only (and apparently there are many cheap adapters pretending to be a CSR8510A10).

* BCM20702A0 - also a quite old chipset with Bluetooth 4.0 only (I can find issues from 2014 with a simple google search).

#### should work / kind'of work

* TP-Link UB500 (RTL8761b)

* ASUS USB-BT500 (RTL8761b) [0b05:190e]
* ASUS USB-BT540 (?)

* UGREEEN BT5.4 CM748 "45134" (BR8654A02) [33fa:0010]
* UGREEEN BT6.0 CM748 "75073" (BR8654A02)

#### unknown

* UGREEEN BT5.4 CM749 "35059" (ATS2851? BR8654?)
* UGREEEN BT5.4 CM748 "35058" (ATS2851? BR8654?)
* UGREEEN BT5.3 CM591 "35995" (ATS2851?)
* UGREEEN BT5.3 CM591 "90225" (ATS2851?)
* UGREEEN BT5.0 CM390 "80889" (?)

* UGREEN BT5.4 BT301 (???)
* UGREEN BT5.3 BT501 (???)

* EDUP EP-B3536 Plus Bluetooth 5.1 (RTL8761BUE) [0bda:876e]

* EDUP EP-B3552 Bluetooth 5.3 (ATS2851) [10d7:b012]

* TP-Link UB600 (8821CU)

* EDIMAX BT-8500 (RTL8761BUV)

# Linux tricks:

### Get device info

```bash
$ lsusb | grep -i bluetooth
```

> Bus 001 Device 004: ID 0b05:17cb ASUSTek Computer, Inc. Broadcom BCM20702A0 Bluetooth

```bash
$ btmgmt info
```

> Index list with 1 item  
> hci0: Primary controller  
>    addr 00:11:22:33:44:55 version 6 manufacturer 15 class 0x6c0104  
>    supported settings: powered connectable fast-connectable discoverable bondable link-security ssp br/edr le advertising secure-conn debug-keys privacy configuration static-addr phy-configuration  
>    current settings: powered ssp br/edr le secure-conn  
>    name desktop-emeric  
>    short name  


```bash
$ bluetoothctl show
```

```bash
$ busctl introspect org.bluez /org/bluez/hci0
```

### Various useful commands

#### check USB autosuspend:

```bash
cat /sys/module/btusb/parameters/enable_autosuspend
```

#### set USB autosuspend off:

```bash
echo 0 | sudo tee /sys/module/btusb/parameters/enable_autosuspend
```

#### check USB autosuspend (per device):

```bash
for i in /sys/bus/usb/devices/*/power/autosuspend; do echo "$i: $(cat $i)"; done
```

#### set USB autosuspend off: (for device X-Y)

```bash
echo 0 | sudo tee /sys/bus/usb/devices/X-Y/power/autosuspend
```


# macOS tricks:

### Get device info

```bash
$ system_profiler -detailLevel full SPBluetoothDataType
```

### Various useful commands

> TODO


# Windows tricks:

> TODO
