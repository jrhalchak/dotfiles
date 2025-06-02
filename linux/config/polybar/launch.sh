#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config.ini
if [[ $(xrandr | grep ' connected' | grep 3840x2160) ]]; then
    polybar left_4k &
    polybar right_4k &
else
    polybar left_1080p &
    polybar right_1080p &
fi

# Trap USR1 signal to toggle Polybar visibility
trap 'pkill -STOP polybar || pkill -CONT polybar' USR1

wait
