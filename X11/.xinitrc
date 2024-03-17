#!/bin/sh

# Source all scripts in xinitrc.d
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi


# TODO: ???
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto


# Set xresources location
xrdb -load $HOME/.config/X11/xresources

# Set numlock
numlockx &

# Solve Pycharm subwindows going funky
export _JAVA_AWT_WM_NONREPARENTING=1

# Disable terminal emulators scaling with DPI
export WINIT_X11_SCALE_FACTOR=1

exec i3
