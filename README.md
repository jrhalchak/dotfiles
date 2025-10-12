# dotfiles

Configs, set

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

