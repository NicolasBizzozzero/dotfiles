#!/usr/bin/env python3
"""Lit un nombre dit à voix haute, et écrit une durée en lettres.

Vosk écrit les nombres en lettres. Ce module sert à minuteur.py, qui l'importe,
et à volume.sh et now-playing.sh, qui le lancent :

    nombres.py "soixante quinze pour cent"    # affiche 75
    nombres.py --duree 4980                   # affiche « une heure vingt-trois minutes »

Il comprend les chiffres, et les nombres en lettres de zéro à neuf cent
quatre-vingt-dix-neuf, avec ou sans tirets. « pour cent » est ignoré. Le code
de sortie vaut 1 si le texte n'est pas un nombre.

Une durée s'écrit en lettres pour le LLM : qwen3.5:2b recopie fidèlement
« vingt et une minutes », mais transforme « 21 minutes » en « vingt-one ».
"""

import re
import sys

NOMBRES = {
    "zéro": 0,
    "un": 1,
    "une": 1,
    "deux": 2,
    "trois": 3,
    "quatre": 4,
    "cinq": 5,
    "six": 6,
    "sept": 7,
    "huit": 8,
    "neuf": 9,
    "dix": 10,
    # Vosk écrit parfois « dit secondes » pour « dix secondes ».
    "dit": 10,
    "onze": 11,
    "douze": 12,
    "treize": 13,
    "quatorze": 14,
    "quinze": 15,
    "seize": 16,
    "vingt": 20,
    "trente": 30,
    "quarante": 40,
    "cinquante": 50,
    "soixante": 60,
}


class NombreIncompris(ValueError):
    pass


# Pour écrire en lettres : de zéro à seize, puis les dizaines.
EN_LETTRES = [
    mot for mot, valeur in NOMBRES.items() if valeur <= 16 and mot not in ("une", "dit")
]
DIZAINES = {20: "vingt", 30: "trente", 40: "quarante", 50: "cinquante", 60: "soixante"}


def en_lettres(n, feminin=False):
    """21 donne « vingt et un », ou « vingt et une » au féminin, devant
    « minutes ». De 0 à 99 ; au-delà, le nombre reste en chiffres."""
    if not 0 <= n <= 99:
        return str(n)
    if n <= 16:
        texte = EN_LETTRES[n]
    elif n < 20:
        texte = f"dix-{EN_LETTRES[n - 10]}"
    elif n >= 80:
        reste = n - 80
        texte = "quatre-vingts" if not reste else f"quatre-vingt-{en_lettres(reste)}"
    else:
        # Au-delà de soixante, on compte par vingt : soixante-dix, soixante et onze.
        dizaine = min(n // 10 * 10, 60)
        reste = n - dizaine
        if not reste:
            texte = DIZAINES[dizaine]
        elif reste in (1, 11):
            texte = f"{DIZAINES[dizaine]} et {en_lettres(reste)}"
        else:
            texte = f"{DIZAINES[dizaine]}-{en_lettres(reste)}"
    if feminin and texte.endswith("un"):
        texte += "e"
    return texte


def duree_en_lettres(secondes):
    """4980 donne « une heure vingt-trois minutes ». Les secondes ne sont dites
    que pour une durée de moins d'une heure."""
    heures, reste = divmod(int(secondes), 3600)
    minutes, secondes = divmod(reste, 60)
    parties = []
    for nombre_d_unites, unite in ((heures, "heure"), (minutes, "minute")):
        if nombre_d_unites:
            pluriel = "s" if nombre_d_unites > 1 else ""
            parties.append(f"{en_lettres(nombre_d_unites, True)} {unite}{pluriel}")
    if not heures and (secondes or not parties):
        pluriel = "s" if secondes > 1 else ""
        parties.append(f"{en_lettres(secondes, True)} seconde{pluriel}")
    return " ".join(parties)


def mots(texte):
    """Les mots du texte, en minuscules : « Quatre-vingt-dix » donne quatre, vingt, dix."""
    return re.findall(r"\w+", texte.lower())


def est_un_mot_de_nombre(mot):
    singulier = mot.removesuffix("s")
    return mot.isdigit() or mot in NOMBRES or singulier in ("vingt", "cent")


def nombre(liste):
    """« vingt cinq » donne 25, « quatre vingt dix » 90, « cent vingt » 120.

    Les nombres français s'additionnent mot à mot, sauf deux cas : « quatre
    vingt » multiplie, et « cent » multiplie ce qui le précède. « et », comme
    dans « vingt et un », est ignoré.
    """
    liste = [mot for mot in liste if mot != "et"]
    if not liste:
        raise NombreIncompris("aucun nombre")
    total, precedent = 0, None
    for mot in liste:
        singulier = mot.removesuffix("s")
        if mot.isdigit():
            total += int(mot)
        elif singulier == "vingt" and precedent == "quatre":
            total += 80 - 4
        elif singulier == "cent":
            total = max(total, 1) * 100
        elif mot in NOMBRES:
            total += NOMBRES[mot]
        else:
            raise NombreIncompris(mot)
        precedent = mot
    return total


def main(arguments):
    if arguments[:1] == ["--duree"] and len(arguments) == 2:
        if not arguments[1].isdigit():
            return 1
        print(duree_en_lettres(int(arguments[1])))
        return 0
    texte = re.sub(r"\bpour\s*cent\b|%", " ", " ".join(arguments).lower())
    try:
        print(nombre(mots(texte)))
    except NombreIncompris:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
