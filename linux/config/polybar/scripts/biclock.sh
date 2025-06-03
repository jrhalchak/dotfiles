#!/bin/bash
# Visual binary clock for Polybar using Unicode blocks

time=$(date +"%H %M %S")
output=" "
count=0
for part in $time; do
    # Convert each part to 6-bit binary
    bin=$(printf "%06d" "$(echo "obase=2; $part" | bc)")
    # Replace 1 with a filled block, 0 with a hollow block
    # vis=$(echo "$bin" | sed 's/1//g; s/0//g')
    # vis=$(echo "$bin" | sed 's/./&- /g; s/1/󰡖 /g; s/0/󰢤 /g; s/- $//')
    vis=$(echo "$bin" | sed 's/1/󰄮 /g; s/0/󰢤 /g; s/ $//')
    output+="$vis"
    count=$((count+1))
    [ $count -lt 3 ] && output+="  "
done
echo "$output "
