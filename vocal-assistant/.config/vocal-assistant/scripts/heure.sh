#!/bin/bash
#
# Dit l'heure : « Il est 21 heures 5. »
#
# L'heure est écrite comme elle se dit : Piper lirait « 21 h 05 » « vingt et
# un ache zéro cinq », et « 1 heure » « un heure ».

read -r heure minutes < <(date '+%-H %-M')

case "$heure" in
    0) texte="minuit" ;;
    1) texte="une heure" ;;
    12) texte="midi" ;;
    21) texte="vingt et une heures" ;;
    *) texte="$heure heures" ;;
esac
if [ "$minutes" -ne 0 ]; then
    texte="$texte $minutes"
fi

echo "Il est $texte."
