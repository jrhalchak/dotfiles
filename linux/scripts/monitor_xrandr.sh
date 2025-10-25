#!/bin/bash
#
# Shared xrandr display configuration logic
# Sources monitor_config.sh for display constants and provides setup_displays() function
#

# Source central configuration for display constants
source ~/.config/i3/monitor_config.sh

# Function to configure displays based on current setup
setup_displays() {
    # Dynamic display detection
    read HDMI_OUTPUT EDP_OUTPUT <<< $(~/dotfiles/linux/scripts/get_display_names.sh)
    LID_STATE=$(~/dotfiles/linux/scripts/get_lid_state.sh)
    HDMI_CONNECTED=$(xrandr | grep "$HDMI_OUTPUT connected" | grep -v "disconnected")

    echo "monitor_xrandr: Configuring displays - HDMI_OUTPUT=$HDMI_OUTPUT, EDP_OUTPUT=$EDP_OUTPUT, LID_STATE=$LID_STATE"

    if [[ -n "$HDMI_CONNECTED" && "$LID_STATE" == "closed" ]]; then
        # HDMI only, laptop lid closed
        echo "monitor_xrandr: Setting up HDMI-only configuration"
        xrandr --output $HDMI_OUTPUT --primary --mode $HDMI_MODE --pos 0x0 --rotate normal \
               --output $EDP_OUTPUT --off
        MONITOR_CONFIG="hdmi_only"

    elif [[ -n "$HDMI_CONNECTED" && "$LID_STATE" == "open" ]]; then
        # Both screens, HDMI primary, EDP to the left and offset down
        echo "monitor_xrandr: Setting up dual monitor configuration"
        xrandr --output $HDMI_OUTPUT --primary --mode $HDMI_MODE --pos 1920x0 --rotate normal \
               --output $EDP_OUTPUT --mode $EDP_MODE --pos ${EDP_OFFSET_X}x${EDP_OFFSET_Y} --rotate normal
        MONITOR_CONFIG="dual"

    else
        # HDMI disconnected, fallback to laptop only
        echo "monitor_xrandr: Setting up EDP-only configuration"
        xrandr --output $EDP_OUTPUT --primary --mode $EDP_MODE --pos 0x0 --rotate normal \
               --output $HDMI_OUTPUT --off
        MONITOR_CONFIG="edp_only"
    fi

    # Export variables for caller to use
    export HDMI_OUTPUT EDP_OUTPUT LID_STATE HDMI_CONNECTED MONITOR_CONFIG

    echo "monitor_xrandr: Display configuration complete (config: $MONITOR_CONFIG)"
}

# Function to wait for display configuration to be active
wait_for_displays() {
    echo "monitor_xrandr: Waiting for display configuration to be active..."
    timeout=10

    case $MONITOR_CONFIG in
        hdmi_only)
            while ! xrandr | grep -q "$HDMI_OUTPUT.*$HDMI_MODE.*\*"; do
                sleep 0.2; timeout=$((timeout - 1))
                if [ $timeout -eq 0 ]; then
                    echo "monitor_xrandr: Timeout waiting for HDMI display"
                    break
                fi
            done
            ;;
        dual)
            while ! (xrandr | grep -q "$HDMI_OUTPUT.*$HDMI_MODE.*\*" && xrandr | grep -q "$EDP_OUTPUT.*$EDP_MODE.*\*"); do
                sleep 0.2; timeout=$((timeout - 1))
                if [ $timeout -eq 0 ]; then
                    echo "monitor_xrandr: Timeout waiting for dual displays"
                    break
                fi
            done
            ;;
        edp_only)
            while ! xrandr | grep -q "$EDP_OUTPUT.*$EDP_MODE.*\*"; do
                sleep 0.2; timeout=$((timeout - 1))
                if [ $timeout -eq 0 ]; then
                    echo "monitor_xrandr: Timeout waiting for EDP display"
                    break
                fi
            done
            ;;
    esac

    echo "monitor_xrandr: Display wait complete"
}

# If executed directly, perform display setup and workspace relocation
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  setup_displays
  wait_for_displays

  # Workspace relocation (requires i3 and jq)
  if command -v i3-msg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    if [[ "$MONITOR_CONFIG" == "dual" ]]; then
      # In dual mode, move WS 1-3 to HDMI, WS 4-5 to EDP
      for w in "$WS1" "$WS2" "$WS3"; do
        cur_out=$(i3-msg -t get_workspaces | jq -r '.[] | select(.name=="'"$w"'") | .output')
        if [ -n "$cur_out" ] && [ "$cur_out" != "$HDMI_OUTPUT" ]; then
          i3-msg "workspace '$w'; move workspace to output $HDMI_OUTPUT" >/dev/null
        fi
      done

      for w in "$WS4" "$WS5"; do
        cur_out=$(i3-msg -t get_workspaces | jq -r '.[] | select(.name=="'"$w"'") | .output')
        if [ -n "$cur_out" ] && [ "$cur_out" != "$EDP_OUTPUT" ]; then
          i3-msg "workspace '$w'; move workspace to output $EDP_OUTPUT" >/dev/null
        fi
      done
    fi
  fi
fi
