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
stow tuxedo
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

# Cursor theme (Catppuccin Mocha Mauve, xcursor + hyprcursor), not packaged in
# the official repos: install the upstream release for the user
CURSOR=catppuccin-mocha-mauve-cursors
if [ ! -d ~/.local/share/icons/$CURSOR ]; then
    mkdir -p ~/.local/share/icons
    curl -sL -o /tmp/$CURSOR.zip \
        https://github.com/catppuccin/cursors/releases/download/v2.0.0/$CURSOR.zip &&
        python3 -c "import zipfile, os; zipfile.ZipFile('/tmp/$CURSOR.zip').extractall(os.path.expanduser('~/.local/share/icons'))"
    rm -f /tmp/$CURSOR.zip
fi

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

# Power: TUXEDO Control Center is the only power manager (power-profiles-daemon
# would fight over the same CPU settings); install the profiles, power saving by default
sudo systemctl enable --now tccd.service
sudo systemctl mask --now power-profiles-daemon.service
sudo ~/.config/tuxedo/apply.sh
