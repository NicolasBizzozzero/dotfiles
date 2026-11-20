#!/bin/bash
#
# Dit dans quelle ville se trouve l'ordinateur. La ville vient du module météo
# de Waybar : ton Wi-Fi s'il est connu, sinon ton adresse IP. La table des Wi-Fi
# connus est dans ~/.config/waybar/scripts/weather.sh.

if ! lieu=$(~/.config/waybar/scripts/weather.sh city); then
    echo "Je n'arrive pas à savoir où tu es."
    exit 1
fi
{
    read -r ville
    read -r source
} <<<"$lieu"

case $source in
    wifi) echo "Tu es à $ville." ;;
    ip) echo "D'après ton adresse internet, tu serais à $ville, mais ce n'est pas sûr." ;;
    # Ni Wi-Fi connu, ni réponse d'ipinfo.io : la ville par défaut ne dit rien.
    *)
        echo "Je n'arrive pas à savoir où tu es."
        exit 1
        ;;
esac
