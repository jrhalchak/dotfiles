#!/usr/bin/env bash
#
# Unified i3 startup script - orchestrates all monitor/workspace setup
# Replaces setup_monitors.sh, set_gaps.sh, and individual service launches
#

# Wait functions that check for actual readiness instead of arbitrary sleeps

wait_for_picom() {
    local max_attempts=50
    local attempt=0
    echo "Waiting for picom compositor..."

    while [ $attempt -lt $max_attempts ]; do
        # Check if picom process exists
        if pgrep -x picom > /dev/null; then
            # Check if compositor is detected by X
            if xprop -root _NET_WM_CM_S0 > /dev/null 2>&1; then
                echo "Picom compositor ready"
                return 0
            fi
        fi
        attempt=$((attempt + 1))
        sleep 0.1
    done

    echo "Warning: Picom not ready after ${max_attempts} attempts"
    return 1
}

wait_for_polybar() {
    local max_attempts=30
    local attempt=0
    echo "Waiting for polybar..."

    while [ $attempt -lt $max_attempts ]; do
        if pgrep -x polybar > /dev/null; then
            # Give polybar a moment to create its windows
            sleep 0.2
            echo "Polybar ready"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 0.1
    done

    echo "Warning: Polybar not ready after ${max_attempts} attempts"
    return 1
}

# Source central configuration and xrandr functions
source ~/.config/i3/monitor_config.sh
source ~/dotfiles/linux/scripts/monitor_xrandr.sh

# Brief wait for displays to be ready
sleep 0.5

#
# 1. Configure displays with xrandr
#
echo "i3_startup: Configuring displays..."
setup_displays

# Wait for xrandr changes to fully take effect
sleep 0.3

#
# 2. Wait for expected display configuration to be active
#
wait_for_displays

#
# 3. Generate workspace configuration
#
echo "i3_startup: Generating workspace configuration..."

# Escape special sed characters in workspace names (parentheses, slashes, etc.)
escape_sed() {
  echo "$1" | sed 's/[&/\()]/\\&/g'
}

if [[ "$MONITOR_CONFIG" == "dual" ]]; then
  # Dual monitor - substitute variables in template with escaped values
  WS1_HDMI_ESC=$(escape_sed "$WS1_HDMI")
  WS2_HDMI_ESC=$(escape_sed "$WS2_HDMI")
  WS3_HDMI_ESC=$(escape_sed "$WS3_HDMI")
  WS4_HDMI_ESC=$(escape_sed "$WS4_HDMI")
  WS5_HDMI_ESC=$(escape_sed "$WS5_HDMI")
  WS1_EDP_ESC=$(escape_sed "$WS1_EDP")
  WS2_EDP_ESC=$(escape_sed "$WS2_EDP")
  WS3_EDP_ESC=$(escape_sed "$WS3_EDP")

  sed "s/{{HDMI_OUTPUT}}/$HDMI_OUTPUT/g; s/{{EDP_OUTPUT}}/$EDP_OUTPUT/g; \
       s/{{WS1_HDMI}}/$WS1_HDMI_ESC/g; s/{{WS2_HDMI}}/$WS2_HDMI_ESC/g; s/{{WS3_HDMI}}/$WS3_HDMI_ESC/g; s/{{WS4_HDMI}}/$WS4_HDMI_ESC/g; s/{{WS5_HDMI}}/$WS5_HDMI_ESC/g; \
       s/{{WS1_EDP}}/$WS1_EDP_ESC/g; s/{{WS2_EDP}}/$WS2_EDP_ESC/g; s/{{WS3_EDP}}/$WS3_EDP_ESC/g; \
       s/{{GAP_INNER_DUAL_HDMI}}/$GAP_INNER_DUAL_HDMI/g; s/{{GAP_OUTER_DUAL_HDMI}}/$GAP_OUTER_DUAL_HDMI/g; \
       s/{{GAP_TOP_DUAL_HDMI}}/$GAP_TOP_DUAL_HDMI/g; s/{{GAP_RIGHT_DUAL_HDMI}}/$GAP_RIGHT_DUAL_HDMI/g; \
       s/{{GAP_BOTTOM_DUAL_HDMI}}/$GAP_BOTTOM_DUAL_HDMI/g; s/{{GAP_LEFT_DUAL_HDMI}}/$GAP_LEFT_DUAL_HDMI/g; \
       s/{{GAP_INNER_DUAL_EDP}}/$GAP_INNER_DUAL_EDP/g; s/{{GAP_OUTER_DUAL_EDP}}/$GAP_OUTER_DUAL_EDP/g; \
       s/{{GAP_TOP_DUAL_EDP}}/$GAP_TOP_DUAL_EDP/g; s/{{GAP_RIGHT_DUAL_EDP}}/$GAP_RIGHT_DUAL_EDP/g; \
       s/{{GAP_BOTTOM_DUAL_EDP}}/$GAP_BOTTOM_DUAL_EDP/g; s/{{GAP_LEFT_DUAL_EDP}}/$GAP_LEFT_DUAL_EDP/g" \
      ~/.config/i3/workspaces.dual > ~/.config/i3/generated.bindings
