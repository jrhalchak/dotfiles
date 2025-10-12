#!/usr/bin/env bash
#
# Unified i3 startup script - orchestrates all monitor/workspace setup
# Replaces setup_monitors.sh, set_gaps.sh, and individual service launches
#

# Source central configuration and xrandr functions
source ~/.config/i3/monitor_config.sh
source ~/dotfiles/scripts/sys/monitor_xrandr.sh

# Wait just in case displays aren't setup
sleep 2

#
# 1. Configure displays with xrandr
#
echo "i3_startup: Configuring displays..."
setup_displays

# Wait for xrandr changes to fully take effect
sleep 0.5

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
       s/{{WS1_EDP}}/$WS1_EDP_ESC/g; s/{{WS2_EDP}}/$WS2_EDP_ESC/g; s/{{WS3_EDP}}/$WS3_EDP_ESC/g" \
      ~/.config/i3/workspaces.dual > ~/.config/i3/generated.bindings
else
  # Single monitor - substitute variables in template with escaped values
  WS1_SINGLE_ESC=$(escape_sed "$WS1_SINGLE")
  WS2_SINGLE_ESC=$(escape_sed "$WS2_SINGLE")
  WS3_SINGLE_ESC=$(escape_sed "$WS3_SINGLE")
  WS4_SINGLE_ESC=$(escape_sed "$WS4_SINGLE")
  WS5_SINGLE_ESC=$(escape_sed "$WS5_SINGLE")
  
  sed "s/{{WS1_SINGLE}}/$WS1_SINGLE_ESC/g; s/{{WS2_SINGLE}}/$WS2_SINGLE_ESC/g; s/{{WS3_SINGLE}}/$WS3_SINGLE_ESC/g; s/{{WS4_SINGLE}}/$WS4_SINGLE_ESC/g; s/{{WS5_SINGLE}}/$WS5_SINGLE_ESC/g" \
      ~/.config/i3/workspaces.single > ~/.config/i3/generated.bindings
fi

#
# 4. Set wallpaper before starting picom
#
echo "i3_startup: Setting wallpaper..."
feh --bg-fill $WALLPAPER_PATH

#
# 5. Start picom after wallpaper is set
#
echo "i3_startup: Starting picom..."
if pgrep -x picom > /dev/null; then
    killall picom
    sleep 0.5
fi
picom --backend glx --config ~/.config/picom/picom.conf --daemon

# Wait for picom to start
sleep 0.3

#
# 5. Start polybar
#
echo "i3_startup: Starting polybar..."

# Aggressively kill all polybars
killall -q polybar 2>/dev/null
killall -9 polybar 2>/dev/null

# Wait for polybars to terminate
for i in {1..5}; do
  if ! pgrep -u $UID -x polybar >/dev/null; then
    break
  fi
  sleep 0.5
done

# Force kill any remaining
if pgrep -u $UID -x polybar >/dev/null; then
  pkill -9 -u $UID polybar
  sleep 0.5
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
    MONITOR=$EDP_OUTPUT polybar left_1080p &
    MONITOR=$EDP_OUTPUT polybar right_1080p &
    ;;
esac

# Wait for polybars to start
sleep 0.5

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
  
  # Initialize primary workspaces
  i3-msg "workspace \"$WS1_HDMI\""
  i3-msg "workspace \"$WS1_EDP\""
else
  i3-msg "workspace \"$WS1_SINGLE\""
fi

#
# 10. Set gaps after polybar is running
#
echo "i3_startup: Setting gaps..."
if [[ "$MONITOR_CONFIG" == "dual" ]]; then
  # Dual monitor gaps - switch to each workspace and set gaps
  i3-msg "gaps inner all set $GAP_INNER; gaps outer all set $GAP_OUTER"
  i3-msg "workspace \"$WS1_HDMI\"; gaps top current set $GAP_TOP_4K"
  i3-msg "workspace \"$WS2_HDMI\"; gaps top current set $GAP_TOP_4K"
  i3-msg "workspace \"$WS3_HDMI\"; gaps top current set $GAP_TOP_4K"
  i3-msg "workspace \"$WS4_HDMI\"; gaps top current set $GAP_TOP_4K"
  i3-msg "workspace \"$WS5_HDMI\"; gaps top current set $GAP_TOP_4K"
  i3-msg "workspace \"$WS1_EDP\"; gaps top current set $GAP_TOP_1080P"
  i3-msg "workspace \"$WS2_EDP\"; gaps top current set $GAP_TOP_1080P"
  i3-msg "workspace \"$WS3_EDP\"; gaps top current set $GAP_TOP_1080P"
else
  # Single monitor gaps
  if [[ "$MONITOR_CONFIG" == "hdmi_only" ]]; then
    GAP_TOP=$GAP_TOP_4K
  else
    GAP_TOP=$GAP_TOP_1080P
  fi
  i3-msg "gaps inner all set $GAP_INNER; gaps outer all set 0"
  i3-msg "workspace \"$WS1_SINGLE\"; gaps top current set $GAP_TOP"
  i3-msg "workspace \"$WS2_SINGLE\"; gaps top current set $GAP_TOP"
  i3-msg "workspace \"$WS3_SINGLE\"; gaps top current set $GAP_TOP"
  i3-msg "workspace \"$WS4_SINGLE\"; gaps top current set $GAP_TOP"
  i3-msg "workspace \"$WS5_SINGLE\"; gaps top current set $GAP_TOP"
fi

echo "i3_startup: Startup sequence complete (config: $MONITOR_CONFIG)"