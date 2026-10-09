#!/bin/sh
# Start or stop a screen recording of a selected region.
# Used by the Super + Shift + R bind and the Quickshell bar button.

# If a recording is running, stop it. SIGINT lets wf-recorder finish the file.
pkill -INT -x wf-recorder && exit

# Pick a region. Escape cancels without recording.
region=$(slurp) || exit
mkdir -p ~/Downloads
file=~/Downloads/rec-$(date +%F_%H%M%S).mp4

notify-send "Recording started"
# Encode on the Intel GPU (VA-API) to keep CPU use low.
wf-recorder -g "$region" -c h264_vaapi -d /dev/dri/renderD128 -f "$file"
notify-send "Recording stopped" "$file"
