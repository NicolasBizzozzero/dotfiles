#!/usr/bin/env python3
"""Dit la météo d'après wttr.in : maintenant, demain ou après-demain, ici ou ailleurs.

Le script lit la phrase entendue, dans $VOCAL_ASSISTANT_PHRASE :

- « quel temps fait-il » : maintenant, là où tu es ;
- « quel temps fera-t-il demain » : demain, là où tu es ;
- « quelle est la météo à Lyon », « météo d'après-demain à Boulogne-sur-Mer ».

La ville est ce qui suit le premier « à », « au », « dans », « sur » ou « pour »,
sans les mots de temps comme « demain ». wttr.in la cherche telle qu'elle a été
entendue. Sans ville, c'est celle du module météo de Waybar :
~/.config/waybar/scripts/weather.sh city.

Seules la ville et la langue partent à wttr.in.
"""

import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

WEATHER = Path.home() / ".config/waybar/scripts/weather.sh"
DELAI = 10

# (motif, jour) : 0 pour aujourd'hui, 1 pour demain, 2 pour après-demain.
# Après-demain d'abord : il contient « demain ».
JOURS = [(r"apr[eè]s[- ]demain", 2), (r"demain", 1)]
NOMS_DES_JOURS = {1: "Demain", 2: "Après-demain"}
# Retirés avant de chercher la ville : « à Lyon demain matin » donne « Lyon ».
MOTS_DE_TEMPS = re.compile(
    r"(?<!\w)(?:apr[eè]s[- ]demain|demain|aujourd'hui|maintenant|en ce moment"
    r"|cet? (?:matin|soir|après-midi|week-end)|matin|soir|après-midi)(?!\w)"
)
VILLE = re.compile(r"(?<!\w)(à|au|aux|dans|sur|pour)\s+(?:la ville de\s+)?(.+)$")
# « au Mans » se dit pour « le Mans ».
ARTICLES = {"au": "le ", "aux": "les "}
# Laissés en minuscules au milieu d'un nom : « Boulogne-sur-Mer ».
PETITS_MOTS = {"sur", "sous", "en", "le", "la", "les", "de", "du", "des", "lès"}
# Au-delà, le risque de pluie est dit.
PLUIE_A_DIRE = 40


class Erreur(Exception):
    """Un problème à dire à voix haute."""


def jour_demande(phrase):
    texte = phrase.lower()
    for motif, jour in JOURS:
        if re.search(rf"(?<!\w){motif}(?!\w)", texte):
            return jour
    return 0


def ville_demandee(phrase):
    """La ville dite dans la phrase, en minuscules, ou None."""
    texte = MOTS_DE_TEMPS.sub(" ", phrase.lower())
    texte = " ".join(texte.split()).strip(" ?!.,")
    trouve = VILLE.search(texte)
    if not trouve:
        return None
    preposition, ville = trouve.groups()
    ville = ville.strip(" ?!.,")
    return ARTICLES.get(preposition, "") + ville if ville else None


def nom_affiche(ville):
    """« boulogne sur mer » donne « Boulogne sur Mer », « saint-étienne » « Saint-Étienne »."""
    mots = re.split(r"([ -])", ville)
    return "".join(
        mot if (i and mot in PETITS_MOTS) else mot[:1].upper() + mot[1:]
        for i, mot in enumerate(mots)
    )


def ville_d_ici():
    try:
        sortie = subprocess.run(
            [str(WEATHER), "city"], capture_output=True, text=True, timeout=15
        )
    except (OSError, subprocess.TimeoutExpired):
        sortie = None
    if sortie is None or sortie.returncode or not sortie.stdout.strip():
        raise Erreur("Je n'arrive pas à savoir où tu es.")
    # La première ligne est la ville, la seconde dit comment elle a été trouvée.
    return sortie.stdout.splitlines()[0]


def previsions(ville):
    adresse = f"https://wttr.in/{urllib.parse.quote(ville)}?format=j1&lang=fr"
    requete = urllib.request.Request(adresse, headers={"User-Agent": "vocal-assistant"})
    try:
        with urllib.request.urlopen(requete, timeout=DELAI) as reponse:
            return json.load(reponse)
    except urllib.error.HTTPError as erreur:
        # wttr.in répond « location not found » avec le code 500.
        if b"not found" in erreur.read():
            raise Erreur(f"Je ne trouve pas la ville {ville}.") from None
        raise Erreur("Le service météo ne répond pas.") from None
    except (OSError, ValueError):
        raise Erreur("Le service météo ne répond pas.") from None


def degres(valeur):
    """Piper ignore le signe moins : « -3 » s'écrit « moins 3 »."""
    nombre = int(valeur)
    return f"moins {-nombre}" if nombre < 0 else str(nombre)


def description(meteo):
    """« Averses légères » donne « averses légères »."""
    texte = meteo["lang_fr"][0]["value"].strip()
    return texte[:1].lower() + texte[1:]


def dire(donnees, jour, lieu):
    if jour == 0:
        actuelle = donnees["current_condition"][0]
        return (
            f"À {lieu} : {description(actuelle)}, {degres(actuelle['temp_C'])} degrés."
        )
    prevue = donnees["weather"][jour]
    # La description de midi résume la journée.
    midi = next(h for h in prevue["hourly"] if h["time"] == "1200")
    texte = (
        f"{NOMS_DES_JOURS[jour]} à {lieu} : {description(midi)}, "
        f"de {degres(prevue['mintempC'])} à {degres(prevue['maxtempC'])} degrés."
    )
    pluie = max(int(h["chanceofrain"]) for h in prevue["hourly"])
    if pluie >= PLUIE_A_DIRE:
        texte += f" Risque de pluie : {pluie} pour cent."
    return texte


def main():
    phrase = os.environ.get("VOCAL_ASSISTANT_PHRASE", "")
    jour = jour_demande(phrase)
    try:
        ville = ville_demandee(phrase)
        lieu = nom_affiche(ville) if ville else ville_d_ici()
        donnees = previsions(ville or lieu)
        if ville:
            pays = donnees["nearest_area"][0]["country"][0]["value"]
            # Une ville mal entendue peut être trouvée à l'autre bout du monde.
            if pays != "France":
                lieu = f"{lieu}, {pays}"
        print(dire(donnees, jour, lieu))
    except Erreur as erreur:
        print(erreur)
        return 1
    except (KeyError, IndexError, StopIteration, TypeError, ValueError):
        print("Le service météo a répondu dans un format inattendu.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
