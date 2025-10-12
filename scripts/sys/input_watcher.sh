#!/bin/bash

inotifywait -m -e create,modify /tmp/input_trigger |
while read path action file; do
  ~/dotfiles/scripts/sys/input.sh
done

