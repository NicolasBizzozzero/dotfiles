#!/bin/sh

# Setup defaults softwares
export SHELL="zsh"
export PAGER="less"
export EDITOR="nvim"
export VISUAL=$EDITOR
export TERMINAL="alacritty"
export BROWSER="firefox"
export EXPLORER="thunar"

# Add local scripts to PATH
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Disable X11 dpi scaling
# Fix alacritty font wrt. multiple monitors
export WINIT_X11_SCALE_FACTOR=1

# X11 shit
export DISPLAY=:0

# if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#   exec startx
# fi
