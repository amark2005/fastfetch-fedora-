#!/usr/bin/env bash
set -e

echo "🚀 Fedora Ultra-Mobility & Battery Optimization Script"
echo "----------------------------------------------------"

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root (sudo)"
  exit 1
fi

echo "✅ Running as root"

# ----------------------------------------------------
# 1. Remove known troublemakers (safe if not installed)
# ----------------------------------------------------
echo "🧹 Removing conflicting power tools (if any)..."
dnf -y remove auto-cpufreq tlp tuned-ppd intel-undervolt 2>/dev/null || true

# ----------------------------------------------------
# 2. Install required Fedora-native stack
# ----------------------------------------------------
echo "📦 Installing Fedora power stack..."
dnf -y install \
  power-profiles-daemon \
  tuned \
  powertop

# ----------------------------------------------------
# 3. Enable and start services
# ----------------------------------------------------
echo "⚙️ Enabling services..."
systemctl enable --now power-profiles-daemon
systemctl enable --now tuned

# ----------------------------------------------------
# 4. Apply correct profiles
# ----------------------------------------------------
echo "🔋 Applying power profiles..."
powerprofilesctl set power-saver
tuned-adm profile laptop-battery-powersave

# ----------------------------------------------------
# 5. PipeWire audio safety (no stutter)
# ----------------------------------------------------
echo "🎧 Applying PipeWire power-safe config..."
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
PW_DIR="$USER_HOME/.config/pipewire/pipewire.conf.d"

mkdir -p "$PW_DIR"

cat > "$PW_DIR/99-power-safe.conf" <<EOF
context.properties = {
    default.clock.rate = 48000
    default.clock.quantum = 1024
}
EOF

chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} "$USER_HOME/.config"

# Restart audio
sudo -u ${SUDO_USER:-$USER} systemctl --user restart pipewire pipewire-pulse wireplumber

# ----------------------------------------------------
# 6. Bluetooth autosuspend fix (only BT, not USB)
# ----------------------------------------------------
echo "📡 Fixing Bluetooth autosuspend..."
echo "options btusb enable_autosuspend=0" > /etc/modprobe.d/btusb.conf

# ----------------------------------------------------
# 7. Enable deep sleep (real suspend)
# ----------------------------------------------------
echo "💤 Enforcing deep sleep if supported..."
if grep -q deep /sys/power/mem_sleep; then
  grubby --update-kernel=ALL --args="mem_sleep_default=deep"
  echo "✔ Deep sleep enabled"
else
  echo "⚠ Deep sleep not supported on this hardware"
fi

# ----------------------------------------------------
# 8. Intel iGPU power saving (safe)
# ----------------------------------------------------
echo "🖥 Enabling Intel iGPU RC6..."
grubby --update-kernel=ALL --args="i915.enable_rc6=1"

# ----------------------------------------------------
# 9. One-time powertop tuning
# ----------------------------------------------------
echo "⚡ Applying powertop auto-tune (one-time)..."
powertop --auto-tune || true

# ----------------------------------------------------
# 10. Final status report
# ----------------------------------------------------
echo
echo "✅ SETUP COMPLETE"
echo "-----------------"
echo "Active tuned profile:"
tuned-adm active || true
echo
echo "Active power profile:"
powerprofilesctl || true
echo
echo "Suspend mode:"
cat /sys/power/mem_sleep || true
echo
echo "🔁 Reboot recommended to apply kernel parameters"
echo "🚀 Fedora is now optimized for ultra mobility & battery life"
