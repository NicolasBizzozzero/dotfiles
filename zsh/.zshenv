export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Here and not in .variables.sh: ly's login shell reads this file, so Hyprland
# and everything it launches (waybar's claude module) get it too
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# Where programs keep their files, out of $HOME. Here and not in .variables.sh
# (read by interactive shells only): ly's login shell reads this file, so
# Hyprland and every app it launches get them too, not only terminals. Paths
# only: nothing here changes how a program behaves.
# Development
export GOPATH="$XDG_DATA_HOME/go"
# Downloaded modules are a cache, apart from GOPATH's installed binaries
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CABAL_CONFIG="$XDG_CONFIG_HOME/cabal/config"
export CABAL_DIR="$XDG_DATA_HOME/cabal"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export DOCKER_CONFIG="$HOME/.config/docker"
# Python: every .pyc in one tree under the cache, instead of __pycache__
# folders next to the code (also in environment.d, for the user services)
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export KAGGLE_CONFIG_DIR="${XDG_CONFIG_HOME}/kaggle"
export NLTK_DATA="$XDG_DATA_HOME/nltk"
# Other programs
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/pass"
export RANDFILE="$XDG_DATA_HOME/openssl/.rnd"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export TS3_CONFIG_DIR="$XDG_CONFIG_HOME/ts3client"
export WEECHAT_HOME="$XDG_CONFIG_HOME/weechat"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export W3M_DIR="$XDG_DATA_HOME/w3m"
export WINEPREFIX="$XDG_DATA_HOME/wine"
# A history is state, not cache: ~/scripts/system/clean_caches.sh empties ~/.cache
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

export ZDOTDIR="$HOME/.config/zsh"

# Java, for the apps started from rofi too (IDEs, JDownloader), not only from
# a terminal. The JDK `archlinux-java set` chose: a fixed version breaks when
# it is removed (java-22 was, and JAVA_HOME pointed nowhere until 2026-11-27)
export JAVA_HOME="/usr/lib/jvm/default"
# Java's preferences out of ~/.java (an IDE started from rofi wrote there)
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
# WebStorm comes without its own Java (no webstorm-jre): it runs on this one
export WEBIDE_JDK="/usr/lib/jvm/java-21-openjdk"

# OpenGL apps (EGL) only load Mesa, the Intel GPU's driver. Otherwise every one
# of them, Hyprland included, also loads NVIDIA's and opens the NVIDIA GPU,
# which then never powers off, though nothing draws with it. Here because
# Hyprland itself needs it, before its config is read. Only if Mesa's file is
# there: with no driver at all, Hyprland would not start. Vulkan and CUDA
# (games, Ollama) still reach the NVIDIA GPU; for an OpenGL app on it, prefix
# it with __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json
if [[ -r /usr/share/glvnd/egl_vendor.d/50_mesa.json ]]; then
    export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
fi
