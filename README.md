# ELAN2513 Linux Touchscreen Driver (HP Pavilion & I2C-HID Laptops)

A lightweight, high-performance native user-space driver for the **Elantech ELAN2513** I2C touchscreen (`PNP0C50` / `04f3:2c3f`) on Linux (Arch Linux, Ubuntu, Debian, Fedora, Manjaro).

Fixes the common issue on HP Pavilion laptops where the ELAN touchscreen is completely unresponsive or returns `-121 EREMOTEIO` / NACK errors with the default `i2c_hid_acpi` kernel module.

---

## ⚠️ Disclaimer & Acknowledgments
- **Author**: Patrice N'Dri (<ndripatrice8@gmail.com>)
- **AI Assistance**: Built & reverse-engineered with the assistance of AI (Google Antigravity AI coding assistant).
- **Note**: While fully tested and working on HP Pavilion 15-eg3xxx laptops, this user-space driver is a work-in-progress workaround. It may not be perfect for every hardware configuration. Pull requests, feedback, and contributions are welcome!

---

## Features
- **Native User-Space Driver**: Bypasses broken `i2c_hid_acpi` 1-byte register reads using raw `/dev/i2c` communication and `/dev/uinput`.
- **1:1 Native Resolution**: Direct pixel mapping (`3888x2160`) for 100% precision under your finger.
- **ACPI Power Management**: Wakes up the digitizer hardware rail via ACPI calls (`_ON` / `_PS0` / `_INI`).
- **Wayland & X11 Support**: Works seamlessly with KDE Plasma, GNOME, Hyprland, Sway, and X11 desktop environments.
- **Automated 1-Click Installer**: GUI & CLI compatible installation.

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/elan2513-touchscreen-driver.git
cd elan2513-touchscreen-driver
sudo ./install.sh
```

Or double-click `install.sh` in your file manager!

---

## Uninstallation

```bash
sudo ./uninstall.sh
```

---

## Technical Details

The ELAN2513 digitizer chip on HP Pavilion laptops suffers from two main issues under Linux:
1. **ACPI Power Gating**: The BIOS ACPI firmware turns off the digitizer power rail (`_PS0` / `_INI` return `0` under Linux).
2. **I2C-HID Protocol Divergence**: Sending `RESET` (`0x05 0x00 0x00 0x01`) locks the ELAN firmware into a `0x55` reset buffer loop. The chip requires a single `POWER ON` opcode (`0x05 0x00 0x00 0x08`) followed by direct `os.read()` frame streaming.

### Packet Decoding Map
- **Report Length**: `b[0] | (b[1] << 8)`
- **Report ID**: `b[2] == 0x01`
- **Contact State**: `b[3] & 0x01` (Tip switch)
- **X Coordinate**: `b[6] | (b[7] << 8)` (0 .. 3888 pixels)
- **Y Coordinate**: `b[10] | (b[11] << 8)` (0 .. 2160 pixels)

---

## License
MIT License - Copyright (c) 2026 Patrice N'Dri
