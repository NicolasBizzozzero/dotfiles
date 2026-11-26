#!/bin/bash
#
# Pilote la musique ou la vidéo : musique.sh pause|play|next|previous
#
# Le lecteur est celui que montre le module « now playing » de Waybar
# (~/.config/waybar/scripts/media.sh) : celui qui joue, le plus récent s'il y en
# a plusieurs, sinon le dernier mis en pause. Un onglet de Firefox en est un.
# « pause » et « reprends » sont deux commandes distinctes : dire « pause » ne
# relance jamais une musique déjà en pause. Ce qui est déjà fait le dit.

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

lecteur=$("$MEDIA" player)
if [ -z "$lecteur" ]; then
    echo "Aucune musique ni vidéo n'est ouverte."
    exit 1
fi
# Playing, Paused ou Stopped. Vide si le lecteur vient de disparaître : le
# lecteur répondra alors lui-même qu'il n'est plus là.
etat=$(playerctl --player="$lecteur" status 2>/dev/null)
if [ "$1" = pause ] && [ -n "$etat" ] && [ "$etat" != Playing ]; then
    echo "C'est déjà en pause."
    exit 0
fi
if [ "$1" = play ] && [ "$etat" = Playing ]; then
    echo "Ça joue déjà."
    exit 0
fi
if ! "$MEDIA" "$1" 2>/dev/null; then
    echo "Le lecteur n'a pas répondu."
    exit 1
fi
echo "$message"
