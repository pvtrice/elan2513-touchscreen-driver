#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  if command -v pkexec &>/dev/null; then
    exec pkexec "$0" "$@"
  else
    echo "Error: Root privileges required. Run with: sudo ./install.sh"
    exit 1
  fi
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "=== 1. Installing dependencies ==="
if command -v pacman &>/dev/null; then
  pacman -Sy --needed --noconfirm python python-evdev i2c-tools acpi_call-dkms || true
elif command -v apt-get &>/dev/null; then
  apt-get update && apt-get install -y python3 python3-evdev i2c-tools acpi-call-dkms || true
elif command -v dnf &>/dev/null; then
  dnf install -y python3 python3-evdev i2c-tools acpi_call || true
fi

echo "=== 2. Loading i2c-dev kernel module ==="
modprobe i2c-dev || true
echo "i2c-dev" > /etc/modules-load.d/i2c-dev.conf

echo "=== 3. Installing ACPI power service ==="
cat << 'ACPI_EOF' > /etc/systemd/system/touchscreen-power.service
[Unit]
Description=Power ON ELAN Touchscreen via ACPI Call
DefaultDependencies=no
Before=sysinit.target elan-touchscreen.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'modprobe acpi_call 2>/dev/null; echo "\_SB.PC00.I2C0.PTPL._ON" > /proc/acpi/call 2>/dev/null; echo "\_SB.PC00.I2C0.TPL1._PS0" > /proc/acpi/call 2>/dev/null; echo "\_SB.PC00.I2C0.TPL1._INI" > /proc/acpi/call 2>/dev/null'

[Install]
WantedBy=multi-user.target
ACPI_EOF

echo "=== 4. Copying daemon script ==="
cp "$DIR/elan-touchscreen-daemon" /usr/local/bin/elan-touchscreen-daemon
chmod +x /usr/local/bin/elan-touchscreen-daemon

echo "=== 5. Installing systemd driver service ==="
cat << 'SERVICE_EOF' > /etc/systemd/system/elan-touchscreen.service
[Unit]
Description=ELAN2513 Native Touchscreen Driver Daemon
After=multi-user.target touchscreen-power.service
Wants=touchscreen-power.service

[Service]
Type=simple
ExecStart=/usr/local/bin/elan-touchscreen-daemon
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "=== 6. Enabling and starting services ==="
systemctl daemon-reload
systemctl enable --now touchscreen-power.service
systemctl enable --now elan-touchscreen.service

if command -v notify-send &>/dev/null; then
  notify-send "ELAN Touchscreen Driver" "Installation successful! Touchscreen is active."
fi

echo "Installation complete!"
