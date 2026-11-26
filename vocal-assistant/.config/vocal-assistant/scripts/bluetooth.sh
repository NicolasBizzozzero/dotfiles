#!/bin/bash
#
# Allume ou éteint le Bluetooth : bluetooth.sh on|off
#
# Comme le clic droit sur le module Bluetooth de Waybar
# (~/.config/waybar/scripts/bluetooth.sh) : l'état tient après un redémarrage.
# Ce qui est déjà fait ne change rien, et le dit.
#
# Éteint veut dire coupé et bloqué par rfkill : c'est le blocage qui tient après
# un redémarrage. Un Bluetooth coupé sans blocage, comme après un démarrage où
# BlueZ a échoué, est donc encore éteint pour de bon.

BLUETOOTH=~/.config/waybar/scripts/bluetooth.sh

# bluetoothctl attend sans fin bluetoothd quand il ne tourne pas.
allume() { timeout 5 bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }

bloque() {
    local appareil
    for appareil in /sys/class/rfkill/rfkill*; do
        [[ $(<"$appareil/type") == bluetooth && $(<"$appareil/soft") == 1 ]] && return 0
    done
    return 1
}

case ${1:-} in
    on)
        if allume; then
            echo "Le Bluetooth est déjà activé."
            exit 0
        fi
        fait="Bluetooth activé."
        rate="Je n'ai pas pu activer le Bluetooth."
        ;;
    off)
        if ! allume && bloque; then
            echo "Le Bluetooth est déjà désactivé."
            exit 0
        fi
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
