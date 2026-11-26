#!/bin/bash
#
# Dit la température du processeur, et si elle est normale : temperature.sh
#
# La valeur vient de coretemp (« Package id 0 », tout le processeur), lue dans
# /sys sans lm_sensors. La carte graphique n'est pas lue : nvidia-smi la
# réveillerait pour rien quand elle dort.
#
# Les seuils sont ceux de cette machine : ventilateurs arrêtés sous 60 °C, une
# rafale sur tous les cœurs reste vers 72 °C, et l'i7-12700H ralentit seul à
# 100 °C.

for capteur in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$capteur/name" 2>/dev/null)" = coretemp ] || continue
    for etiquette in "$capteur"/temp*_label; do
        if [ "$(cat "$etiquette")" = "Package id 0" ]; then
            milli=$(cat "${etiquette%_label}_input")
        fi
    done
done

if [ -z "${milli:-}" ]; then
    echo "Je ne trouve pas la température du processeur."
    exit 1
fi

degres=$(((milli + 500) / 1000))
if [ "$degres" -lt 75 ]; then
    avis="c'est normal."
elif [ "$degres" -lt 90 ]; then
    avis="il chauffe, sans danger."
else
    avis="il est très chaud, près de sa limite."
fi
echo "Le processeur est à $degres degrés : $avis"
