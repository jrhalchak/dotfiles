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
# Also convert newlines to literal \n for sed
escape_sed() {
  echo "$1" | sed 's/[&/\()]/\\&/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

# Escape workspace names
WS1_ESC=$(escape_sed "$WS1")
WS2_ESC=$(escape_sed "$WS2")
WS3_ESC=$(escape_sed "$WS3")
WS4_ESC=$(escape_sed "$WS4")
WS5_ESC=$(escape_sed "$WS5")

# Build sed substitution based on monitor configuration
if [[ "$MONITOR_CONFIG" == "dual" ]]; then
  # Dual monitor: WS 1-3 on HDMI, WS 4-5 on EDP
  OUTPUT_1="$HDMI_OUTPUT"
  OUTPUT_2="$HDMI_OUTPUT"
  OUTPUT_3="$HDMI_OUTPUT"
  OUTPUT_4="$EDP_OUTPUT"
  OUTPUT_5="$EDP_OUTPUT"

  # Gaps for WS 1-3 (HDMI)
  GAP_INNER_WS1="$GAP_INNER_DUAL_HDMI"
  GAP_OUTER_WS1="$GAP_OUTER_DUAL_HDMI"
  GAP_TOP_WS1="$GAP_TOP_DUAL_HDMI"
  GAP_RIGHT_WS1="$GAP_RIGHT_DUAL_HDMI"
  GAP_BOTTOM_WS1="$GAP_BOTTOM_DUAL_HDMI"
  GAP_LEFT_WS1="$GAP_LEFT_DUAL_HDMI"

  GAP_INNER_WS2="$GAP_INNER_DUAL_HDMI"
  GAP_OUTER_WS2="$GAP_OUTER_DUAL_HDMI"
  GAP_TOP_WS2="$GAP_TOP_DUAL_HDMI"
  GAP_RIGHT_WS2="$GAP_RIGHT_DUAL_HDMI"
  GAP_BOTTOM_WS2="$GAP_BOTTOM_DUAL_HDMI"
  GAP_LEFT_WS2="$GAP_LEFT_DUAL_HDMI"

  GAP_INNER_WS3="$GAP_INNER_DUAL_HDMI"
  GAP_OUTER_WS3="$GAP_OUTER_DUAL_HDMI"
  GAP_TOP_WS3="$GAP_TOP_DUAL_HDMI"
  GAP_RIGHT_WS3="$GAP_RIGHT_DUAL_HDMI"
  GAP_BOTTOM_WS3="$GAP_BOTTOM_DUAL_HDMI"
  GAP_LEFT_WS3="$GAP_LEFT_DUAL_HDMI"

  # Gaps for WS 4-5 (EDP)
  GAP_INNER_WS4="$GAP_INNER_DUAL_EDP"
  GAP_OUTER_WS4="$GAP_OUTER_DUAL_EDP"
  GAP_TOP_WS4="$GAP_TOP_DUAL_EDP"
  GAP_RIGHT_WS4="$GAP_RIGHT_DUAL_EDP"
  GAP_BOTTOM_WS4="$GAP_BOTTOM_DUAL_EDP"
  GAP_LEFT_WS4="$GAP_LEFT_DUAL_EDP"

  GAP_INNER_WS5="$GAP_INNER_DUAL_EDP"
  GAP_OUTER_WS5="$GAP_OUTER_DUAL_EDP"
  GAP_TOP_WS5="$GAP_TOP_DUAL_EDP"
  GAP_RIGHT_WS5="$GAP_RIGHT_DUAL_EDP"
  GAP_BOTTOM_WS5="$GAP_BOTTOM_DUAL_EDP"
  GAP_LEFT_WS5="$GAP_LEFT_DUAL_EDP"

  # Add output navigation bindings for dual mode
  DUAL_OUTPUT_NAVIGATION="# Move focused container to the next output
bindsym \$mod+Shift+period move workspace to output right
bindsym \$mod+Shift+comma move workspace to output left

# Move focus to the next output
bindsym \$mod+period focus output right
bindsym \$mod+comma focus output left"

elif [[ "$MONITOR_CONFIG" == "hdmi_only" ]]; then
  # HDMI only: All workspaces on HDMI
  OUTPUT_1="$HDMI_OUTPUT"
  OUTPUT_2="$HDMI_OUTPUT"
  OUTPUT_3="$HDMI_OUTPUT"
  OUTPUT_4="$HDMI_OUTPUT"
  OUTPUT_5="$HDMI_OUTPUT"

  # Use HDMI-only gaps for all workspaces
  for i in 1 2 3 4 5; do
    eval "GAP_INNER_WS${i}=$GAP_INNER_HDMI_ONLY"
    eval "GAP_OUTER_WS${i}=$GAP_OUTER_HDMI_ONLY"
    eval "GAP_TOP_WS${i}=$GAP_TOP_HDMI_ONLY"
    eval "GAP_RIGHT_WS${i}=$GAP_RIGHT_HDMI_ONLY"
    eval "GAP_BOTTOM_WS${i}=$GAP_BOTTOM_HDMI_ONLY"
    eval "GAP_LEFT_WS${i}=$GAP_LEFT_HDMI_ONLY"
  done

  DUAL_OUTPUT_NAVIGATION=""

else
  # EDP only: All workspaces on EDP
  OUTPUT_1="$EDP_OUTPUT"
  OUTPUT_2="$EDP_OUTPUT"
  OUTPUT_3="$EDP_OUTPUT"
  OUTPUT_4="$EDP_OUTPUT"
  OUTPUT_5="$EDP_OUTPUT"

  # Use EDP-only gaps for all workspaces
  for i in 1 2 3 4 5; do
    eval "GAP_INNER_WS${i}=$GAP_INNER_EDP_ONLY"
    eval "GAP_OUTER_WS${i}=$GAP_OUTER_EDP_ONLY"
    eval "GAP_TOP_WS${i}=$GAP_TOP_EDP_ONLY"
    eval "GAP_RIGHT_WS${i}=$GAP_RIGHT_EDP_ONLY"
    eval "GAP_BOTTOM_WS${i}=$GAP_BOTTOM_EDP_ONLY"
    eval "GAP_LEFT_WS${i}=$GAP_LEFT_EDP_ONLY"
  done

  DUAL_OUTPUT_NAVIGATION=""
fi

# Escape DUAL_OUTPUT_NAVIGATION for sed
DUAL_OUTPUT_NAVIGATION_ESC=$(escape_sed "$DUAL_OUTPUT_NAVIGATION")

# Generate workspace bindings from unified template using piped sed commands
cat ~/.config/i3/workspaces.unified | \
  sed "s/{{WS1}}/$WS1_ESC/g; s/{{WS2}}/$WS2_ESC/g; s/{{WS3}}/$WS3_ESC/g; s/{{WS4}}/$WS4_ESC/g; s/{{WS5}}/$WS5_ESC/g" | \
  sed "s/{{OUTPUT_1}}/$OUTPUT_1/g; s/{{OUTPUT_2}}/$OUTPUT_2/g; s/{{OUTPUT_3}}/$OUTPUT_3/g; s/{{OUTPUT_4}}/$OUTPUT_4/g; s/{{OUTPUT_5}}/$OUTPUT_5/g" | \
  sed "s/{{GAP_INNER_WS1}}/$GAP_INNER_WS1/g; s/{{GAP_OUTER_WS1}}/$GAP_OUTER_WS1/g; s/{{GAP_TOP_WS1}}/$GAP_TOP_WS1/g; s/{{GAP_RIGHT_WS1}}/$GAP_RIGHT_WS1/g; s/{{GAP_BOTTOM_WS1}}/$GAP_BOTTOM_WS1/g; s/{{GAP_LEFT_WS1}}/$GAP_LEFT_WS1/g" | \
  sed "s/{{GAP_INNER_WS2}}/$GAP_INNER_WS2/g; s/{{GAP_OUTER_WS2}}/$GAP_OUTER_WS2/g; s/{{GAP_TOP_WS2}}/$GAP_TOP_WS2/g; s/{{GAP_RIGHT_WS2}}/$GAP_RIGHT_WS2/g; s/{{GAP_BOTTOM_WS2}}/$GAP_BOTTOM_WS2/g; s/{{GAP_LEFT_WS2}}/$GAP_LEFT_WS2/g" | \
  sed "s/{{GAP_INNER_WS3}}/$GAP_INNER_WS3/g; s/{{GAP_OUTER_WS3}}/$GAP_OUTER_WS3/g; s/{{GAP_TOP_WS3}}/$GAP_TOP_WS3/g; s/{{GAP_RIGHT_WS3}}/$GAP_RIGHT_WS3/g; s/{{GAP_BOTTOM_WS3}}/$GAP_BOTTOM_WS3/g; s/{{GAP_LEFT_WS3}}/$GAP_LEFT_WS3/g" | \
  sed "s/{{GAP_INNER_WS4}}/$GAP_INNER_WS4/g; s/{{GAP_OUTER_WS4}}/$GAP_OUTER_WS4/g; s/{{GAP_TOP_WS4}}/$GAP_TOP_WS4/g; s/{{GAP_RIGHT_WS4}}/$GAP_RIGHT_WS4/g; s/{{GAP_BOTTOM_WS4}}/$GAP_BOTTOM_WS4/g; s/{{GAP_LEFT_WS4}}/$GAP_LEFT_WS4/g" | \
  sed "s/{{GAP_INNER_WS5}}/$GAP_INNER_WS5/g; s/{{GAP_OUTER_WS5}}/$GAP_OUTER_WS5/g; s/{{GAP_TOP_WS5}}/$GAP_TOP_WS5/g; s/{{GAP_RIGHT_WS5}}/$GAP_RIGHT_WS5/g; s/{{GAP_BOTTOM_WS5}}/$GAP_BOTTOM_WS5/g; s/{{GAP_LEFT_WS5}}/$GAP_LEFT_WS5/g" | \
  sed "s/{{DUAL_OUTPUT_NAVIGATION}}/$DUAL_OUTPUT_NAVIGATION_ESC/g" \
  > ~/.config/i3/generated.bindings

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
max_wait=20
count=0
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
    # MONITOR=$HDMI_OUTPUT polybar left_4k &
    # MONITOR=$HDMI_OUTPUT polybar right_4k &
    MONITOR=$HDMI_OUTPUT polybar minimal_4k &
    ;;
  dual)
    # MONITOR=$HDMI_OUTPUT polybar left_4k &
    # MONITOR=$HDMI_OUTPUT polybar right_4k &
    MONITOR=$EDP_OUTPUT polybar minimal_1080p &
    MONITOR=$HDMI_OUTPUT polybar minimal_4k &
    ;;
  edp_only)
    MONITOR=$EDP_OUTPUT polybar minimal_1080p &
    # MONITOR=$EDP_OUTPUT polybar left_1080p &
    # MONITOR=$EDP_OUTPUT polybar right_1080p &
    ;;
