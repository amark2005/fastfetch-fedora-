# Reboot2menu

Reboot directly into **UEFI/BIOS firmware** from Linux.
No key-spamming. No timing roulette. One command. Done.

If your system supports UEFI and `systemd`, this script tells Linux to **reboot straight into firmware setup** using the native, supported method.

---

## 🚀 What It Does

`Reboot2menu` triggers:

```bash
systemctl reboot --firmware-setup
````

# Reboot2menu

Reboot directly into UEFI/BIOS firmware from Linux using a single command.

---

## Description

Reboot2menu is a simple Bash script that reboots a Linux system directly into the firmware (BIOS/UEFI) menu using systemd.

---

## Requirements

- Linux with systemd
- UEFI-based system
- Root (sudo) access

---

## Installation

The script is already executable and placed in `/usr/local/bin`.

Manual install:

```bash
git clone https://github.com/amark2005/reboot2menu.git
cd reboot2menu
sudo cp reboot2bios.sh /usr/local/bin/reboot2menu
sudo chmod +x /usr/local/bin/reboot2menu
````

---

## Usage

Run the command as root:

```bash
sudo reboot2menu
```

The system will reboot directly into the BIOS/UEFI firmware menu.

---

## How It Works

The script uses the following systemd command:

```bash
systemctl reboot --firmware-setup
```

---

## Notes

* Works only on UEFI systems
* Requires systemd
* Firmware support may vary by hardware vendor

---

