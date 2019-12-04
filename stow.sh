#!/usr/bin/zsh
#
# Launch the GNU Stow software on all directories of this repository to
# install them in their proper location.


stow _custom
stow autorandr
stow bash
stow compton
stow git
stow gnupg
stow htop
stow i3
stow ipython
stow ls
stow nano
stow neomutt
stow neovim
stow profile
stow ssh
stow vlc
stow X
stow zsh

# TODO: Stow root directories with -t param
