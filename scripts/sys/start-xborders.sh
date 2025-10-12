#!/usr/bin/env bash

# Wait for picom compositor to be fully ready
# Check the actual X property that indicates compositor is running

max_wait=50  # 5 seconds max
count=0

echo "Waiting for compositor..."

while [ $count -lt $max_wait ]; do
    # Check if compositor is registered with X server
    if xprop -root _NET_WM_CM_S0 > /dev/null 2>&1; then
        # Also verify GTK can detect it (what xborders uses)
        if python3 -c "import gi; gi.require_version('Gdk', '3.0'); from gi.repository import Gdk; import sys; sys.exit(0 if Gdk.Screen.get_default().is_composited() else 1)" 2>/dev/null; then
            echo "Compositor ready, starting xborders..."
            break
        fi
    fi
    
    count=$((count + 1))
    sleep 0.1
done

if [ $count -ge $max_wait ]; then
    echo "Warning: Compositor not fully ready after 5s, starting xborders anyway..."
fi

exec xborders "$@"
