#!/bin/bash
# Save as ~/.config/polybar/scripts/xwindow-output.sh

OUTPUT="$1"  # Pass output name as argument (e.g., "eDP-1-1")

# Get focused workspace and its output
FOCUSED_WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true) | .output')

# Only show window title if focused workspace is on this output
if [ "$FOCUSED_WS" = "$OUTPUT" ]; then
    i3-msg -t get_tree | jq -r '.. | select(.focused? == true).name' | head -1 | cut -c 1-30
fi
