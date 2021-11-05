alias explorer="$EXPLORER"

alias la='ls -A'
alias ll='ls -lA'
alias lt='ls -t'

alias sl='ls'


# Default commands parameters
alias ls='ls --color --human-readable --literal'
alias mkdir='mkdir -p'
alias mount='mount | column -t'
alias lp='lp -o orientation-requested=3 -o print-quality=5 -o sides=two-sided-long-edge'
alias pdflatex='mkdir bin && pdflatex -halt-on-error -output-directory=bin'
alias kmines='kmines --config $HOME/.config/kmines/kminesrc'
alias calcurse='calcurse -D ~/.config/calcurse'


alias fuck="sudo !!"
alias please="sudo"


# Spotify without adds (https://github.com/abba23/spotify-adblock)
alias spotify-adblock="LD_PRELOAD=/usr/local/lib/spotify-adblock.so spotify"


# WGET 
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts'

# Yarn
alias yarn="yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config"

# Open files with favorite editor
alias -s {yml,yaml,txt,py,csv,c,h,json}=$EDITOR

