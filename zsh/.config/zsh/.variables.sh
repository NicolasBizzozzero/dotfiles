# =============================================================================
# ZSH VARIABLES & ENVIRONMENT
# =============================================================================

# Only for shells. Where programs keep their files is set in ~/.zshenv, so that
# the apps Hyprland launches get it too; what stays here changes how programs
# behave, or only matters in a terminal.

# --- Wayland & Display ---
export ELECTRON_OZONE_PLATFORM_HINT=auto
export LIBVA_DRIVER_NAME=nvidia
export VDPAU_DRIVER=nvidia

# --- Development & Languages ---
export JAVA_HOME="/usr/lib/jvm/java-22-openjdk"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
export WEBIDE_JDK="/usr/lib/jvm/java-21-openjdk"
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

