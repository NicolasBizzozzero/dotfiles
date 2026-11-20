#!/bin/bash
#
# Change le volume de la sortie son : volume.sh up|down|mute|unmute|set
#
# Mêmes règles que les touches de volume (~/.config/waybar/scripts/pulseaudio.sh) :
# pamixer, 150 % au plus, et monter ou baisser le son quand il est coupé le
# remet d'abord. Le pas est plus grand qu'au clavier : une phrase vaut deux appuis.
#
# set règle le volume au nombre dit : « mets le volume à cinquante ». Il le lit
# dans $VOCAL_ASSISTANT_ARGUMENT, ou après le dernier « à » de la phrase quand
# c'est le LLM qui a choisi la commande. « à fond » vaut 100 %.

PAS=10
LIMITE=150
NOMBRES="${BASH_SOURCE%/*}/nombres.py"

volume_dit() {
    echo "$(pamixer --get-volume) pour cent"
}

coupe=$(pamixer --get-mute)

case ${1:-} in
    up | down)
        if [ "$coupe" = "true" ]; then
            pamixer -u
            echo "Son remis, à $(volume_dit)."
            exit 0
        fi
        if [ "$1" = "up" ]; then
            pamixer -i "$PAS" --allow-boost --set-limit "$LIMITE"
        else
            pamixer -d "$PAS"
        fi
        echo "Volume à $(volume_dit)."
        ;;
    mute)
        # La réponse est lue après la coupure : seule la notification la montre.
        pamixer -m
        echo "Son coupé."
        ;;
    unmute)
        pamixer -u
        echo "Son remis, à $(volume_dit)."
        ;;
    set)
        phrase=${VOCAL_ASSISTANT_PHRASE:-}
        texte=${VOCAL_ASSISTANT_ARGUMENT:-${phrase##* à }}
        case $texte in
            *fond* | *maximum*) cible=100 ;;
            *)
                if ! cible=$("$NOMBRES" "$texte"); then
                    echo "Je n'ai pas compris le volume voulu."
                    exit 1
                fi
                ;;
        esac
        if [ "$cible" -gt "$LIMITE" ]; then
            echo "Le volume va de zéro à $LIMITE pour cent."
            exit 1
        fi
        pamixer -u
        pamixer --set-volume "$cible" --allow-boost
        echo "Volume à $(volume_dit)."
        ;;
    *)
        echo "volume.sh attend up, down, mute, unmute ou set."
        exit 1
        ;;
esac
