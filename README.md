# dotfiles

Configs, set

## (Linux) Launch Order
How i3 / LightDM / polybar / feh/ picom launch together.

## ✅ Evaluation: Should work on reboot!

Everything looks properly configured:

### What will happen on boot:

1. LightDM: Runs setup_monitors.sh → login screen appears on HDMI ✅
2. i3 startup sequence:
   - setup_monitors.sh runs (line 9)
     - Detects displays: HDMI-0, eDP-1-1 ✅
     - Configures xrandr with correct names ✅
     - Waits for displays to be fully active (robust loop) ✅
     - Starts picom with correct display geometry ✅
     - Generates ~/.config/i3/generated.bindings with all 8 workspace assignments ✅
 - set_gaps.sh runs (line 19) - sets gaps only, no xrandr conflicts ✅
 - feh runs (line 22) - wallpaper applied to both monitors correctly ✅
 - polybar/launch.sh runs (line 48) - 3 polybars on correct monitors ✅

### Expected result:

- HDMI monitor: 2 polybars, workspaces 1-5, correct gaps
- Laptop monitor: 1 polybar, workspaces 6-8, correct gaps
- No visual artifacts (picom starts after displays configured)
- Wallpaper correct on both monitors (feh runs after displays stable)

## Todo

- [ ] Look at this [atlassian](https://www.atlassian.com/git/tutorials/dotfiles)

