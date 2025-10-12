#!/bin/bash
#
# Central configuration for i3 multi-monitor setup
# Single source of truth for workspace names, gaps, and display settings
#

# Workspace names for dual monitor setup
export WS1_HDMI="1:main-HDMI"
export WS2_HDMI="2:code-HDMI"
export WS3_HDMI="3:web-HDMI"
export WS4_HDMI="4:misc-HDMI"
export WS5_HDMI="5:shed-HDMI"

export WS1_EDP="6(1):main-eDP"
export WS2_EDP="7(2):misc-eDP"
export WS3_EDP="8(3):shed-eDP"

# Workspace names for single monitor setup
export WS1_SINGLE="1:main"
export WS2_SINGLE="2:code"
export WS3_SINGLE="3:web"
export WS4_SINGLE="4:misc"
export WS5_SINGLE="5:shed"

# Gap configuration
export GAP_INNER=16
export GAP_OUTER=8
export GAP_TOP_4K=56    # For 4K HDMI display (polybar height + margin)
export GAP_TOP_1080P=48 # For 1080p laptop display (polybar height + margin)

# Display settings
export HDMI_MODE="3840x2160"
export EDP_MODE="1920x1080"
export EDP_OFFSET_X=0
export EDP_OFFSET_Y=600

# Polybar configuration
export POLYBAR_HEIGHT_4K=48
export POLYBAR_HEIGHT_1080P=40

# Wallpaper path
export WALLPAPER_PATH="$HOME/Pictures/Wallpapers/tokyo-night-aesthetic.jpg"