esac

wait_for_polybar

#
# 7. Relocate workspaces to correct outputs
#
echo "i3_startup: Relocating workspaces to correct outputs..."

if [[ "$MONITOR_CONFIG" == "dual" ]]; then
  # In dual mode, ensure WS 1-3 are on HDMI, WS 4-5 are on EDP
  for w in "$WS1" "$WS2" "$WS3"; do
    cur_out=$(i3-msg -t get_workspaces | jq -r '.[] | select(.name=="'"$w"'") | .output')
    if [ -n "$cur_out" ] && [ "$cur_out" != "$HDMI_OUTPUT" ]; then
      i3-msg "workspace \"$w\"; move workspace to output $HDMI_OUTPUT" >/dev/null
    fi
  done

  for w in "$WS4" "$WS5"; do
    cur_out=$(i3-msg -t get_workspaces | jq -r '.[] | select(.name=="'"$w"'") | .output')
    if [ -n "$cur_out" ] && [ "$cur_out" != "$EDP_OUTPUT" ]; then
      i3-msg "workspace \"$w\"; move workspace to output $EDP_OUTPUT" >/dev/null
    fi
  done
fi



#
# 8. Start xborders (LAST - after compositor, polybar, workspaces, and gaps are ready)
#
echo "i3_startup: Starting xborders..."
if pgrep -f xborders > /dev/null; then
    pkill -f xborders
    sleep 0.3
fi
# Tokyo Night blue color: #7aa2f7 with slight transparency
# Use wrapper script that waits for compositor to be fully ready
nohup ~/dotfiles/linux/scripts/start-xborders.sh --border-width 1 --border-radius 8 --border-rgba '#7aa2f7dd' >/dev/null 2>&1 &

#
# 9. Reload i3 config to apply gap configuration
#
echo "i3_startup: Reloading i3 config to apply gaps..."
i3-msg reload

echo "i3_startup: Startup sequence complete (config: $MONITOR_CONFIG)"
