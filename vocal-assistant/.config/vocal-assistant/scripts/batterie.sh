#!/bin/bash
#
# Dit le niveau de la batterie, si elle charge, et le temps qui lui reste.
#
# Le niveau et l'état viennent du noyau (/sys/class/power_supply). Le temps
# restant vient d'upower, qui l'estime d'après la consommation récente : il
# manque juste après un branchement ou un débranchement.

batterie=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
if [ -z "$batterie" ]; then
    echo "Je ne trouve pas de batterie."
    exit 1
fi
niveau=$(cat "$batterie/capacity")
etat=$(cat "$batterie/status")

# upower écrit « time to empty: 3.2 hours » ou « 45.0 minutes ».
temps_restant() {
    LC_ALL=C upower -i "/org/freedesktop/UPower/devices/battery_$(basename "$batterie")" |
        awk -v cle="$1" '$0 ~ cle {
            minutes = ($NF ~ /^hour/) ? $(NF - 1) * 60 : $(NF - 1)
            minutes = int(minutes + 0.5)
            if (minutes < 60) { print minutes " minutes"; exit }
            heures = int(minutes / 60); reste = minutes % 60
            texte = (heures == 1) ? "une heure" : heures " heures"
            if (reste > 0) texte = texte " " reste
            print texte
        }'
}

case $etat in
    Full)
        echo "La batterie est pleine."
        ;;
    Charging)
        reste=$(temps_restant "time to full")
        echo "La batterie est à $niveau pour cent, et charge${reste:+ : pleine dans $reste}."
        ;;
    Discharging)
        reste=$(temps_restant "time to empty")
        echo "La batterie est à $niveau pour cent${reste:+, il reste environ $reste}."
        ;;
    "Not charging")
        # Sur secteur, mais sous le seuil de charge réglé (TUXEDO Control Center).
        echo "La batterie est à $niveau pour cent, sur secteur, sans charger."
        ;;
    *)
        echo "La batterie est à $niveau pour cent."
        ;;
esac
