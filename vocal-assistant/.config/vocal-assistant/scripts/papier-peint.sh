#!/bin/bash
#
# Change le papier peint, comme cron le fait chaque heure : papier-peint.sh
#
# Le script qui choisit l'image est ~/scripts/ricing/change_wallpaper.sh. Il
# démarre hyprpaper s'il ne tourne pas. L'assistant attend la fin de ce script
# pour lire sa réponse, puis systemd arrête tout ce que le script a laissé
# derrière lui : hyprpaper avec. Le script tourne donc dans un scope à lui, qui
# survit (voir mode-chat.sh).

CHANGER=~/scripts/ricing/change_wallpaper.sh

if systemd-run --user --scope --quiet --collect "$CHANGER" >/dev/null 2>&1; then
    echo "Papier peint changé."
else
    echo "Je n'ai pas pu changer le papier peint."
    exit 1
fi