else
  # Single monitor - substitute variables in template with escaped values
  WS1_SINGLE_ESC=$(escape_sed "$WS1_SINGLE")
  WS2_SINGLE_ESC=$(escape_sed "$WS2_SINGLE")
  WS3_SINGLE_ESC=$(escape_sed "$WS3_SINGLE")
  WS4_SINGLE_ESC=$(escape_sed "$WS4_SINGLE")
  WS5_SINGLE_ESC=$(escape_sed "$WS5_SINGLE")

  if [[ "$MONITOR_CONFIG" == "hdmi_only" ]]; then
    sed "s/{{WS1_SINGLE}}/$WS1_SINGLE_ESC/g; s/{{WS2_SINGLE}}/$WS2_SINGLE_ESC/g; s/{{WS3_SINGLE}}/$WS3_SINGLE_ESC/g; s/{{WS4_SINGLE}}/$WS4_SINGLE_ESC/g; s/{{WS5_SINGLE}}/$WS5_SINGLE_ESC/g; \
         s/{{GAP_INNER_SINGLE}}/$GAP_INNER_HDMI_ONLY/g; s/{{GAP_OUTER_SINGLE}}/$GAP_OUTER_HDMI_ONLY/g; \
         s/{{GAP_TOP_SINGLE}}/$GAP_TOP_HDMI_ONLY/g; s/{{GAP_RIGHT_SINGLE}}/$GAP_RIGHT_HDMI_ONLY/g; \
         s/{{GAP_BOTTOM_SINGLE}}/$GAP_BOTTOM_HDMI_ONLY/g; s/{{GAP_LEFT_SINGLE}}/$GAP_LEFT_HDMI_ONLY/g" \
        ~/.config/i3/workspaces.single > ~/.config/i3/generated.bindings
  else
    sed "s/{{WS1_SINGLE}}/$WS1_SINGLE_ESC/g; s/{{WS2_SINGLE}}/$WS2_SINGLE_ESC/g; s/{{WS3_SINGLE}}/$WS3_SINGLE_ESC/g; s/{{WS4_SINGLE}}/$WS4_SINGLE_ESC/g; s/{{WS5_SINGLE}}/$WS5_SINGLE_ESC/g; \
         s/{{GAP_INNER_SINGLE}}/$GAP_INNER_EDP_ONLY/g; s/{{GAP_OUTER_SINGLE}}/$GAP_OUTER_EDP_ONLY/g; \
         s/{{GAP_TOP_SINGLE}}/$GAP_TOP_EDP_ONLY/g; s/{{GAP_RIGHT_SINGLE}}/$GAP_RIGHT_EDP_ONLY/g; \
         s/{{GAP_BOTTOM_SINGLE}}/$GAP_BOTTOM_EDP_ONLY/g; s/{{GAP_LEFT_SINGLE}}/$GAP_LEFT_EDP_ONLY/g" \
        ~/.config/i3/workspaces.single > ~/.config/i3/generated.bindings
  fi
