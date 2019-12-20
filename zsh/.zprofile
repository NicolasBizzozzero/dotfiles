# Setup defaults softwares
export SHELL="zsh"
export PAGER="less"
export EDITOR="nvim"
export VISUAL=$EDITOR
export TERMINAL="termite"
export BROWSER="firefox"
export EXPLORER="thunar"


# Add local scripts to PATH
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"


# Start graphical environment
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi
