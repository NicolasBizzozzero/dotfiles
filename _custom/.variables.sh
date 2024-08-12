##
# Config files
##

# Android-Studio
export ANDROID_HOME="$XDG_DATA_HOME"/android

# Cabal
export CABAL_CONFIG="$XDG_CONFIG_HOME"/cabal/config
export CABAL_DIR="$XDG_DATA_HOME"/cabal

# Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Cuda
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export DOCKER_BUILDKIT=1

# GNUGPG
export GNUPGHOME="$XDG_DATA_HOME"/gnupg

# Go
export GOPATH="$XDG_DATA_HOME/go"

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# iPython / Jupyter
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter

# kaggle
export KAGGLE_CONFIG_DIR="${XDG_CONFIG_HOME}/kaggle"

# Node
export NODE_PATH="$XDG_DATA_HOME/node/node_modules"

# NPM
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# NVM
export NVM_DIR="$XDG_DATA_HOME/nvm"

# NLTK
export NLTK_DATA="$XDG_DATA_HOME/nltk"

# Nuget
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages

# OpenSSL
export RANDFILE="$XDG_DATA_HOME"/openssl/.rnd

# Parallel
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel

# pass
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

# Python
export PYTHONSTARTUP="/etc/python/pythonrc"

# Shell's history files
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export HISTFILE="${XDG_STATE_HOME}"/zsh/zsh_history

# TeamSpeak
export TS3_CONFIG_DIR="$XDG_CONFIG_HOME/ts3client"

# WeeChat
export WEECHAT_HOME="$XDG_CONFIG_HOME/weechat"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# w3m
export W3M_DIR="$XDG_DATA_HOME"/w3m

# Wine
export WINEPREFIX="$XDG_DATA_HOME/wine"

# X11
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
# Removed because not working : export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"

# Z
export _Z_DATA="$XDG_DATA_HOME/z"


##
# SSH
##
SSH_OSIRIM="nbizzozz@osirim-slurm.irit.fr"
alias ssh_personnal='ssh nicolas@51.38.187.4 -p 64219'


##
# Build parameters
##

export JAVA_HOME="/usr/lib/jvm/java-22-openjdk"
export TORBROWSER_PKGLANG="fr"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"


##
# Printer
##

PRINTER="HP-LaserJet-2"


##
# Miscellaneous
##

# Python better-exceptions: https://github.com/qix-/better-exceptions
export BETTER_EXCEPTIONS=1

# Cursor theme (X11)
export XCURSOR_THEME=volantes_cursors
export XCURSOR_PATH=${XCURSOR_PATH}:~/.local/share/icons:/usr/share/icons
