#!/usr/bin/env python3
"""Répond à « qui es-tu » : toujours la même phrase, avec le nom du LLM.

Le nom vient de la configuration que le service emploie, la copie adoptée par
vocal-assistant apply : changer de modèle change donc la réponse, sans rien
toucher ici.

Le nom s'écrit pour être lu par Piper : « qwen3.5:2b » devient « Qwen 3 point
5, en version 2 milliards de paramètres ».
"""

import re
import sys
from pathlib import Path

import yaml

CONFIG_ADOPTEE = Path.home() / ".local/share/vocal-assistant/actif/config.yaml"


def nom_dit(modele):
    """« qwen3.5:2b » → « Qwen 3 point 5, en version 2 milliards de paramètres »."""
    nom, _, version = modele.partition(":")
    # « qwen3.5 » → « qwen 3.5 », « llama3.2 » → « llama 3.2 »
    nom = re.sub(r"(?<=[a-zA-Z])(?=\d)", " ", nom)
    nom = re.sub(r"(\d)\.(\d)", r"\1 point \2", nom)
    nom = nom[:1].upper() + nom[1:]
    taille = re.fullmatch(r"(\d+(?:\.\d+)?)b", version)
    if taille:
        milliards = taille.group(1).replace(".", ",")
        pluriel = "s" if float(taille.group(1)) >= 2 else ""
        return f"{nom}, en version {milliards} milliard{pluriel} de paramètres"
    if version and version != "latest":
        return f"{nom}, en version {version}"
    return nom


def main():
    try:
        modele = yaml.safe_load(CONFIG_ADOPTEE.read_text(encoding="utf-8"))["llm"][
            "model"
        ]
    except (OSError, KeyError, TypeError, yaml.YAMLError):
        modele = None
    phrase = (
        "Je suis ton assistant vocal. Tout tourne sur ton ordinateur, sans internet."
    )
    if modele:
        phrase += f" Mon modèle de langage est {nom_dit(modele)}."
    print(phrase)
    return 0


if __name__ == "__main__":
    sys.exit(main())
