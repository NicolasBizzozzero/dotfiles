# =============================================================================
# ZSH VARIABLES & ENVIRONMENT
# =============================================================================

# --- Wayland & Display ---
export ELECTRON_OZONE_PLATFORM_HINT=auto
export LIBVA_DRIVER_NAME=nvidia
export VDPAU_DRIVER=nvidia

# --- Development & Languages ---
export JAVA_HOME="/usr/lib/jvm/java-22-openjdk"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
export WEBIDE_JDK="/usr/lib/jvm/java-21-openjdk"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export NODE_PATH="$XDG_DATA_HOME/node/node_modules"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export CABAL_CONFIG="$XDG_CONFIG_HOME/cabal/config"
export CABAL_DIR="$XDG_DATA_HOME/cabal"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"

# --- Python / Data Science ---
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export KAGGLE_CONFIG_DIR="${XDG_CONFIG_HOME}/kaggle"
export NLTK_DATA="$XDG_DATA_HOME/nltk"
export BETTER_EXCEPTIONS=1

# --- App Configs (XDG Workarounds) ---
export ANDROID_HOME="$XDG_DATA_HOME/android"
export DOCKER_CONFIG="$HOME/.config/docker"
export DOCKER_BUILDKIT=1
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export RANDFILE="$XDG_DATA_HOME/openssl/.rnd"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/pass"
export TS3_CONFIG_DIR="$XDG_CONFIG_HOME/ts3client"
export WEECHAT_HOME="$XDG_CONFIG_HOME/weechat"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export W3M_DIR="$XDG_DATA_HOME/w3m"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# --- Miscellaneous ---
export TORBROWSER_PKGLANG="fr"
export PATH_DIR_WEBSITE="/home/johnlocke/work/projects/personal_website"
export PRINTER="HP-LaserJet-2"
export EDITOR="nvim"
export VISUAL="nvim"

