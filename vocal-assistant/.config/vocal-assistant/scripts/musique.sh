#!/bin/bash
#
# Pilote la musique ou la vidéo : musique.sh pause|play|next|previous
#
# Le lecteur est celui que montre le module « now playing » de Waybar
# (~/.config/waybar/scripts/media.sh) : celui qui joue, le plus récent s'il y en
# a plusieurs, sinon le dernier mis en pause. Un onglet de Firefox en est un.
# « pause » et « reprends » sont deux commandes distinctes : dire « pause » ne
# relance jamais une musique déjà en pause.

MEDIA=~/.config/waybar/scripts/media.sh

case ${1:-} in
    pause) message="Pause." ;;
    play) message="Lecture." ;;
    next) message="Suivant." ;;
    previous) message="Précédent." ;;
    *)
        echo "musique.sh attend pause, play, next ou previous."
        exit 1
        ;;
esac

if [ -z "$("$MEDIA" player)" ]; then
    echo "Aucune musique ni vidéo n'est ouverte."
    exit 1
fi
if ! "$MEDIA" "$1" 2>/dev/null; then
    echo "Le lecteur n'a pas répondu."
    exit 1
fi
echo "$message"
