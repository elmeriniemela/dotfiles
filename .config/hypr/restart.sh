#!/bin/sh

hyprctl reload || exit
pkill -u "$(id -u)" -x 'quickshell|hyprpaper|hypridle|hyprsunset|dunst|nm-applet|blueman-applet|hyprpolkitagent'
pkill -u "$(id -u)" -f '^wl-paste --type (text|image) --watch cliphist store$'
sleep 1
exec sh ~/.config/hypr/autostart.sh
