# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.


# Python local environment
PATH=~/.local/bin:$PATH


# Start Wayland
#if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
#  exec sway
#fi
#exec sway --unsupported-gpu
