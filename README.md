# dotfiles
My own local configuration files.  
Files are organized by software following a _GNU Stow_ hierarchy.

## Installation
To install the configuration files of a software, invoke the _GNU Stow_ command with the respecting software's directory.  
For example, if you want to install my *zsh* configuration files, simply run: 
```bash
$ stow zsh
```

Running `install.sh` stows everything at once.

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
| Email client | NeoMutt | `neomutt` |
| Terminal file manager | Yazi | `yazi` |
| Process monitor | htop | `htop` |
| System summary | fastfetch | `fastfetch` |
| Printing | CUPS | `cups` |
| Python tooling | Python, IPython/Jupyter | `python`, `jupyter` |
| JavaScript package manager | Yarn | `yarn` |
| AI coding assistant | Claude Code | `claude` |

Entries with no package are either system-level (not something a home directory dotfile controls) or run fine on their defaults without any tracked configuration.

## What's in here
A quick tour of the software behind each package, grouped by what it's used for.

### Desktop
The system runs Hyprland (`hypr`) as the window manager, with `waybar` as the status bar, `mako` for notifications, and `rofi` as the application launcher. `gtk` and `qt` hold the toolkit theming shared by GTK and Qt applications, and `xdg` carries desktop-wide defaults such as default applications and user directories.

### Shell
`zsh` is the shell, with `starship` for the prompt.

### Terminal and editors
`kitty` is the terminal emulator. `neovim` is the main text editor, with `nano` kept around for quick edits.

### Development
`git` and `ssh` cover version control and remote access. `python` holds general Python configuration, and `jupyter` configures Jupyter and IPython for notebook work. `yarn` is the JavaScript package manager. `claude` holds the settings for Claude Code.

### Media
`mpd` runs as a background music daemon, and `vlc` handles video and other media playback.

### Documentation and mail
`zeal` is an offline documentation browser, and `neomutt` is the email client.

### System
`fastfetch` prints a quick system summary, `htop` is the process monitor, `cups` handles printing, and `wget` is used for downloads from the command line.
