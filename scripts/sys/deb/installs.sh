#!/bin/bash

# Some common utils I install with every fresh install
## NOTE: This presupposes you're using `apt`, won't work on nono-apt distroes
##       and you'll need to run this script as sudo
apt update && apt install ripgrep xclip
