##
# Config files
##

# Cabal
export CABAL_CONFIG="$XDG_CONFIG_HOME/cabal/config"

# Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# iPython / Jupyter
export IPYTHONDIR="$XDG_CONFIG_HOME/jupyter"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"

# Node
export NODE_PATH="$XDG_DATA_HOME/node/node_modules"

# NPM
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# NLTK
export NLTK_DATA="$XDG_DATA_HOME/nltk"

# Python
export PYTHONHISTFILE="$XDG_DATA_HOME/python/python_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/startup.py"

# Shell's history files
export HISTFILE="$XDG_DATA_HOME/zsh/zsh_history"

# TeamSpeak
export TS3_CONFIG_DIR="$XDG_CONFIG_HOME/ts3client"

# WeeChat
export WEECHAT_HOME="$XDG_CONFIG_HOME/weechat"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# Wine
export WINEPREFIX="$HOME/.wine"

# X11
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
# Removed because not working : export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"

# Z
export _Z_DATA="$XDG_DATA_HOME/z"


##
# SSH
##
SSH_OSIRIM="nbizzozz@osirim-slurm.irit.fr"


##
# Build parameters
## 

export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"
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

