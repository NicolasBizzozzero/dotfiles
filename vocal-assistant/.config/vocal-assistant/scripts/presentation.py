#!/usr/bin/env python3
"""Répond à « qui es-tu » : toujours la même phrase, avec le système et le LLM.

« Je suis l'assistant vocal tournant sur Arch Linux, kernel 7.2.14-arch1-1,
basé sur le modèle qwen3.5:2b. » Les trois noms sont lus à chaque fois :

- le système dans /etc/os-release, le noyau avec uname ;
- le modèle dans la configuration que le service emploie, la copie adoptée par
  vocal-assistant apply. Changer de modèle change donc la réponse, sans rien
  toucher ici.

Le nom du modèle est écrit tel quel : « qwen3.5:2b », dit « 2b ».
"""

import os
import sys
from pathlib import Path

import yaml

CONFIG_ADOPTEE = Path.home() / ".local/share/vocal-assistant/actif/config.yaml"
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


def modele():
    try:
        config = yaml.safe_load(CONFIG_ADOPTEE.read_text(encoding="utf-8"))
        return config["llm"]["model"]
    except (OSError, KeyError, TypeError, yaml.YAMLError):
        return None


def main():
    phrase = f"Je suis l'assistant vocal tournant sur {systeme()}, kernel {os.uname().release}"
    nom = modele()
    print(f"{phrase}, basé sur le modèle {nom}." if nom else f"{phrase}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
