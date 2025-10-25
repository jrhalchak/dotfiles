#!/bin/bash
#
# Central configuration for i3 multi-monitor setup
# Single source of truth for workspace names, gaps, and display settings
#

# Unified workspace names (used across all monitor configurations)
export WS1="1:main"
export WS2="2:code"
export WS3="3:web"
export WS4="4:misc"
export WS5="5:shed"

# Gap configuration - dual monitor HDMI workspaces
export GAP_INNER_DUAL_HDMI=8
export GAP_OUTER_DUAL_HDMI=4
export GAP_TOP_DUAL_HDMI=32
export GAP_RIGHT_DUAL_HDMI=4
export GAP_BOTTOM_DUAL_HDMI=4
export GAP_LEFT_DUAL_HDMI=4

# Gap configuration - dual monitor EDP workspaces
export GAP_INNER_DUAL_EDP=8
export GAP_OUTER_DUAL_EDP=4
export GAP_TOP_DUAL_EDP=32
export GAP_RIGHT_DUAL_EDP=4
export GAP_BOTTOM_DUAL_EDP=4
export GAP_LEFT_DUAL_EDP=4

# Gap configuration - hdmi only
export GAP_INNER_HDMI_ONLY=8
export GAP_OUTER_HDMI_ONLY=4
export GAP_TOP_HDMI_ONLY=32
export GAP_RIGHT_HDMI_ONLY=4
export GAP_BOTTOM_HDMI_ONLY=4
export GAP_LEFT_HDMI_ONLY=4

# Gap configuration - laptop only
export GAP_INNER_EDP_ONLY=8
export GAP_OUTER_EDP_ONLY=4
export GAP_TOP_EDP_ONLY=32
export GAP_RIGHT_EDP_ONLY=4
export GAP_BOTTOM_EDP_ONLY=4
export GAP_LEFT_EDP_ONLY=4

# Display settings
export HDMI_MODE="3840x2160"
export EDP_MODE="1920x1080"
export EDP_OFFSET_X=0
export EDP_OFFSET_Y=600

# Wallpaper path
# export WALLPAPER_PATH="$HOME/Pictures/Wallpapers/buddha-01.jpg"
export WALLPAPER_PATH="$HOME/Pictures/Wallpapers/forest-fog-morning-dark-path-autumn-forest-mist-landscape-3840x2562-8010.jpg"
