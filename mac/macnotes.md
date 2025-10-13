
# Notes on MacOS "ricing"

MacOS has head/face tracking for mouse movement if hammerspoon + keys fails, lol.

## Apps (mostly installed via homebrew)
- ~~**yabai**: tiling wm~~
- ~~**skhd**: keybindg daemon for calling yabai~~
- ~~**barik**: menu bar~~
- **ubersicht**: widgets and stuff
- **sol**: launcher
- **sketchybar**: menu bar
  - [dotfiles example](https://github.com/bfpimentel/nixos/blob/main/modules/home-manager/hosts/solaire/sketchybar/config/init.lua)
- **hammerspoon** (L)
- **jankyborders**: border focus changes
- **shortcat**: vim like bindings for MacOS
  - not sure if I'll keep
- **karabiner elements**: for keybindings on mouse-move, etc
- ~~**FnMate (Spoon)**: use fn + hjkl for mouse (and yuio for scroll)~~
  - FnMate doesn't seem to do what I thought and my hammerspoon remaps didn't work for mouse keys, using _karabiner_
  - also emoji picker spoon, brew info spoon... a bunch that look good & it's extensible
- **fastfetch**: like fetch/neofetch for displaying sysinfo and ascii art on terminal start

## Apps To Instal
- **Qutebrowser** (keyboard browser, cool features, youtube -> mpv)
  - use this alongside chrome instead of ff?
  - will need VLC or something for mpv

## Apps that Look Promising
- **pecan**: menu bar
- **demnu**: top-menu(?) app launcher
- **simple-bar**: top bar (has tokyonight style)
- **alfred**: open source launcher for
  - _Note_: [ULauncher](https://ulauncher.io/) is a linux alternative

## Settings I've Changed & Things I've Added
- Finder
  - list them
- Keyboard shortcuts
  - list them
- Brew services
- Applescript
- Config files
  - list them and move them to dotfiles if they're not there


## Configs / Instructions

### Yabai
**Config file**: `.yabairc`

**Command for service**: `yabai --start-service`
(The service should be added to autostart if it's not present)

Yabai requires disabling SIP for certain things (transparent windows, no shadows, etc).

### Custom Bars
To autohide:
```
macOS Big Sur:
System Preferences -> General -> Automatically hide and show the menu bar.

macOS Monterey:
System Preferences -> Dock & Menu bar -> Select Dock & Menu bar in left sidebar

macOS Ventura:
System Settings -> Desktop & Dock -> Scroll down to the Menu Bar heading

macOS Sonoma:
System Settings -> Control Centre -> Scroll down to "Automatically Hide and Show the menu bar"
```


### Dock Hiding
[This article from Lifehacker.com.au](http://www.lifehacker.com.au/2012/09/how-to-disable-the-dock-in-mountain-lion/) suggests setting the Dock autohide delay to 1000 seconds, like so:
```
defaults write com.apple.dock autohide-delay -float 1000; killall Dock
```

To restore the default behavior:
```
defaults delete com.apple.dock autohide-delay; killall Dock
```

The author says he sets the delay to two seconds, so he can still get to the Dock in those rare cases when it's needed.

### SKHD
**NOT USING**

**Config file**: `.skhd`

**Command for service**: `skhd --start-service`
(The service should be added to autostart if it's not present)
