#!/bin/sh

setxkbmap us

XSECURELOCK_SAVER="$HOME/.config/i3/lock-saver.sh" \
XSECURELOCK_SHOW_DATETIME=1 \
xsecurelock

setxkbmap us,ir -option grp:ctrls_toggle
xmodmap ~/.Xmodmap
