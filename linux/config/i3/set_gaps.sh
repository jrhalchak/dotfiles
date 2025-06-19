#!/bin/bash

xrandr_output="$(xrandr | grep ' connected')"
echo "$xrandr_output" > /tmp/xrandr_debug.txt

if echo "$xrandr_output" | grep -q '3840x2160'; then
    # 4K screen detected
    i3-msg 'gaps inner all set 16'
    i3-msg 'gaps outer all set 8'
    i3-msg 'gaps top all set 56'
    # elif echo "$xrandr_output" | grep -q '1920x1080'; then
    #    i3-msg 'gaps inner 8; gaps outer 15'
else
  # 1080p
  i3-msg 'gaps inner all set 16'
  i3-msg 'gaps outer all set 0'
  i3-msg 'gaps top all set 48'
fi

