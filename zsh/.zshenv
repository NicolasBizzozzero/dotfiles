export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Here and not in .variables.sh: ly's login shell reads this file, so Hyprland
# and everything it launches (waybar's claude module) get it too
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

export ZDOTDIR="$HOME/.config/zsh"
