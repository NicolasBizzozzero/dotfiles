# --- Eza (ls replacement) ---
alias ls='eza --color=always --icons=always --group-directories-first'
alias ll='eza -la --color=always --icons=always --group-directories-first --git'
alias la='eza -a --color=always --icons=always --group-directories-first'
alias lt='eza --tree --level=2 --color=always --icons=always --group-directories-first'
alias sl='ls' # Catch the common 'sl' typo

# --- File explorer
alias thunar='nemo'

# --- System & Package Management ---
alias fetch='fastfetch'
alias neofetch='fastfetch'
alias fuck='sudo !!'
alias please='sudo'

# --- One-liners that were scripts in ~/scripts ---
alias yay_clean='yay -Sc'
alias list_packages='yay -Ps'  # Statistics about the installed packages
alias yay_lspkg='yay -Qqe'     # The explicitly installed packages
alias grep_last_updated_packages="grep -iE 'installed|upgraded' /var/log/pacman.log"
alias ls_disks_usage='df -H'
alias git_version_number='git describe --always --dirty'
alias docker_clean_system='docker system prune --volumes'
alias docker_run='docker run -d -p 80:80'  # docker_run IMAGE: in the background, port 80 forwarded
docker_build() { docker build -t "$1" "${2:-.}"; }  # docker_build NAME [DIR]: DIR holds the Dockerfile (default: .)
alias grep_kernel_errors='journalctl -b -k -p err --no-pager'  # This boot's kernel errors (~/scripts/system/syslogs.sh for everything)
alias grep_systemd_failed='systemctl --failed; systemctl --user --failed'
alias get_chmod_code="stat -c '%a %n'"  # get_chmod_code FILE...: the permissions as a number
copy_to_clipboard() { wl-copy < "$1"; }  # copy_to_clipboard FILE: its contents
lss() { command ls -U "${1:-.}" | head -n "${2:-10}"; }  # lss [DIR] [N]: N names, unsorted (fast in a huge folder)
random_file() { find "${1:-.}" -maxdepth 1 -type f | shuf -n "${2:-1}"; }  # random_file [DIR] [N]
random_integer() { shuf -i "${1:-0}-${2:-100}" -n 1; }  # random_integer [MIN] [MAX], both included
scrap_subreddit() { gallery-dl "https://www.reddit.com/r/$1/"; }  # scrap_subreddit NAME: its images and videos, in ./gallery-dl
# screenshot [area]: the whole screen, or an area chosen with the mouse, into ~/pictures/screenshots
screenshot() {
	local file=~/pictures/screenshots/screenshot-$(date +%Y%m%d@%H%M%S).png area
	local -a geometry
	if [[ ${1:-} == area ]]; then area=$(slurp) || return 1; geometry=(-g "$area"); fi
	mkdir -p ~/pictures/screenshots && grim "${geometry[@]}" "$file" && notify-send Screenshot "$file"
}

# --- CLI Tools ---
alias mkdir='mkdir -p'
alias mount='mount | column -t'
alias pdflatex='mkdir -p bin && pdflatex -halt-on-error -output-directory=bin'

# --- Applications & XDG Fixes ---
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias nvidia-settings='nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings"'
alias minecraft-launcher='minecraft-launcher --workDir "$XDG_DATA_HOME/minecraft"'
alias youtube-dl='yt-dlp'
alias handbrake='ghb'
alias setup_mouse='rivalcfg'
alias chromecast='go-chromecast'
alias spotify-adblock='LD_PRELOAD=/usr/local/lib/spotify-adblock.so spotify'

# --- Printers ---
alias lp='lp -o orientation-requested=3 -o print-quality=5 -o sides=two-sided-long-edge'

# --- SSH ---
# Wrap SSH with known terminal to prevent terminfo errors on remote servers
alias ssh='TERM=xterm-256color command ssh'

# --- Extension Handlers ---
# Auto-open these files with Neovim/Vim if you just type their name
alias -s {yml,yaml,txt,py,csv,c,h,json}=$EDITOR

# --- Yazi Wrapper ---
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias yazi='yy'
