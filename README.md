# dotfiles
My own local configuration files.  
Files are organized by software following a _GNU Stow_ hierarchy.

## Installation
To install the configuration files of a software, invoke the _GNU Stow_ command with the respecting software's directory.  
For example, if you want to install my *zsh* configuration files, simply run: 
```bash
$ stow zsh
```

Running `install.sh` stows everything at once and enables the services the configuration relies on (Proton Mail Bridge, the waybar mail watcher, MPD, the alarm clock, Bluetooth, CUPS and cron).

## System overview
The machine this runs on, roughly the way `fastfetch`/`neofetch` would summarize it:

| Role | Software | Package here |
|---|---|---|
| Distribution | Arch Linux | - |
| Window manager / compositor | Hyprland (Wayland) | `hypr` |
| Status bar | Waybar | `waybar` |
| Application launcher | Rofi | `rofi` |
| Notification daemon | Mako | `mako` |
| Login / display manager | ly | - |
| Screen locker | Hyprlock | - |
| Cursor theme | Catppuccin Mocha Mauve | `hypr`, `gtk` (theme installed by `install.sh`) |
| Password manager / keyring | KeePassXC | `keepassxc` |
| Alarm clock | alarm_clock | `alarm_clock` |
| Terminal emulator | kitty | `kitty` |
| Shell | zsh | `zsh` |
| Prompt | Starship | `starship` |
| Primary editor | Neovim | `neovim` |
| Secondary editor | nano | `nano` |
| Version control | git | `git` |
| Remote access | OpenSSH | `ssh` |
| AUR helper | yay | - |
| Web browser | Firefox | - |
| Music daemon | MPD | `mpd` |
| Video / media playback | VLC | `vlc` |
| Offline documentation | Zeal | `zeal` |
| Email client | Thunderbird | `thunderbird` |
| Proton Mail IMAP/SMTP bridge | Proton Mail Bridge | `systemd` |
| Terminal file manager | Yazi | `yazi` |
| Process monitor | htop | `htop` |
| System summary | fastfetch | `fastfetch` |
| Printing | CUPS | - |
| Python tooling | Python, IPython/Jupyter | `python`, `jupyter` |
| AI coding assistant | Claude Code | `claude` |

Entries with no package are either system-level (not something a home directory dotfile controls) or run fine on their defaults without any tracked configuration.

## What's in here
A quick tour of the software behind each package, grouped by what it's used for.

### Desktop
The system runs Hyprland (`hypr`) as the window manager, with `waybar` as the status bar, `mako` for notifications, and `rofi` as the application launcher. `gtk` holds the GTK toolkit theming, and `xdg` carries desktop-wide defaults such as default applications and user directories.

### Shell
`zsh` is the shell, with `starship` for the prompt.

### Terminal and editors
`kitty` is the terminal emulator. `neovim` is the main text editor, with `nano` kept around for quick edits.

### Development
`git` and `ssh` cover version control and remote access. `python` holds general Python configuration, and `jupyter` configures Jupyter and IPython for notebook work. `claude` holds the settings for Claude Code.

### Media
`mpd` runs as a background music daemon, and `vlc` handles video and other media playback.

### Documentation and mail
`zeal` is an offline documentation browser. Mail is read in Thunderbird (`thunderbird`), which stores it as Maildir under `~/.local/share/mail` instead of inside its profile. `systemd` runs Proton Mail Bridge in the background so Thunderbird can reach the Proton account over IMAP/SMTP; Bridge already keeps a local copy of that account, so Thunderbird does not download one.

### System
`fastfetch` prints a quick system summary, `htop` is the process monitor, and `wget` is used for downloads from the command line.
