#!/bin/bash
#
# Change ou dit le volume de la sortie son : volume.sh up|down|mute|unmute|set|get
#
# Mêmes règles que les touches de volume (~/.config/waybar/scripts/pulseaudio.sh) :
# pamixer, 150 % au plus, et monter ou baisser le son quand il est coupé le
# remet d'abord. Le pas est plus grand qu'au clavier : une phrase vaut deux appuis.
#
# Ce qui est déjà fait ne change rien, et le dit : mute sur un son coupé, unmute
# sur un son qui ne l'est pas, up au maximum, down à zéro.
#
# set règle le volume au nombre dit : « mets le volume à cinquante ». Il le lit
# dans $VOCAL_ASSISTANT_ARGUMENT, ou après le dernier « à » de la phrase quand
# c'est le LLM qui a choisi la commande. « à fond » vaut 100 %.
#
# Quand le son est coupé, la voix de l'assistant l'est aussi : la réponse ne se
# voit alors que dans la notification.

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
        volume=$(pamixer --get-volume)
        if [ "$1" = "up" ]; then
            if [ "$volume" -ge "$LIMITE" ]; then
                echo "Le volume est déjà au maximum, à $LIMITE pour cent."
                exit 0
            fi
            pamixer -i "$PAS" --allow-boost --set-limit "$LIMITE"
        else
            if [ "$volume" -le 0 ]; then
                echo "Le volume est déjà au minimum."
                exit 0
            fi
            pamixer -d "$PAS"
        fi
        echo "Volume à $(volume_dit)."
        ;;
    mute)
        if [ "$coupe" = "true" ]; then
            echo "Le son est déjà coupé."
            exit 0
        fi
        pamixer -m
        echo "Son coupé."
        ;;
    unmute)
        if [ "$coupe" != "true" ]; then
            echo "Le son est déjà activé."
            exit 0
        fi
        pamixer -u
        echo "Son remis, à $(volume_dit)."
        ;;
    get)
        if [ "$coupe" = "true" ]; then
            echo "Le son est coupé. Le volume est réglé à $(volume_dit)."
        else
            echo "Le volume est à $(volume_dit)."
        fi
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
        echo "volume.sh attend up, down, mute, unmute, set ou get."
        exit 1
        ;;
esac
