#!/bin/bash
#
# Active ou désactive le mode chat : mode-chat.sh on|off
#
# Le mode chat est celui du module Waybar (~/.config/waybar/scripts/cat.py) : le
# clavier et les clics sont bloqués, contre le chat. Ce qui est déjà fait ne
# change rien, et le dit.
#
# Le mode chat dure tant que son overlay tourne, en arrière-plan. L'assistant
# attend la fin de ce script pour lire sa réponse, puis systemd arrête tout ce
# que le script a laissé derrière lui : l'overlay, donc le mode chat. cat.py est
# donc lancé dans un scope à lui, qui survit au script.

CAT=~/.config/waybar/scripts/cat.py

# status répare aussi un mode chat resté sans overlay, comme le fait Waybar.
actif() { "$CAT" status 2>/dev/null | grep -q '"class": "on"'; }

case ${1:-} in
    on)
        if actif; then
            echo "Le mode chat est déjà activé."
        elif systemd-run --user --scope --quiet --collect "$CAT" turn_on 2>/dev/null; then
            echo "Mode chat activé."
        else
            echo "Je n'ai pas pu activer le mode chat : la barre Waybar est hors d'atteinte."
            exit 1
        fi
        ;;
    off)
        if ! actif; then
            echo "Le mode chat est déjà désactivé."
        else
            "$CAT" turn_off
            echo "Mode chat désactivé."
        fi
        ;;
    *)
        echo "mode-chat.sh attend on ou off."
        exit 1
        ;;
esac
