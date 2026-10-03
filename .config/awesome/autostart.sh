#!/bin/bash

function run {
  if ! pgrep -x -- "$1" >/dev/null;
  then
    "$@" &
  fi
}
run nm-applet
run blueman-applet --loglevel debug --syslog
run lxpolkit
run xfce4-clipman
run xss-lock -- "$HOME/.config/awesome/scripts/locker.sh"
run picom -b --config "$HOME/.config/awesome/picom.conf"
