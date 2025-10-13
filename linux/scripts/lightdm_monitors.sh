#!/usr/bin/env bash
#
# Robust monitor setup for LightDM login screen
# - Prefers HDMI as primary when connected; otherwise uses eDP (laptop panel)
# - Applies explicit modes and positions when available
# - Verifies configuration and gracefully falls back to safer settings
# - Never causes LightDM to loop: always exits 0
#
# Notes:
# - Self-contained: does not depend on $HOME files
# - Logs to /var/log/lightdm/lightdm-monitors.log (falls back to /tmp when not writable)
# - Optional dry-run: LIGHTDM_MONITORS_DRYRUN=1 to print planned commands

# --------------- Config -----------------
HDMI_TARGET_MODE="3840x2160"
EDP_TARGET_MODE="1920x1080"
# Fallback vertical offset if dynamic centering can't be computed
EDP_FALLBACK_OFFSET_Y=540
# How many times to retry before soft fallback
RETRIES=2
SLEEP_BETWEEN=1

# --------------- Logging ----------------
log_file="/var/log/lightdm/lightdm-monitors.log"
{
  ts() { date '+%Y-%m-%d %H:%M:%S'; }
  log() { echo "$(ts) lightdm_monitors: $*"; }

  # Choose a writable log destination before redirecting
  if ! : >>"$log_file" 2>/dev/null; then
    log_file="/tmp/lightdm-monitors.log"
    : >>"$log_file" 2>/dev/null || true
  fi
  exec >>"$log_file" 2>&1

  log "---- script start (pid $$) ----"
  log "ENV: DISPLAY=${DISPLAY:-<unset>} XAUTHORITY=${XAUTHORITY:-<unset>} DRYRUN=${LIGHTDM_MONITORS_DRYRUN:-0}"

  # --------------- Helpers ---------------
  run() {
    if [ "${LIGHTDM_MONITORS_DRYRUN:-0}" = "1" ]; then
      log "DRYRUN: $*"
      return 0
    else
      log "RUN: $*"
      "$@"
      return $?
    fi
  }

  xrandr_ok() {
    xrandr --query >/dev/null 2>&1
  }

  # Extract connected outputs (first match)
  detect_outputs() {
    local hdmi edp
    hdmi=$(xrandr --query | awk '/^HDMI[^ ]* connected/{print $1; exit}')
    edp=$(xrandr --query | awk '/^eDP[^ ]* connected/{print $1; exit}')
    HDMI_OUTPUT="$hdmi"
    EDP_OUTPUT="$edp"
    log "detected: HDMI_OUTPUT=${HDMI_OUTPUT:-<none>} EDP_OUTPUT=${EDP_OUTPUT:-<none>}"
  }

  # Lid state (open/closed) using ACPI proc; default to open if unreadable
  lid_state() {
    local s f
    for f in /proc/acpi/button/lid/*/state; do
      [ -r "$f" ] || continue
      s=$(cat "$f")
      [ -n "$s" ] && break
    done
    echo "$s" | grep -qi "closed" && echo closed || echo open
  }

  # Check if a given mode appears under an output's mode list
  mode_available() {
    local out="$1" mode="$2"
    [ -n "$out" ] || return 1
    xrandr --query |
      sed -n "/^$out[[:space:]]/,/^[^[:space:]]/p" |
      grep -Eq "^[[:space:]]+$mode(\s|$)"
  }

  # Verify active mode (starred) and primary for an output
  active_mode_is() {
    local out="$1" mode="$2"
    [ -n "$out" ] || return 1
    xrandr --query |
      sed -n "/^$out[[:space:]]/,/^[^[:space:]]/p" |
      grep -Eq "^[[:space:]]+$mode\b.*\*"
  }

  output_has_active_mode() {
    local out="$1"
    [ -n "$out" ] || return 1
    xrandr --query | sed -n "/^$out[[:space:]]/,/^[^[:space:]]/p" | grep -q '\*'
  }

  is_primary() {
    local out="$1"
    [ -n "$out" ] || return 1
    xrandr --query | grep -Eq "^$out\b.*primary"
  }

  # Compute vertical offset to center EDP relative to HDMI using target modes
  compute_edp_offset_y() {
    local h_h w_h h_e w_e
    h_h=${HDMI_TARGET_MODE#*x}; w_h=${HDMI_TARGET_MODE%x*}
    h_e=${EDP_TARGET_MODE#*x};  w_e=${EDP_TARGET_MODE%x*}
    if [[ "$h_h" =~ ^[0-9]+$ && "$h_e" =~ ^[0-9]+$ && $h_h -ge $h_e ]]; then
      echo $(( (h_h - h_e) / 2 ))
    else
      echo "$EDP_FALLBACK_OFFSET_Y"
    fi
  }

  # Apply layout with either explicit modes (preferred) or --auto fallbacks
  apply_layout() {
    local use_auto_hdmi="$1" use_auto_edp="$2" scenario="$3"
    local edp_off_y
    edp_off_y=$(compute_edp_offset_y)
    log "apply_layout scenario=$scenario use_auto_hdmi=$use_auto_hdmi use_auto_edp=$use_auto_edp edp_off_y=$edp_off_y"

    case "$scenario" in
      dual)
        # HDMI primary right-of eDP with explicit pos to maintain greeter location
        if [ -n "$HDMI_OUTPUT" ]; then
          if [ "$use_auto_hdmi" = "1" ]; then
            run xrandr --output "$HDMI_OUTPUT" --primary --auto --pos 1920x0 --rotate normal || true
          else
            run xrandr --output "$HDMI_OUTPUT" --primary --mode "$HDMI_TARGET_MODE" --pos 1920x0 --rotate normal || true
          fi
        fi
        if [ -n "$EDP_OUTPUT" ]; then
          if [ "$use_auto_edp" = "1" ]; then
            run xrandr --output "$EDP_OUTPUT" --auto --pos 0x"$edp_off_y" --rotate normal || true
          else
            run xrandr --output "$EDP_OUTPUT" --mode "$EDP_TARGET_MODE" --pos 0x"$edp_off_y" --rotate normal || true
          fi
        fi
        ;;
      hdmi_only)
        if [ -n "$HDMI_OUTPUT" ]; then
          if [ "$use_auto_hdmi" = "1" ] || ! mode_available "$HDMI_OUTPUT" "$HDMI_TARGET_MODE"; then
            run xrandr --output "$HDMI_OUTPUT" --primary --auto --pos 0x0 --rotate normal || true
          else
            run xrandr --output "$HDMI_OUTPUT" --primary --mode "$HDMI_TARGET_MODE" --pos 0x0 --rotate normal || true
          fi
        fi
        if [ -n "$EDP_OUTPUT" ]; then
          run xrandr --output "$EDP_OUTPUT" --off || true
        fi
        ;;
      edp_only)
        if [ -n "$EDP_OUTPUT" ]; then
          if [ "$use_auto_edp" = "1" ] || ! mode_available "$EDP_OUTPUT" "$EDP_TARGET_MODE"; then
            run xrandr --output "$EDP_OUTPUT" --primary --auto --pos 0x0 --rotate normal || true
          else
            run xrandr --output "$EDP_OUTPUT" --primary --mode "$EDP_TARGET_MODE" --pos 0x0 --rotate normal || true
          fi
        fi
        if [ -n "$HDMI_OUTPUT" ]; then
          run xrandr --output "$HDMI_OUTPUT" --off || true
        fi
        ;;
    esac
  }

  # Verify the layout matches expectations; return 0 if satisfied
  verify_layout() {
    local scenario="$1" ok=0
    case "$scenario" in
      dual)
        ok=1
        if [ -n "$HDMI_OUTPUT" ]; then
          if ! is_primary "$HDMI_OUTPUT"; then ok=0; fi
          if ! active_mode_is "$HDMI_OUTPUT" "$HDMI_TARGET_MODE"; then
            xrandr --query | sed -n "/^$HDMI_OUTPUT[[:space:]]/,/^[^[:space:]]/p" | grep -q '\*' || ok=0
          fi
        else ok=0; fi
        if [ -n "$EDP_OUTPUT" ]; then
          if ! active_mode_is "$EDP_OUTPUT" "$EDP_TARGET_MODE"; then
            xrandr --query | sed -n "/^$EDP_OUTPUT[[:space:]]/,/^[^[:space:]]/p" | grep -q '\*' || ok=0
          fi
        else ok=0; fi
        [ $ok -eq 1 ]
        ;;
      hdmi_only)
        ok=1
        if [ -n "$HDMI_OUTPUT" ]; then
          if ! is_primary "$HDMI_OUTPUT"; then ok=0; fi
          if ! active_mode_is "$HDMI_OUTPUT" "$HDMI_TARGET_MODE"; then
            xrandr --query | sed -n "/^$HDMI_OUTPUT[[:space:]]/,/^[^[:space:]]/p" | grep -q '\*' || ok=0
          fi
        else ok=0; fi
        [ $ok -eq 1 ]
        ;;
      edp_only)
        ok=1
        if [ -n "$EDP_OUTPUT" ]; then
          if ! is_primary "$EDP_OUTPUT"; then ok=0; fi
          if ! active_mode_is "$EDP_OUTPUT" "$EDP_TARGET_MODE"; then
            xrandr --query | sed -n "/^$EDP_OUTPUT[[:space:]]/,/^[^[:space:]]/p" | grep -q '\*' || ok=0
          fi
        else ok=0; fi
        [ $ok -eq 1 ]
        ;;
    esac
  }

  # --------------- Main ------------------
  # Allow a brief settle window and ensure xrandr is ready
  for i in $(seq 0 $RETRIES); do
    if xrandr_ok; then break; fi
    log "xrandr not ready, retry $i/$RETRIES"
    sleep "$SLEEP_BETWEEN"
  done
  if ! xrandr_ok; then
    log "xrandr still not ready; letting LightDM default"
    exit 0
  fi

  detect_outputs

  # Prefer hdmi_only when lid closed and HDMI present
  LID_STATE=$(lid_state)
  scenario="edp_only"
  if [ -n "$HDMI_OUTPUT" ] && [ -n "$EDP_OUTPUT" ]; then
    if [ "$LID_STATE" = "closed" ]; then
      scenario="hdmi_only"
    else
      scenario="dual"
    fi
  elif [ -n "$HDMI_OUTPUT" ]; then
    scenario="hdmi_only"
  else
    scenario="edp_only"
  fi
  log "scenario=$scenario lid_state=$LID_STATE"

  # Attempt 1: explicit target modes when available
  use_auto_hdmi=0; use_auto_edp=0
  if [ "$scenario" != "edp_only" ] && [ -n "$HDMI_OUTPUT" ] && ! mode_available "$HDMI_OUTPUT" "$HDMI_TARGET_MODE"; then
    log "HDMI target mode $HDMI_TARGET_MODE not available; will use --auto for HDMI"
    use_auto_hdmi=1
  fi
  if [ "$scenario" != "hdmi_only" ] && [ -n "$EDP_OUTPUT" ] && ! mode_available "$EDP_OUTPUT" "$EDP_TARGET_MODE"; then
    log "EDP target mode $EDP_TARGET_MODE not available; will use --auto for EDP"
    use_auto_edp=1
  fi

  apply_layout "$use_auto_hdmi" "$use_auto_edp" "$scenario"
  sleep 0.3
  if verify_layout "$scenario"; then
    log "layout verified on attempt 1"
    log "---- script end (success) ----"
    exit 0
  fi

  # If dual failed but HDMI is active and EDP inactive, prefer hdmi_only fallback
  if [ "$scenario" = "dual" ] && output_has_active_mode "$HDMI_OUTPUT" && ! output_has_active_mode "$EDP_OUTPUT"; then
    log "dual verification failed with EDP inactive; switching to hdmi_only"
    apply_layout 1 1 hdmi_only
    sleep 0.2
    if verify_layout hdmi_only; then
      log "hdmi_only verified after dual failure"
      log "---- script end (success) ----"
      exit 0
    fi
  fi

  # Attempt 2: force --auto on whichever output failed
  log "verification failed; retrying with --auto"
  use_auto_hdmi=1; use_auto_edp=1
  apply_layout "$use_auto_hdmi" "$use_auto_edp" "$scenario"
  sleep 0.3
  if verify_layout "$scenario"; then
    log "layout verified on attempt 2 (auto)"
    log "---- script end (success) ----"
    exit 0
  fi

  # Attempt 3: minimal safe fallback
  log "verification still failing; applying minimal --auto"
  run xrandr --auto || true
  log "---- script end (fallback, letting LightDM default) ----"
  exit 0
} # logging subshell