fi

#
# 4. Set wallpaper before starting picom
#
echo "i3_startup: Setting wallpaper..."
feh --bg-fill $WALLPAPER_PATH

#
# 5. Start/restart picom after wallpaper is set
#
echo "i3_startup: Starting picom..."
if pgrep -x picom > /dev/null; then
    killall picom
    # Wait for picom to actually terminate
    while pgrep -x picom > /dev/null; do
        sleep 0.1
    done
fi
picom --backend glx --config ~/.config/picom/picom.conf --daemon
wait_for_picom

#
# 6. Start polybar
#
echo "i3_startup: Starting polybar..."

# Kill existing polybars
killall -q polybar 2>/dev/null

# Wait for polybars to actually terminate
local max_wait=20
local count=0
while pgrep -u $UID -x polybar >/dev/null && [ $count -lt $max_wait ]; do
    sleep 0.1
    count=$((count + 1))
done

# Force kill if still running
if pgrep -u $UID -x polybar >/dev/null; then
    pkill -9 -u $UID polybar
    while pgrep -u $UID -x polybar >/dev/null; do
        sleep 0.1
    done
fi

# Start appropriate polybars based on monitor configuration
case $MONITOR_CONFIG in
  hdmi_only)
    MONITOR=$HDMI_OUTPUT polybar left_4k &
    MONITOR=$HDMI_OUTPUT polybar right_4k &
    ;;
  dual)
    MONITOR=$HDMI_OUTPUT polybar left_4k &
    MONITOR=$HDMI_OUTPUT polybar right_4k &
    MONITOR=$EDP_OUTPUT polybar minimal_1080p &
    ;;
  edp_only)
    MONITOR=$EDP_OUTPUT polybar minimal_1080p &
    #MONITOR=$EDP_OUTPUT polybar left_1080p &
    #MONITOR=$EDP_OUTPUT polybar right_1080p &
    ;;
esac

wait_for_polybar

#
# 8. Set wallpaper again to ensure it's properly composited
#
echo "i3_startup: Final wallpaper setting..."
feh --bg-fill $WALLPAPER_PATH

#
# 9. Clean up and initialize workspaces
#
echo "i3_startup: Cleaning up old workspaces and initializing new ones..."

# Get list of existing workspaces and move windows to new workspace names
if [[ "$MONITOR_CONFIG" == "dual" ]]; then
  # Rename old workspaces to new naming scheme if they exist
  i3-msg -t get_workspaces | jq -r '.[].name' | while read -r ws; do
    case "$ws" in
      "1:main") i3-msg "rename workspace \"$ws\" to \"$WS1_HDMI\"" ;;
      "2:code") i3-msg "rename workspace \"$ws\" to \"$WS2_HDMI\"" ;;
      "3:web") i3-msg "rename workspace \"$ws\" to \"$WS3_HDMI\"" ;;
      "4:misc") i3-msg "rename workspace \"$ws\" to \"$WS4_HDMI\"" ;;
      "5:shed") i3-msg "rename workspace \"$ws\" to \"$WS5_HDMI\"" ;;
    esac
  done
fi



#
# 11. Start xborders (LAST - after compositor, polybar, workspaces, and gaps are ready)
#
echo "i3_startup: Starting xborders..."
if pgrep -f xborders > /dev/null; then
    pkill -f xborders
    sleep 0.3
fi
# Tokyo Night blue color: #7aa2f7 with slight transparency
# Use wrapper script that waits for compositor to be fully ready
nohup ~/dotfiles/linux/scripts/start-xborders.sh --border-width 1 --border-radius 16 --border-rgba '#7aa2f7dd' >/dev/null 2>&1 &

#
# 12. Reload i3 config to apply gap configuration
#
echo "i3_startup: Reloading i3 config to apply gaps..."
i3-msg reload

echo "i3_startup: Startup sequence complete (config: $MONITOR_CONFIG)"
