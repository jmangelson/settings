#!/bin/bash

export GTK2_RC_FILES=/usr/share/themes/Clearlooks/gtk-2.0/gtkrc:${HOME}/.gtkrc-mine
export OOO_FORCE_DESKTOP='gnome'

#Temporary fix for latex files being used in openbox
eval "$(grep 'export ...INPUTS=' ~/.bashrc)"

[ -f ${HOME}/.swapcaps ] && xmodmap .swapcaps
[ -f ${HOME}/swapcaps ] && xmodmap swapcaps
[ -f ${HOME}/.xmodmap  ] && xmodmap .xmodmap

gnome-keyring-daemon

rr

xrandr -q | grep -q 'VGA1 connected' && Esetroot ~/pics/netwall/road-dual.jpg || Esetroot -s ~/pics/netwall/maldiviansunset_2560x1440.jpg

gnome-power-manager &
gnome-volume-control-applet &
gnome-panel &
checkgmail &
nm-applet &
