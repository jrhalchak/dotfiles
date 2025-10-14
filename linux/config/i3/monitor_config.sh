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

# Gap configuration - dual monitor HDMI workspaces
export GAP_INNER_DUAL_HDMI=16
export GAP_OUTER_DUAL_HDMI=8
export GAP_TOP_DUAL_HDMI=56
export GAP_RIGHT_DUAL_HDMI=8
export GAP_BOTTOM_DUAL_HDMI=8
export GAP_LEFT_DUAL_HDMI=8

# Gap configuration - dual monitor EDP workspaces
export GAP_INNER_DUAL_EDP=16
export GAP_OUTER_DUAL_EDP=8
export GAP_TOP_DUAL_EDP=48
export GAP_RIGHT_DUAL_EDP=8
export GAP_BOTTOM_DUAL_EDP=8
export GAP_LEFT_DUAL_EDP=8

# Gap configuration - hdmi only
export GAP_INNER_HDMI_ONLY=16
export GAP_OUTER_HDMI_ONLY=8
export GAP_TOP_HDMI_ONLY=56
export GAP_RIGHT_HDMI_ONLY=8
export GAP_BOTTOM_HDMI_ONLY=8
export GAP_LEFT_HDMI_ONLY=8

# Gap configuration - laptop only
export GAP_INNER_EDP_ONLY=8
export GAP_OUTER_EDP_ONLY=4
export GAP_TOP_EDP_ONLY=40
export GAP_RIGHT_EDP_ONLY=4
export GAP_BOTTOM_EDP_ONLY=4
export GAP_LEFT_EDP_ONLY=4

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
