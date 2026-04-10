![Wiintosh logo](https://github.com/Wiintosh/.github/blob/main/profile/logo.png)
---

Wiintosh is a collection of projects to enable creation of a Hackintosh on the Wii and Wii U consoles. These used a variant of the PowerPC 750 (named Broadway and Espresso respectively) which is the same as the PowerPC G3 used in a variety of Macs supported by Mac OS X 10.0 to 10.4.

Running Mac OS X is accomplished with an Open Firmware implementation (OpenBIOS) loaded from a CFW running on the Starlet or Starbuck. Patches to XNU/BootX are applied and drivers are injected during the BootX load process.

This is still very much a work in progress and there will be instablity and bugs encountered, and not all hardware or possible Mac OS X versions are supported at this time.

## Repositories
* [wii-loader](https://github.com/Wiintosh/wii-loader) - First stage MINI-based loader for Wii consoles
* [wiiu-loader](https://github.com/Wiintosh/wiiu-loader) - First stage linux-loader based loader for Wii U consoles
* [openbios](https://github.com/Wiintosh/openbios) - OpenBIOS implementation for the Wii and Wii U hardware
* [osx-drivers](https://github.com/Wiintosh/osx-drivers) - Kernel extensions for Mac OS X supporting Wii and Wii U hardware


## Installation

### Requirements
Either a Wii with [BootMii](https://bootmii.org) or a Wii U with [Aroma](https://aroma.foryour.cafe) is required. You will also need a reasonably sized SD card and a USB keyboard/mouse. Currently instructions are provided for macOS only, but Linux can be used as well.

Partition the card as Apple Partition Map (APM), creating three partitions:
* FAT32 boot partition
* Mac OS X system partition
* Mac OS X installer partition

The installer partition can eventually be removed later once Mac OS X has been installed.
```
diskutil partitionDisk diskX APM \
    FAT32 "BOOT" 128M \
    HFS+ "Hackintosh HD" R \
    HFS+ "Installer" 4G
```

Mount the OS X ISO and restore it to the Installer partition, i.e:

```sudo asr restore --source /Volumes/Mac\ OS\ X\ Install\ Disc\ 1 --target /Volumes/Installer --erase```

Create the hybrid MBR / APM to allow the Wii to boot off the SD card:

Download the required boot files and place at the root of the BOOT partition:
1. fw.img from the latest release of [wiiu-loader](https://github.com/Wiintosh/wiiu-loader)
2. fw.img loader Aroma payload and place at the root of the BOOT partition (should be a wiiu folder)
3. openbios.elf from the latest release of [openbios](https://github.com/Wiintosh/openbios)
4. Wii.mkext from the latest release of [osx-drivers](https://github.com/Wiintosh/osx-drivers)

## Support status

### Version status

| Version       | Supported                  |
|---------------|----------------------------|
| 10.0 Cheetah  | No                         |
| 10.1 Puma     | No                         |
| 10.2 Jaguar   | Yes                        |
| 10.3 Panther  | Yes (Wii U only)           |
| 10.4 Tiger    | Yes, but cannot use installer (Wii U only) |
| 10.5 Leopard  | Never, requires a G4       |
| 10.6 Snow Leopard | Never, requires a G4   |

### Wii hardware support status
| Hardware                                            | Supported                                   |
|-----------------------------------------------------|---------------------------------------------|
| Broadway primary interrupt controller               | Yes                                         |
| Hollywood secondary interrupt controller            | Yes                                         |
| USB 1.1 (OHCI) controller (rear ports)              | Yes                                         |
| USB 1.1 (OHCI) controller (internal Bluetooth)      | Bluetooth does not load                     |
| USB 2.0 (EHCI) controller (rear ports)              | No                                          |
| SD host controller (front SD slot)                  | Yes, SDHC only                              |
| WiFi via SDIO                                       | No                                          |
| Audio interface (rear A/V)                          | Yes, not all media may work                 |
| Flipper video interface                             | 32-bit framebuffer via Starlet -> XFB       |
| External interface                                  | RTC (partially), slots are nonfunctional    |
| Serial interface (GameCube controllers)             | No                                          |
| DVD drive                                           | No                                          |
| Power/reset switches                                | No                                          |
| Shutdown/reboot functionality                       | Yes                                         |

### Wii U hardware support status
| Hardware                                            | Supported                                   |
|-----------------------------------------------------|---------------------------------------------|
| Espresso primary interrupt controller               | Yes                                         |
| Latte secondary interrupt controller                | Yes                                         |
| USB 1.1 (OHCI) controller (rear ports)              | Yes                                         |
| USB 1.1 (OHCI) controller (internal Bluetooth)      | Bluetooth does not load                     |
| USB 1.1 (OHCI) controller (front ports)             | Yes                                         |
| USB 2.0 (EHCI) controller (rear ports)              | No                                          |
| USB 2.0 (EHCI) controller (front ports)             | No                                          |
| USB 2.0 (EHCI) controller (GamePad)                 | No                                          |
| SD host controller (front SD slot)                  | Yes, SDHC only                              |
| WiFi via SDIO                                       | No                                          |
| Audio interface (rear A/V)                          | Yes, not all media may work                 |
| Audio interface (GamePad)                           | Yes, not all media may work                 |
| GX2 video interface                                 | 32/16/8-bit TV framebuffer, hardware cursor |
| External interface                                  | RTC (partially)                             |
| DVD drive                                           | No                                          |
| Power/reset switches                                | No                                          |
| Shutdown/reboot functionality                       | Yes                                         |

## Credits
- [Apple](https://www.apple.com) for Mac OS X
- [Goldfish64](https://github.com/Goldfish64) for this software
- [Wiibrew.org](https://wiibrew.org) / [Wiiubrew.org](https://wiiubrew.org) for various documents/info
- [Yet Another Gamecube Documenation](https://www.gc-forever.com/yagcd/)
