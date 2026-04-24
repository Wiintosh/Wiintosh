![Wiintosh logo](https://github.com/Wiintosh/.github/blob/main/profile/logo.png)
---

Wiintosh is a collection of projects to enable creation of a Hackintosh on the Wii and Wii U consoles. These used a variant of the PowerPC 750 (named Broadway and Espresso respectively) which is the same as the PowerPC G3 used in a variety of Macs supported by Mac OS X 10.0 to 10.4.

Running Mac OS X is accomplished with an Open Firmware implementation (OpenBIOS) loaded from a CFW running on the Starlet or Starbuck. Patches to XNU/BootX are applied and drivers are injected during the BootX load process.

**Note:** This is still very much a work in progress and there will be instablity and bugs encountered, and not all hardware or possible Mac OS X versions are supported at this time. Currently Wii U is the best supported as the Wii does not have enough resources to run most OS X versions. Contributions/suggestions to code and documentation is welcome.

## Repositories
* [wii-loader](https://github.com/Wiintosh/wii-loader) - First stage MINI-based loader for Wii consoles
* [wiiu-loader](https://github.com/Wiintosh/wiiu-loader) - First stage linux-loader based loader for Wii U consoles
* [openbios](https://github.com/Wiintosh/openbios) - OpenBIOS implementation for the Wii and Wii U hardware
* [osx-drivers](https://github.com/Wiintosh/osx-drivers) - Kernel extensions for Mac OS X supporting Wii and Wii U hardware


## Installation

### Requirements
Either a Wii with [BootMii](https://bootmii.org) or a Wii U with [Aroma](https://aroma.foryour.cafe) is required. You will also need a reasonably sized SD card and a USB keyboard/mouse. Currently instructions are provided for macOS only, but Linux can be used as well.

### SD card partitioning
Partition the card as Apple Partition Map (APM), creating three partitions:
* FAT32 boot partition
* Mac OS X system partition
* Mac OS X installer partition (example shows 1GB, but this may need to be larger for newer versions of Mac OS X, i.e. Tiger)

The installer partition can eventually be removed later once Mac OS X has been installed.
```
diskutil partitionDisk diskX APM \
    "MS-DOS FAT32" "BOOT" 128M \
    HFS+ "Hackintosh HD" R \
    HFS+ "Installer" 1G
```

### Installer creation
Mount the OS X ISO and restore it to the Installer partition, i.e:

```sudo asr restore --source /Volumes/Mac\ OS\ X\ Install\ Disc\ 1 --target /Volumes/Installer --erase```

DD can also be used, ensure both the ISO and partition are unmounted and copy the installer partition to the SD card:

```sudo dd if=/dev/diskXsY of=/dev/diskAsB bs=4096 status=progress```

### SD card prep and boot files
Download [make-hybrid-mbr.sh](make-hybrid-mbr.sh) and create the hybrid MBR / APM to allow the Wii to boot off the SD card. The script will prompt for the disk and modify the MBR.

Download the required boot files and place at the root of the BOOT partition:
1. First-stage loader
    * Wii
        1. armboot.bin from the latest release of [wii-loader](https://github.com/Wiintosh/wii-loader) and place into a folder named `bootmii`
    * Wii U
        1. fw.img from the latest release of [wiiu-loader](https://github.com/Wiintosh/wiiu-loader)
        2. fw.img loader Aroma payload, placed into a folder named `wiiu`
2. openbios-wii.elf from the latest release of [openbios](https://github.com/Wiintosh/openbios)
    * This **must** be renamed to openbios.elf
3. Drivers mkext from the latest release of [osx-drivers](https://github.com/Wiintosh/osx-drivers)
    * Download the mkext version appropriate for the Mac OS X version being installed. If multi-booting, ensure all applicable versions are present.
    * The Kexts folder is provided as a reference only and does not need to be copied to the SD card

### Boot and installation
Insert the SD card into the console. On the Wii, BootMii will startup OpenBIOS automatically. On the Wii U enter Aroma and load the fw.img loader payload. By default, the system should load the Mac OS X installer. Once in the installer, you can install OS X as normal to the previously created system partition.

**NOTE:** OpenBIOS keyboard input currently does not function on the Wii. If the installer partition does not auto boot, you may need to manually bless the installer partition.

If the installer does not boot, run `load hd:X,\\:tbxi` to boot the installer, where `X` is the installer partition.

* To prevent automatic boot, create a file named `disable-autoboot` at the root of the BOOT partition.
* To boot in verbose, run `setenv boot-args "-v"` prior to booting Mac OS X.
* To boot in single user, run `setenv boot-args "-s"` prior to booting Mac OS X.

## Post installation
Some versions of OS X will require modifications to IOAudioFamily and IOGraphicsFamily for audio and the framebuffer to work. You'll need to edit both to ensure they are loaded at bootup.

`sudo vi /System/Library/Extensions/IOAudioFamily.kext/Contents/Info.plist`
`sudo vi /System/Library/Extensions/IOGraphicsFamily.kext/Info.plist`

For both files, type `i` to enter insert mode and append the following after the last key, but before the closing plist:

```
<key>OSBundleRequired</key>
<string>Root</string>
```

Save and quit with `:wq`.

After both edits are made, run `sudo touch /System/Library/Extensions` to force a kext cache rebuild and reboot. The next bootup may take several minutes as the system will boot without a kext cache. Once booted, graphics framebuffer and audio should be fully functional.

## Support status

### Version status

| Version       | Supported                  |
|---------------|----------------------------|
| 10.0 Cheetah  | Yes, no audio              |
| 10.1 Puma     | Yes                        |
| 10.2 Jaguar   | Yes                        |
| 10.3 Panther  | Yes (Wii U only)           |
| 10.4 Tiger    | Yes, use a 10.4.0 installer (Wii U only) |
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
