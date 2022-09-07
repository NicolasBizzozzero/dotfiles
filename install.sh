#!/usr/bin/sh

# Stow config files in home directory
stow _common
stow _custom
stow _games
stow alacritty
stow autorandr
stow calcurse
stow clipster
stow cups
stow dircolors
stow dunst
stow git
stow gnupg
stow htop
stow i3
stow jupyter
stow mpd
stow nano
stow ncmpcpp
stow neofetch
stow neomutt
stow neovim
stow nextcloud
stow npm
stow obs
stow picom
stow pinta
stow profile
stow python
stow ranger
stow rclone
stow ssh
stow sublime_text
stow systemd
stow vlc
stow wget
stow X11
stow xdg
stow yarn
stow zeal
stow zotero
stow zsh


# Force copy files in miscellaneous root directories
cp "crontab/$USER" /var/spool/cron/

