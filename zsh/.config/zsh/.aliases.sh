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

# --- CLI Tools ---
alias mkdir='mkdir -p'
alias mount='mount | column -t'
alias pdflatex='mkdir -p bin && pdflatex -halt-on-error -output-directory=bin'

# --- Applications & XDG Fixes ---
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'
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
