#!/bin/bash
# picom -b --config ~/.config/picom.conf
log() { echo "input.sh: $*"; }

# Prefer XKB option for Caps<->Escape swap; fallback to xmodmap
if command -v setxkbmap >/dev/null 2>&1; then
  setxkbmap -option '' -option caps:swapescape
  log "applied setxkbmap caps:swapescape"
else
  xmodmap ~/dotfiles/linux/.Xmodmap
  log "applied xmodmap from ~/.Xmodmap"
fi

# Apply natural scrolling on all libinput pointer devices; fall back to inversion if none succeed.
if command -v xinput >/dev/null 2>&1; then
  prop="libinput Natural Scrolling Enabled"
  changed=0
  # Iterate over all slave pointer device IDs
  while IFS= read -r id; do
    # Only touch devices that expose the property
    if xinput list-props "$id" 2>/dev/null | grep -Fq "$prop ("; then
      xinput set-prop "$id" "$prop" 1 2>/dev/null || true
      line=$(xinput list-props "$id" 2>/dev/null | grep -F "$prop (" | head -n1)
      val=$(printf "%s\n" "$line" | awk -F': ' '{print $2; exit}')
      if [ "$val" = "1" ]; then changed=1; fi
    fi
  done < <(xinput --list | awk '/slave[[:space:]]+pointer/{if (match($0,/id=([0-9]+)/,m)) print m[1]}')

  if [ "$changed" -ne 1 ]; then
    # Fallback: invert wheel on master pointer by swapping 4<->5 and 6<->7
    mapline=$(xinput get-button-map "Virtual core pointer" 2>/dev/null || true)
    if [ -n "$mapline" ]; then
      read -r -a map <<<"$mapline"
      if [ ${#map[@]} -ge 7 ]; then
        tmp=${map[3]}; map[3]="${map[4]}"; map[4]="$tmp"
        tmp=${map[5]}; map[5]="${map[6]}"; map[6]="$tmp"
        xinput set-button-map "Virtual core pointer" "${map[@]}" 2>/dev/null || true
      fi
    fi
  fi
fi
