#!/bin/bash
#
# Connecte ou déconnecte ton casque Bluetooth : casque.sh connect|disconnect
#
# L'adresse du casque est dans ~/.config/vocal-assistant/casque, une seule ligne
# comme 00:11:22:33:44:55, donnée par « bluetoothctl devices ». Ce fichier reste
# hors du dépôt public des dotfiles. Le casque doit déjà être appairé.
#
# Connecter allume d'abord le Bluetooth s'il est éteint, comme le clic droit sur
# son module de Waybar. Ce qui est déjà fait ne change rien, et le dit.
#
# Déconnecter bloque aussi le casque dans BlueZ (bluetoothctl block) : il se
# reconnecte de lui-même dans les trois secondes, et BlueZ l'accepte sans rien
# demander puisqu'il est de confiance (trusted). Bloqué, il est refusé, et le
# reste après un redémarrage. Connecter le débloque, comme le menu Bluetooth de
# Waybar. L'appairage, lui, est gardé.

FICHIER=~/.config/vocal-assistant/casque
BLUETOOTH=~/.config/waybar/scripts/bluetooth.sh

adresse=$(tr -d '[:space:]' 2>/dev/null <"$FICHIER")
if [[ ! $adresse =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
    # Lu à voix haute : le nom du fichier, pas son chemin.
    echo "Je ne connais pas ton casque : écris son adresse dans le fichier casque, à côté de config.yaml."
    exit 1
fi

# bluetoothctl attend sans fin bluetoothd quand il ne tourne pas.
allume() { timeout 5 bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }
connecte() { timeout 5 bluetoothctl info "$adresse" 2>/dev/null | grep -q "Connected: yes"; }
bloque() { timeout 5 bluetoothctl info "$adresse" 2>/dev/null | grep -q "Blocked: yes"; }

case ${1:-} in
    connect)
        if allume && connecte; then
            echo "Le casque est déjà connecté."
            exit 0
        fi
        if ! allume && ! "$BLUETOOTH" on; then
            echo "Je n'ai pas pu activer le Bluetooth."
            exit 1
        fi
        if bloque; then
            timeout 5 bluetoothctl unblock "$adresse" >/dev/null 2>&1
        fi
        # Un casque éteint ou hors de portée fait attendre bluetoothctl.
        timeout 20 bluetoothctl connect "$adresse" >/dev/null 2>&1
        if connecte; then
            echo "Casque connecté."
        else
            echo "Je n'ai pas pu connecter le casque. Est-il allumé ?"
            exit 1
        fi
        ;;
    disconnect)
        if ! allume || ! connecte; then
            echo "Le casque n'est pas connecté."
            exit 0
        fi
        # Bloqué d'abord : la reconnexion du casque arrive dès la déconnexion.
        timeout 5 bluetoothctl block "$adresse" >/dev/null 2>&1
        if connecte; then
            timeout 10 bluetoothctl disconnect "$adresse" >/dev/null 2>&1
        fi
        if connecte; then
            echo "Je n'ai pas pu déconnecter le casque."
            exit 1
        fi
        echo "Casque déconnecté."
        ;;
    *)
        echo "casque.sh attend connect ou disconnect."
        exit 1
        ;;
esac
