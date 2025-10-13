#!/usr/bin/env bash
set -euo pipefail

DF="${DOTFILES_DIR:-$HOME/dotfiles}"
UDEV_RULE_SRC="$DF/linux/udev/99-input-hook.rules"
UDEV_RULE_DST="/etc/udev/rules.d/99-input-hook.rules"
SERVICE_NAME="input_watcher.service"
SERVICE_PATH_USER="$HOME/.config/systemd/user/$SERVICE_NAME"

printf '[bootstrap] Input hotplug bootstrap starting...\n'

# 1) Verify user service file exists (setup.sh links it earlier)
if [ ! -e "$SERVICE_PATH_USER" ]; then
  printf '[bootstrap] Warning: %s missing; ensure setup.sh linked it.\n' "$SERVICE_PATH_USER"
fi

# 2) Install udev rule and reload (requires sudo)
if command -v sudo >/dev/null 2>&1; then
  sudo install -o root -g root -m 644 "$UDEV_RULE_SRC" "$UDEV_RULE_DST"
  sudo udevadm control --reload-rules
  sudo udevadm trigger -s input || true
  printf '[bootstrap] Udev rule installed and reloaded.\n'
else
  printf '[bootstrap] Warning: sudo not found — skipping udev rule install.\n'
fi

# 3) Start via systemd-user if available; else fall back to background
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload || true
  if systemctl --user enable --now "$SERVICE_NAME"; then
    printf '[bootstrap] %s enabled and started.\n' "$SERVICE_NAME"
    # Keep user services running across logouts (best-effort)
    if command -v loginctl >/dev/null 2>&1; then
      sudo loginctl enable-linger "$USER" || true
      printf '[bootstrap] Linger enabled for %s.\n' "$USER"
    fi
  else
    printf '[bootstrap] systemd --user not usable; starting watcher directly.\n'
    nohup "$DF/linux/scripts/input_watcher.sh" >/dev/null 2>&1 &
  fi
else
  printf '[bootstrap] systemctl not found; starting watcher directly.\n'
  nohup "$DF/linux/scripts/input_watcher.sh" >/dev/null 2>&1 &
fi

# 4) Dependency check
if ! command -v inotifywait >/dev/null 2>&1; then
  printf '[bootstrap] Note: install inotify-tools to enable hotplug watcher.\n'
fi

# Optional smoke test: RUN_SMOKE_TEST=1 ./bootstrap_input_hotplug.sh
if [ "${RUN_SMOKE_TEST:-0}" = "1" ] && command -v sudo >/dev/null 2>&1; then
  sudo /usr/bin/touch /run/input_trigger || true
  printf '[bootstrap] Smoke test trigger touched at /run/input_trigger.\n'
fi

printf '[bootstrap] Done.\n'