# =============================================================================
# MAIN ZSH CONFIGURATION (~/.config/zsh/.zshrc)
# =============================================================================

# --- 1. History Configuration ---
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt CORRECT

# --- 2. Keybindings ---
bindkey -e # Use Emacs keybindings (default)
bindkey "^[[1;5C" forward-word             # Ctrl+Right
bindkey "^[[1;5D" backward-word            # Ctrl+Left
bindkey "^[[H" beginning-of-line           # Home
bindkey "^[[F" end-of-line                 # End
bindkey "^[[1;6C" vi-forward-word          # Ctrl+Shift+Right (Kitty)
bindkey "^[[1;6D" vi-backward-word         # Ctrl+Shift+Left (Kitty)
bindkey '^[[3~' delete-char                # Fix Delete key outputting '~'
bindkey '^[[Z' reverse-menu-complete       # Shift+Tab to go backward in completion menu

# --- 3. Sources (Aliases & Variables) ---
source "$ZDOTDIR/.variables.sh"
source "$ZDOTDIR/.aliases.sh"

# --- 4. Completion System ---
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive tab completion

# --- 5. Plugins ---
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/doc/find-the-command/ftc.zsh

# --- 6. Prompt (MUST BE LAST) ---
eval "$(starship init zsh)"
