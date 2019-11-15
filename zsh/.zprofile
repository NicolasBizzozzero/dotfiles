
export PATH="$HOME/scripts"

export EDITOR="nvim"
export TERMINAL="urxvt"
export BROWSER="firefox"


# Add Python local bin dir to PATH
export PATH="$HOME/.local/bin:$PATH"


if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1  ]]; then
  exec startx
fi
