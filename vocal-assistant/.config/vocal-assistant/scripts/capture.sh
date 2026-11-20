#!/bin/bash
#
# Enregistre une capture de tout l'écran dans ~/pictures/screenshots.
#
# Le script tourne avant que l'assistant n'affiche la notification de la
# phrase : elle n'apparaît donc pas sur la capture.

dossier="$(xdg-user-dir PICTURES)/screenshots"
mkdir -p "$dossier"
fichier="$dossier/capture_$(date '+%Y-%m-%d_%H-%M-%S').png"

if ! grim "$fichier" 2>/dev/null; then
    echo "La capture d'écran a échoué."
    exit 1
fi
echo "Capture d'écran enregistrée."
