#!/bin/bash
#
# Dit la météo actuelle d'après wttr.in, pour la ville du module météo de
# Waybar : voir ~/.config/waybar/scripts/weather.sh.

if ! lieu=$(~/.config/waybar/scripts/weather.sh city); then
    echo "Je n'arrive pas à savoir où tu es."
    exit 1
fi
# La première ligne est la ville, la seconde dit comment elle a été trouvée.
ville=${lieu%%$'\n'*}

lieu=$(printf '%s' "$ville" | jq -sRr @uri)
if ! meteo=$(curl -sf --max-time 8 -A "vocal-assistant" "https://wttr.in/$lieu?format=%C,+%t&lang=fr&m"); then
    echo "Le service météo ne répond pas."
    exit 1
fi

# wttr.in renvoie « Bruine légère, +10°C ». Piper lirait « plus dix degrés C »,
# et ignorerait le signe moins : la température est écrite en mots.
meteo=$(printf '%s' "$meteo" | sed 's/+\([0-9]*\)°C/\1 degrés/; s/-\([0-9]*\)°C/moins \1 degrés/')

echo "À $ville : $meteo."
