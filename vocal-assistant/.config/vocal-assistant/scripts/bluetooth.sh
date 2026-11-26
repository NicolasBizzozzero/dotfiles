#!/bin/bash
#
# Allume ou éteint le Bluetooth : bluetooth.sh on|off
#
# Comme le clic droit sur le module Bluetooth de Waybar
# (~/.config/waybar/scripts/bluetooth.sh) : l'état tient après un redémarrage.

BLUETOOTH=~/.config/waybar/scripts/bluetooth.sh

case ${1:-} in
    on)
        fait="Bluetooth activé."
        rate="Je n'ai pas pu activer le Bluetooth."
        ;;
    off)
        fait="Bluetooth désactivé."
        rate="Je n'ai pas pu désactiver le Bluetooth."
        ;;
    *)
        echo "bluetooth.sh attend on ou off."
        exit 1
        ;;
esac

if "$BLUETOOTH" "$1"; then
    echo "$fait"
else
    echo "$rate"
    exit 1
fi
