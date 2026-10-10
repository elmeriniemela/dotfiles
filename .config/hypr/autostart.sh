#!/bin/sh

quickshell -p ~/.config/hypr/quickshell --no-duplicate &
hyprpaper &
hypridle &
hyprsunset &
dunst &
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
nm-applet &
blueman-applet &
/usr/lib/hyprpolkitagent/hyprpolkitagent &
