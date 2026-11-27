# =============================================================================
# ZSH VARIABLES & ENVIRONMENT
# =============================================================================

# Only what matters in a terminal. What graphical apps need too is set where
# Hyprland gets it: ~/.zshenv (where programs keep their files, Java, the GPU)
# and Hyprland's config (display, video decoding). Not here: terminals get all
# of it anyway, from kitty.

# --- Development & Languages ---
export NODE_PATH="$XDG_DATA_HOME/node/node_modules"
export NVM_DIR="$XDG_DATA_HOME/nvm"

# --- Python / Data Science ---
export BETTER_EXCEPTIONS=1

# --- App Configs (XDG Workarounds) ---
export DOCKER_BUILDKIT=1

# --- Miscellaneous ---
export TORBROWSER_PKGLANG="fr"
export PATH_DIR_WEBSITE="/home/johnlocke/work/projects/personal_website"
export PRINTER="Brother_HL_L1240W"
export EDITOR="nvim"
export VISUAL="nvim"

