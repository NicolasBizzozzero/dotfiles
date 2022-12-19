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
