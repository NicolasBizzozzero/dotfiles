# dotfiles
My own local configuration files.  
Files are organized by software following a _GNU Stow_ hierarchy.

## Installation
To install the configuration files of a software, invoke the _GNU Stow_ command with the respecting software's directory.  
For example, if you want to install my *zsh* configuration files, simply run: 
```bash
$ stow zsh
```

Running `install.sh` stows everything at once and enables the services the machine relies on.

## Outside the home directory
`system/` holds what _GNU Stow_ can't place, as reference copies for a new machine:
- `system/etc/`: files added or edited in `/etc`, to copy back by hand with `sudo cp`. Do `pacman.conf` first: some packages come from multilib.
- `system/packages.txt` and `system/packages-aur.txt`: explicitly installed packages, refreshed with `pacman -Qqen` and `pacman -Qqem`.
- `system/crontab`: installed by `install.sh` when there is no crontab yet.

```bash
$ sudo pacman -S --needed - < system/packages.txt
$ yay -S --needed - < system/packages-aur.txt
```

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
| Power / fan profiles | TUXEDO Control Center | `tuxedo` (profiles applied with `sudo ~/.config/tuxedo/apply.sh`, no GUI needed) |
| Terminal emulator | kitty | `kitty` |
| Shell | zsh | `zsh` |
| Prompt | Starship | `starship` |
| Primary editor | Neovim | `neovim` |
| Secondary editor | nano | `nano` |
| Version control | git | `git` |
| Remote access | OpenSSH | `ssh` |
| AUR helper | yay | - |
| Web browser | Firefox (+ Violentmonkey) | `userscripts` (installed in Violentmonkey, not stowed) |
| Music daemon | MPD | `mpd` |
| Video / media playback | VLC | `vlc` |
| Offline documentation | Zeal | `zeal` |
| Email client | Thunderbird | `thunderbird` |
| Proton Mail IMAP/SMTP bridge | Proton Mail Bridge | `systemd` |
| Nightly sync of my monitoring projects | systemd user timers | `systemd` (`monitor-sync@InstaMonitor`, `monitor-sync@TwitterMonitor`) |
| Terminal file manager | Yazi | `yazi` |
| Process monitor | htop | `htop` |
| System summary | fastfetch | `fastfetch` |
| Printing | CUPS, Brother HL-L1240W | - (queue created by `install.sh`; mDNS left to avahi by `system/etc`, Docker's bridges included) |
| Python tooling | Python, IPython/Jupyter | `python`, `jupyter` |
| AI coding assistant | Claude Code | `claude` (settings, and the subagents every session can call: `reviewer`, `tester`, `sysadmin`) |
| Voice assistant | vocal-assistant | `vocal-assistant` (its config and the scripts its commands run: time, date, weather, timers, music, volume, Wikipedia...; the wake word model is trained locally and not tracked), and a `waybar` module: its state and LLM, a right click to turn it on/off |

Entries with no package are either system-level (not something a home directory dotfile controls) or run fine on their defaults without any tracked configuration.

## What's in here
A quick tour of the software behind each package, grouped by what it's used for.

### Desktop
The system runs Hyprland (`hypr`) as the window manager, with `waybar` as the status bar, `mako` for notifications, and `rofi` as the application launcher. `gtk` holds the GTK toolkit theming, and `xdg` carries desktop-wide defaults such as default applications and user directories.

Waybar's Bluetooth module (right click: on/off, also used by the voice assistant) keeps its state across reboots. Off is an rfkill block, which systemd-rfkill restores at boot. On is restored at login by `bluetooth.sh restore`, from Hyprland's autostart: BlueZ is meant to power the adapter on at boot, but on this laptop that fails every time.

Waybar's weather module (also used by the voice assistant) finds the city from the Wi-Fi name, through a table of known networks, else from the IP address. That table is kept out of this public repository, in `~/.config/waybar/weather_cities.sh`, as `CITIES=(["Wi-Fi name"]="City")`.

### Shell
`zsh` is the shell, with `starship` for the prompt. Its aliases include the one-line commands that used to be scripts in `~/scripts` (`yay_clean`, `git_version_number`, `docker_build`, `screenshot`, `random_file`...).

### Terminal and editors
`kitty` is the terminal emulator. `neovim` is the main text editor, with `nano` kept around for quick edits.

### Development
`git` and `ssh` cover version control and remote access. `python` holds general Python configuration, and `jupyter` configures Jupyter and IPython for notebook work. `claude` holds the settings for Claude Code, and three subagents shared by every project (`.config/claude/agents/`). Each has one task, returns a short report in a fixed format, and never fixes anything itself:
- `reviewer` reads a change before a commit and gives a verdict with its findings. Read-only, on Opus.
- `tester` runs a project's tests, linter and formatter check, or tries a script in a throwaway folder. On Sonnet.
- `sysadmin` diagnoses the computer from its logs and gives the commands to paste. Read-only, on Sonnet.

Call one by name in any session, e.g. `@agent-reviewer`, or let Claude pick it from its description.

`claude` also places `~/work/projects/CLAUDE.md`: the engineering rules all my projects follow (plan, verify, small commits, the `Assisted-by` trailer...). Claude Code reads the `CLAUDE.md` of every parent folder, so each project under `~/work/projects` inherits it and no repository carries a copy. Sessions in `~/.dotfiles` or `~/scripts` are outside that folder and don't load it.

### Media
`mpd` runs as a background music daemon, and `vlc` handles video and other media playback.

### Browser
`userscripts` holds Firefox userscripts. They are not stowed: they need the **Violentmonkey** extension, and each is installed by opening its raw GitHub URL in Firefox (Violentmonkey then keeps it up to date from this repository).
- `youtube-media-keys.user.js`: YouTube next/previous over MPRIS (waybar `custom/media` right/middle click, media keys), in a playlist or not. Install: <https://raw.githubusercontent.com/NicolasBizzozzero/dotfiles/master/userscripts/youtube-media-keys.user.js>
- `x-deleted-post-archive.user.js`: on a post that X says no longer exists or that its author hid (protected account), a panel with its archived text and captures from the Wayback Machine (searched under twitter.com and x.com), plus archive.today and Ghostarchive links. Also on any post from the Violentmonkey menu ("Chercher une archive de ce post"). The post's address only goes to archive.org in those two cases. Install: <https://raw.githubusercontent.com/NicolasBizzozzero/dotfiles/master/userscripts/x-deleted-post-archive.user.js>

### Documentation and mail
`zeal` is an offline documentation browser. Mail is read in Thunderbird (`thunderbird`), which stores it as Maildir under `~/.local/share/mail` instead of inside its profile. `systemd` runs Proton Mail Bridge in the background so Thunderbird can reach the Proton account over IMAP/SMTP; Bridge already keeps a local copy of that account, so Thunderbird does not download one.

### System
`fastfetch` prints a quick system summary, `htop` is the process monitor, and `wget` is used for downloads from the command line.

### Scheduled jobs
`systemd` also holds `monitor-sync@.service` and `monitor-sync@.timer`, a template that runs `main.py sync` of a project in `~/work/projects/<name>` every night between 3:00 and 3:30. It's enabled for `InstaMonitor` and `TwitterMonitor`. A night missed while the laptop was off or asleep is made up as soon as it's back. Only a failed sync sends a notification.
```bash
$ systemctl --user list-timers 'monitor-sync@*'        # last and next run
$ journalctl --user -u monitor-sync@InstaMonitor       # what a run printed
$ systemctl --user start monitor-sync@TwitterMonitor   # sync now (never twice at once)
```
Other scripts live in a separate private repository, `~/scripts`; the hourly wallpaper change comes from its `ricing/` folder through `system/crontab`.
