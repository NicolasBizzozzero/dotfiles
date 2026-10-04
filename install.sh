#!/usr/bin/sh

# Stow config files in home directory
stow alarm_clock
stow claude
stow environment
stow fastfetch
stow git
stow gtk
stow htop
stow hypr
stow jupyter
stow keepassxc
stow kitty
stow mako
stow mpd
stow nano
stow neovim
stow python
stow rofi
stow ssh
stow starship
stow systemd
stow thunderbird
stow vlc
stow waybar
stow wget
stow xdg
stow yazi
stow zeal
stow zsh

# KeePassXC rewrites its config (and keeps its KeeShare private key in it), so
# only a reference copy is tracked: use it on a fresh install
[ -e ~/.config/keepassxc/keepassxc.ini ] ||
    cp ~/.config/keepassxc/keepassxc.base.ini ~/.config/keepassxc/keepassxc.ini

# Services
systemctl --user daemon-reload
systemctl --user enable --now \
    protonmail-bridge.service \
    waybar-mail.service \
    mpd.service \
    alarm_clock.service
sudo systemctl enable --now \
    bluetooth.service \
    cups.socket \
    cronie.service
