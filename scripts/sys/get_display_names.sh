#!/bin/bash

# Output format: HDMI_OUTPUT EDP_OUTPUT
HDMI_OUTPUT=$(xrandr | grep "HDMI.*connected" | cut -d' ' -f1)
EDP_OUTPUT=$(xrandr | grep "eDP.*connected" | cut -d' ' -f1)

echo "$HDMI_OUTPUT $EDP_OUTPUT"
