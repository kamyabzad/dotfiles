#!/bin/sh
eval "$(xdotool getwindowgeometry --shell "$XSCREENSAVER_WINDOW")"
export WIDTH HEIGHT
exec xterm -into "$XSCREENSAVER_WINDOW" -xrm 'XTerm*allowWindowOps: true' \
  -b 0 -bg black -fa Monospace -fs 12 \
  -e sh -c 'printf "\033[4;%s;%st" "$HEIGHT" "$WIDTH"; sleep 0.2; exec dripfetch'
