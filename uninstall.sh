#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  if command -v pkexec &>/dev/null; then
    exec pkexec "$0" "$@"
  else
    echo "Error: Root privileges required. Run with: sudo ./uninstall.sh"
    exit 1
  fi
fi

echo "=== Stopping and disabling services ==="
systemctl disable --now elan-touchscreen.service || true
systemctl disable --now touchscreen-power.service || true

rm -f /etc/systemd/system/elan-touchscreen.service
rm -f /etc/systemd/system/touchscreen-power.service
rm -f /usr/local/bin/elan-touchscreen-daemon

systemctl daemon-reload

echo "Uninstallation complete!"
