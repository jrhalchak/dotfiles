#!/usr/bin/env bash
#
# Minimal monitor setup for LightDM login screen
# Only handles xrandr configuration, no i3-specific setup
#

# Simple xrandr setup - don't use shared functions since lightdm runs as root
sleep 2

# Get display names
HDMI_OUTPUT=$(xrandr | grep -E '^HDMI[0-9-]+' | cut -d' ' -f1 | head -1)
EDP_OUTPUT=$(xrandr | grep -E '^eDP[0-9-]+' | cut -d' ' -f1 | head -1)
HDMI_CONNECTED=$(xrandr | grep "$HDMI_OUTPUT connected" | grep -v "disconnected")

echo "lightdm_monitors: HDMI_OUTPUT=$HDMI_OUTPUT, EDP_OUTPUT=$EDP_OUTPUT"

# Simple display configuration
if [[ -n "$HDMI_CONNECTED" ]]; then
    echo "lightdm_monitors: Setting up HDMI + EDP"
    xrandr --output $HDMI_OUTPUT --primary --mode 3840x2160 --pos 1920x0 --rotate normal \
           --output $EDP_OUTPUT --mode 1920x1080 --pos 0x540 --rotate normal
else
    echo "lightdm_monitors: Setting up EDP only"
    xrandr --output $EDP_OUTPUT --primary --mode 1920x1080 --pos 0x0 --rotate normal \
           --output $HDMI_OUTPUT --off 2>/dev/null || true
fi

echo "lightdm_monitors: Complete"