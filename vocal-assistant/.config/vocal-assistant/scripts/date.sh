#!/bin/bash
#
# Dit la date : « Nous sommes le lundi 16 novembre 2026. »
#
# Le premier du mois s'écrit « 1er », que Piper lit « premier ».

jour=$(date '+%-d')
if [ "$jour" -eq 1 ]; then
    jour="1er"
fi

echo "Nous sommes le $(LC_TIME=fr_FR.UTF-8 date '+%A') $jour $(LC_TIME=fr_FR.UTF-8 date '+%B %Y')."
