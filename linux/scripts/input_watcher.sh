#!/bin/bash

log() { echo "input_watcher: $*"; }

get_session_env() {
  local pid envfile disp xauth
  pid=$(pgrep -u "$USER" -x i3 | head -n1 || true)
  if [ -n "$pid" ] && [ -r "/proc/$pid/environ" ]; then
    envfile=$(tr '\0' '\n' < "/proc/$pid/environ")
    disp=$(printf "%s\n" "$envfile" | awk -F= '/^DISPLAY=/{print $2; exit}')
    xauth=$(printf "%s\n" "$envfile" | awk -F= '/^XAUTHORITY=/{print $2; exit}')
    [ -n "$disp" ] && echo "$disp"; echo "::"; [ -n "$xauth" ] && echo "$xauth"
    return 0
  fi
  echo "::"
}

apply() {
  local detected detected_display detected_xauth candidates d auth
  detected=$(get_session_env)
  detected_display=$(printf "%s" "$detected" | awk -F'::' '{print $1}')
  detected_xauth=$(printf "%s" "$detected" | awk -F'::' '{print $2}')

  candidates=( ${DISPLAY:+$DISPLAY} ${detected_display:+$detected_display} :0 :1 :2 )
  auth=${XAUTHORITY:-${detected_xauth:-$HOME/.Xauthority}}

  for d in "${candidates[@]}"; do
    [ -n "$d" ] || continue
    if DISPLAY="$d" XAUTHORITY="$auth" xset q >/dev/null 2>&1; then
      log "applying via DISPLAY=$d XAUTHORITY=$auth"
      DISPLAY="$d" XAUTHORITY="$auth" ~/dotfiles/linux/scripts/input.sh
      return 0
    fi
  done
  log "could not find a working DISPLAY; will retry on next event"
  return 1
}

# Apply once on start so settings are in place even before hotplug
apply

# Fallback poller: re-apply when X input device list changes (handles BT/receiver reconnects)
(
  last=""
  while sleep 2; do
    # derive a working DISPLAY/XAUTH from the session
    detected=$(get_session_env)
    d=$(printf "%s" "$detected" | awk -F'::' '{print $1}')
    a=$(printf "%s" "$detected" | awk -F'::' '{print $2}')
    d=${d:-${DISPLAY:-:0}}
    a=${a:-${XAUTHORITY:-$HOME/.Xauthority}}
    out=$(DISPLAY="$d" XAUTHORITY="$a" xinput list --name-only 2>/dev/null | sort || true)
    [ -n "$out" ] || continue
    sum=$(printf "%s\n" "$out" | md5sum | awk '{print $1}')
    if [ "$sum" != "$last" ]; then
      log "device list changed; reapplying"
      apply
      last="$sum"
    fi
  done
) &

# Watch for udev-triggered touches to /run/input_trigger
inotifywait -m -e create,modify,attrib,close_write /run | while read -r path action file; do
  [ "$file" = "input_trigger" ] || continue
  apply
done
