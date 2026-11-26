#!/usr/bin/env python3
"""Répond à « qui es-tu » : toujours la même phrase, avec le système, le LLM et Vosk.

« Je suis l'assistant vocal tournant sur Arch Linux, kernel 7.2.14-arch1-1,
basé sur le modèle qwen3.5:2b. Je t'entends avec Vosk 0.3.45 et son modèle
vosk-model-small-fr-0.22. » Tout est lu à chaque fois :

- le système dans /etc/os-release, le noyau avec uname ;
- le LLM et le modèle de Vosk dans la configuration que le service emploie, la
  copie adoptée par vocal-assistant apply. En changer change donc la réponse,
  sans rien toucher ici ;
- la version de Vosk dans l'environnement Python du paquet vocal-assistant.

Le nom du modèle est écrit tel quel : « qwen3.5:2b », dit « 2b ».
"""

import os
import re
import sys
from pathlib import Path

import yaml

CONFIG_ADOPTEE = Path.home() / ".local/share/vocal-assistant/actif/config.yaml"
# Platypush y installe Vosk sous le nom platypush-vosk : vosk-0.3.45.dist-info
# ou platypush_vosk-0.3.45.post2.dist-info.
PAQUETS_PYTHON = Path("/usr/lib/vocal-assistant/venv/lib")
OS_RELEASE = Path("/etc/os-release")


def systeme():
    """« Arch Linux » : le NAME de /etc/os-release, sinon le nom du noyau (Linux)."""
    try:
        for ligne in OS_RELEASE.read_text(encoding="utf-8").splitlines():
            cle, _, valeur = ligne.partition("=")
            if cle == "NAME":
                return valeur.strip().strip('"')
    except OSError:
        pass
    return os.uname().sysname


def config_adoptee():
    try:
        return yaml.safe_load(CONFIG_ADOPTEE.read_text(encoding="utf-8")) or {}
    except (OSError, yaml.YAMLError):
        return {}


def version_de_vosk():
    """« 0.3.45 », lu dans le nom du dossier dist-info, ou None."""
    for dossier in PAQUETS_PYTHON.glob("python*/site-packages/*vosk-*.dist-info"):
        version = re.search(r"vosk-(\d+(?:\.\d+)*)", dossier.name)
        if version:
            return version.group(1)
    return None


def main():
    config = config_adoptee()
    llm = (config.get("llm") or {}).get("model")
    ecoute = (config.get("voice") or {}).get("recognition")

    phrase = f"Je suis l'assistant vocal tournant sur {systeme()}, kernel {os.uname().release}"
    phrase += f", basé sur le modèle {llm}." if llm else "."
    if ecoute:
        version = version_de_vosk()
        vosk = f"Vosk {version}" if version else "Vosk"
        phrase += f" Je t'entends avec {vosk} et son modèle {ecoute}."
    print(phrase)
    return 0


if __name__ == "__main__":
    sys.exit(main())
