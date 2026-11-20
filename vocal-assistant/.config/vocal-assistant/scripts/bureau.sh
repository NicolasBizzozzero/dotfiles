#!/bin/bash
#
# Va sur un bureau (workspace) de Hyprland : « va sur le workspace trois ».
#
# VOCAL_ASSISTANT_ARGUMENT contient ce qu'a pris l'étoile de la phrase :
# « trois », ou « numéro trois ». Seul le dernier mot compte. Quand c'est le LLM
# qui a choisi la commande, l'argument est vide : le dernier mot de la phrase
# entière le remplace.

texte=${VOCAL_ASSISTANT_ARGUMENT:-$VOCAL_ASSISTANT_PHRASE}
mot=${texte##* }

# Vosk écrit les nombres en mots.
case "${mot,,}" in
    1 | un | une | premier) numero=1 ;;
    2 | deux) numero=2 ;;
    3 | trois) numero=3 ;;
    4 | quatre) numero=4 ;;
    5 | cinq) numero=5 ;;
    6 | six) numero=6 ;;
    7 | sept) numero=7 ;;
    8 | huit) numero=8 ;;
    9 | neuf) numero=9 ;;
    10 | dix) numero=10 ;;
    *)
        echo "Je n'ai pas compris le numéro du bureau."
        exit 1
        ;;
esac

# Hyprland se configure en Lua ici : hyprctl dispatch prend la même expression
# que les raccourcis de hyprland.lua.
if [ "$(hyprctl dispatch "hl.dsp.focus({ workspace = \"$numero\" })")" != "ok" ]; then
    echo "Hyprland n'a pas changé de bureau."
    exit 1
fi

echo "Bureau $numero."
