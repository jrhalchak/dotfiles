# dotfiles

Configs, set

## Overview

- Purpose: Opinionated Linux/macOS dotfiles with i3, Polybar, Kitty/WezTerm, Neovim, and sensible input/display handling.
- Structure: Linux-specific configs and scripts live under `linux/`; shared app configs under `shared/`; shell setup in `zsh/`.

## Bootstrap

- `setup.sh` (Linux):
  - Links configs into `~/.config` and common dotfiles (zsh, tmux).
  - Links helper binaries/icons/desktop entries from `shared/apps`.
  - Installs LightDM and udev settings for display/input.
  - Sets up the input watcher user service and reloads udev.
  - Calls `zsh/installs.sh` to install common tools.
- `zsh/installs.sh` (apt-based distros):
  - Installs essentials: `ripgrep xclip xdotool jq pipx inotify-tools x11-xkb-utils xinput`.
  - Optional tooling: Go, fnm (Node), Rust, Neovim AppImage, WezTerm, Vifm.

## Session Startup (Linux)

- Display manager: LightDM runs `linux/scripts/lightdm_monitors.sh` to configure monitors at greeter.
- i3 session: `linux/config/i3/config` executes `linux/scripts/i3_startup.sh` on login and subscribes to output changes to re-apply layout and inputs.
- Polybar/Picom/Wallpaper are orchestrated from `i3_startup.sh` after xrandr stabilizes.

## Display Handling (xrandr)

- LightDM greeter: `linux/scripts/lightdm_monitors.sh`
  - Detects HDMI/eDP presence and lid state; applies scenarios: `edp_only`, `dual`, or `hdmi_only`.
  - Uses explicit target modes when available; falls back to `--auto` and always exits 0.
  - Logs to `/var/log/lightdm/lightdm-monitors.log` (fallback `/tmp/lightdm-monitors.log`).
- User session: `linux/scripts/monitor_xrandr.sh`
  - Detects current outputs and lid state; applies a matching layout.
  - i3 subscribes to RANDR output events to re-run this script.

## Input Handling (Keyboard/Mouse)

- Primary entry: `linux/scripts/input.sh`
  - Keyboard: applies `setxkbmap -option '' -option caps:swapescape` (fallback to `xmodmap ~/.Xmodmap`).
  - Mouse: enables `"libinput Natural Scrolling Enabled"` on all pointer devices with that property; falls back to button-map inversion on the master pointer.
- Hotplug watcher: `linux/scripts/input_watcher.sh` (systemd --user service)
  - Applies settings at start; polls `xinput list` for changes; listens for `/run/input_trigger` (from udev) to re-apply.
  - Service file: `linux/config/systemd/user/input_watcher.service`.
- Udev hook: `linux/udev/99-input-hook.rules` touches `/run/input_trigger` on keyboard/mouse add/change.

## Useful Paths

- i3 config: `linux/config/i3/config`
- Startup orchestrator: `linux/scripts/i3_startup.sh`
- Display scripts: `linux/scripts/lightdm_monitors.sh`, `linux/scripts/monitor_xrandr.sh`
- Input scripts: `linux/scripts/input.sh`, `linux/scripts/input_watcher.sh`
- Setup scripts: `setup.sh`, `zsh/installs.sh`

## Quick Verify

- Inputs now: `~/dotfiles/linux/scripts/input.sh` then `setxkbmap -query | grep options` and `xinput list-props <ID> | grep -F "libinput Natural Scrolling Enabled ("`.
- Trigger hotplug: `sudo /usr/bin/touch /run/input_trigger`; tail `journalctl --user -u input_watcher -f`.
- Greeter layout: reboot; check `/var/log/lightdm/lightdm-monitors.log` for `scenario=...` and verification lines.

## (Linux) Launch Order
How i3 / LightDM / polybar / feh/ picom launch together.

### Boot sequence:

1. **LightDM**: Runs `lightdm_monitors.sh` → configures displays for login screen
2. **i3 startup**: Executes `i3_startup.sh` (via `exec_always` in i3 config):
   1. Configures displays with xrandr (detects dual/hdmi_only/edp_only)
   2. Waits for displays to be active
   3. Generates `~/.config/i3/generated.bindings` from workspace templates with monitor-specific gap values
   4. Sets wallpaper with feh
   5. Starts/restarts picom compositor (waits for readiness)
   6. Starts polybar instances (2-3 bars depending on monitor config)
   7. Sets wallpaper again (ensures proper compositing)
   8. Renames old workspaces to new naming scheme if needed
   9. Starts xborders for window decorations
   10. Reloads i3 config to apply gap configuration

## Todo

- [ ] Look at this [atlassian](https://www.atlassian.com/git/tutorials/dotfiles)


