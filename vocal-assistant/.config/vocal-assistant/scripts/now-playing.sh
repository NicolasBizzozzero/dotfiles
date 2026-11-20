#!/bin/bash
#
# Décrit en texte ce que joue le lecteur montré par le module « now playing » de
# Waybar (~/.config/waybar/scripts/media.sh) : une musique, ou une vidéo dans un
# onglet de Firefox.
#
# La commande now_playing de config.yaml confie ce texte au LLM
# (interpret_output) : il le reformule pour répondre à la question posée. Le
# texte est déjà aussi clair que possible : qwen3.5:2b invente des détails dès
# qu'il doit deviner ou calculer. Ainsi les durées ne sont données que si la
# question porte sur le temps, et elles sont calculées ici, puis écrites en
# lettres par nombres.py.

MEDIA=~/.config/waybar/scripts/media.sh
NOMBRES="${BASH_SOURCE%/*}/nombres.py"

lecteur=$("$MEDIA" player)
if [ -z "$lecteur" ]; then
    echo "Aucune musique ni vidéo n'est ouverte."
    exit 1
fi

valeur() {
    playerctl -p "$lecteur" metadata "$1" 2>/dev/null
}

# Le nom MPRIS d'un onglet de Firefox est « firefox.instance_1_29 ».
case $lecteur in
    firefox*)
        case $(valeur xesam:url) in
            *youtube.com* | *youtu.be*) source="une vidéo YouTube, dans Firefox" ;;
            *) source="un onglet de Firefox" ;;
        esac
        ;;
    *) source=${lecteur%%.*} ;;
esac
case $(playerctl -p "$lecteur" status 2>/dev/null) in
    Playing) etat="en lecture" ;;
    Paused) etat="en pause" ;;
    *) etat="arrêté" ;;
esac

echo "Source : $source"
echo "État : $etat"
titre=$(valeur xesam:title) && [ -n "$titre" ] && echo "Titre : $titre"
artiste=$(valeur xesam:artist) && [ -n "$artiste" ] && echo "Artiste : $artiste"
album=$(valeur xesam:album) && [ -n "$album" ] && echo "Album : $album"

case ${VOCAL_ASSISTANT_PHRASE,,} in
    *temps* | *reste* | *dur* | *combien* | *fini* | *long*) ;;
    *) exit 0 ;;
esac
# position est en secondes, mpris:length en microsecondes.
position=$(playerctl -p "$lecteur" position 2>/dev/null)
position=${position%.*}
longueur=$(valeur mpris:length)
longueur=$((${longueur:-0} / 1000000))
if [ -n "$position" ] && ((longueur > 0)); then
    echo "Temps restant : $("$NOMBRES" --duree $((longueur - position)))"
    echo "Durée totale : $("$NOMBRES" --duree "$longueur")"
fi
exit 0
