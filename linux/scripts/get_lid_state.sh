#!/bin/bash

# Returns "open" or "closed"
LID_PATH=$(ls /proc/acpi/button/lid/ | head -n1)
cat /proc/acpi/button/lid/$LID_PATH/state | awk '{print $2}'

