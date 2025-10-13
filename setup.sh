#!/bin/bash

source ~/dotfiles/zsh/installs.sh

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")"; pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup"

link() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then
      rm "$dest"
    else
      mkdir -p "$BACKUP_DIR"
      base="$(basename "$dest")"
      backup="$BACKUP_DIR/$base"
      i=1
      while [ -e "$backup" ]; do
        backup="$BACKUP_DIR/${base}.$i"
        i=$((i+1))
      done
      mv "$dest" "$backup"
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Linked $src -> $dest"
}

link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/shared/config/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/shared/config/neorg" "$HOME/.config/neorg"
link "$DOTFILES_DIR/shared/config/wezterm" "$HOME/.config/wezterm"
link "$DOTFILES_DIR/shared/config/kitty" "$HOME/.config/kitty"
link "$DOTFILES_DIR/config/.tmux.conf" "$HOME/.tmux.conf"

#--
#- Exit this script early if running on macOS (Darwin)
# TODO : Handle different platforms better in this file
#--
if [ "$(uname)" = "Darwin" ]; then
  exit 0
fi

# ====================
# Linux Bin Mgmgt
# ====================

link "$DOTFILES_DIR/linux/config/fastfetch" "$HOME/.config/fastfetch"
link "$DOTFILES_DIR/linux/config/i3" "$HOME/.config/i3"
link "$DOTFILES_DIR/linux/config/picom" "$HOME/.config/picom"
link "$DOTFILES_DIR/linux/config/polybar" "$HOME/.config/polybar"

# Bins
for bin_file in "$DOTFILES_DIR/shared/apps/bin"/*; do
  [ -f "$bin_file" ] && link "$bin_file" "$HOME/.local/bin/$(basename "$bin_file")"
done

# xborder special case (it's a directory with executable inside)
if [ -d "$DOTFILES_DIR/shared/apps/bin/xborder" ]; then
  link "$DOTFILES_DIR/shared/apps/bin/xborder/xborders" "$HOME/.local/bin/xborders"
fi

# Icons
mkdir -p "$HOME/.icons/custom/"
for icon_file in "$DOTFILES_DIR/shared/apps/icons"/*; do
  [ -f "$icon_file" ] && link "$icon_file" "$HOME/.icons/custom/$(basename "$icon_file")"
done

# Desktop / Shortcuts
for desktop_file in "$DOTFILES_DIR/shared/apps/desktop"/*; do
  [ -f "$desktop_file" ] && link "$desktop_file" "$HOME/.local/share/applications/$(basename "$desktop_file")"
done

#--
#- Keybaord/mouse automatic binding via udev
#
# Setup input service for use by `udev` (see end of `setup.sh`).
#
# NOTE : Alternatively you can have a sudo-less setup by using `udevmon` from `interception-tools` and create a watcher script, use `acpi_listen` or build an `autostart` listener loop in the i3 startup (or via a `systemd` timer)
#--
link "$DOTFILES_DIR/linux/config/systemd/user/input_watcher.service" "$HOME/.config/systemd/user/input_watcher.service"

echo "Setting up input watcher service..."
"$DOTFILES_DIR/linux/scripts/bootstrap_input_hotplug.sh"

# System-level service config (requires `sudo`)
sudo install -d -m 755 /etc/lightdm/lightdm.conf.d
sudo install -o root -g root -m 644 "$DOTFILES_DIR/linux/lightdm/99-monitor-setup.conf" /etc/lightdm/lightdm.conf.d/99-monitor-setup.conf

sudo install -o root -g root -m 644 "$DOTFILES_DIR/linux/udev/99-input-hook.rules" /etc/udev/rules.d/99-input-hook.rules

sudo udevadm control --reload-rules
sudo udevadm trigger -s input
