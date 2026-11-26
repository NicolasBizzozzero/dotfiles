#!/usr/bin/env python3
"""Tes réveils AlarmClock : les dire, ou en poser un à une heure dite.

Usage :
    reveils.py liste    dit les prochains réveils, et s'ils sont en pause
    reveils.py poser    pose un réveil à l'heure que dit $VOCAL_ASSISTANT_PHRASE

Heures comprises, en lettres comme les écrit Vosk : « sept heures », « sept
heures trente », « six heures et demie », « huit heures et quart », « huit
heures moins le quart », « midi », « minuit et demi ». « demain » est compris
aussi. Sans lui, le réveil sonne aujourd'hui si l'heure n'est pas passée,
demain sinon, comme alarm_clock at.

Aucune commande ne met les réveils en pause ni ne les coupe : c'est voulu, ça
se fait à la main.

La liste vient du service d'AlarmClock, par sa socket de contrôle : une ligne
JSON aller, une ligne retour, comme alarm_clock status. Les dates y sont
exactes, là où l'affichage de alarm_clock status est fait pour être lu.
"""

import json
import os
import socket
import subprocess
import sys
from datetime import datetime, timedelta

from minuteur import HEURES_EN_MOTS
from nombres import NombreIncompris, est_un_mot_de_nombre, mots, nombre

# Le nom que montrent alarm_clock list et alarm_clock status.
NOM_DU_REVEIL = "Réveil vocal"
# Les réveils dits, au plus.
DITS = 3
JOURS = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]
MOIS = [
    "janvier",
    "février",
    "mars",
    "avril",
    "mai",
    "juin",
    "juillet",
    "août",
    "septembre",
    "octobre",
    "novembre",
    "décembre",
]


class Incompris(ValueError):
    """La phrase ne dit pas d'heure valable. Le texte est lu à voix haute."""


# --- Dire une date ------------------------------------------------------------


def heure_dite(instant):
    """« 9 heures 30 », « midi », « une heure 5 » : écrit pour être lu par Piper."""
    heures = HEURES_EN_MOTS.get(instant.hour, f"{instant.hour} heures")
    return f"{heures} {instant.minute}" if instant.minute else heures


def quand(instant, aujourd_hui):
    """« demain à 9 heures 30 », « lundi à 9 heures », « le 3 décembre à 7 heures »."""
    ecart = (instant.date() - aujourd_hui).days
    if ecart == 0:
        jour = "aujourd'hui"
    elif ecart == 1:
        jour = "demain"
    elif 1 < ecart < 7:
        jour = JOURS[instant.weekday()]
    else:
        jour = f"le {instant.day} {MOIS[instant.month - 1]}"
    return f"{jour} à {heure_dite(instant)}"


# --- Lire une heure -----------------------------------------------------------


def _dans_un_nombre(liste, i):
    """liste[i] fait partie d'un nombre : un mot de nombre, ou le « et » de « vingt et une »."""
    if est_un_mot_de_nombre(liste[i]):
        return True
    return (
        liste[i] == "et"
        and 0 < i < len(liste) - 1
        and est_un_mot_de_nombre(liste[i - 1])
        and est_un_mot_de_nombre(liste[i + 1])
    )


def _nombre_avant(liste, fin):
    """Le nombre écrit juste avant liste[fin], et l'indice où il commence."""
    debut = fin
    while debut > 0 and _dans_un_nombre(liste, debut - 1):
        debut -= 1
    return nombre(liste[debut:fin]), debut


def _minutes_apres(liste, i):
    """Les minutes qui suivent « heures » : « trente », « et quart », « moins le quart »."""
    suite = liste[i : i + 3]
    if suite[:2] in (["et", "demie"], ["et", "demi"]):
        return 30
    if suite[:2] == ["et", "quart"]:
        return 15
    if suite[:3] == ["moins", "le", "quart"]:
        return -15
    signe = 1
    if suite[:1] == ["moins"]:
        signe, i = -1, i + 1
    fin = i
    while fin < len(liste) and _dans_un_nombre(liste, fin):
        fin += 1
    if fin == i:
        return 0
    return signe * nombre(liste[i:fin])


def comprendre(phrase):
    """(heures, minutes, demain) : l'heure que dit la phrase."""
    liste = mots(phrase)
    demain = "demain" in liste
    try:
        for i, mot in enumerate(liste):
            if mot in ("midi", "minuit"):
                heures, apres = (12 if mot == "midi" else 0), i + 1
                break
            if mot in ("heure", "heures", "h"):
                heures, _ = _nombre_avant(liste, i)
                apres = i + 1
                break
        else:
            raise Incompris("Je n'ai pas compris l'heure du réveil.")
        minutes = _minutes_apres(liste, apres)
    except NombreIncompris:
        raise Incompris("Je n'ai pas compris l'heure du réveil.") from None
    if minutes < 0:
        heures, minutes = (heures - 1) % 24, 60 + minutes
    if not (0 <= heures <= 23 and 0 <= minutes <= 59):
        raise Incompris("Cette heure n'existe pas.")
    return heures, minutes, demain


def instant_du_reveil(heures, minutes, demain, maintenant):
    """Demain si c'est dit, sinon aujourd'hui si l'heure n'est pas passée, demain sinon."""
    jour = maintenant + timedelta(days=1) if demain else maintenant
    instant = jour.replace(hour=heures, minute=minutes, second=0, microsecond=0)
    return instant if demain or instant > maintenant else instant + timedelta(days=1)


# --- AlarmClock ---------------------------------------------------------------


class SansService(RuntimeError):
    """Le service d'AlarmClock ne répond pas."""


def demander(commande):
    """Une commande au service d'AlarmClock, par sa socket. Renvoie data."""
    dossier = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    chemin = os.environ.get("ALARM_CLOCK_SOCKET", f"{dossier}/alarm_clock.sock")
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.settimeout(5)
            client.connect(chemin)
            client.sendall(
                (json.dumps({"command": commande, "args": {}}) + "\n").encode()
            )
            recu = b""
            while not recu.endswith(b"\n"):
                morceau = client.recv(4096)
                if not morceau:
                    break
                recu += morceau
    except OSError:
        raise SansService from None
    reponse = json.loads(recu)
    if not reponse.get("ok"):
        raise SansService
    return reponse.get("data", {})


def liste(maintenant):
    data = demander("status")
    prochains = [
        (datetime.fromisoformat(r["next"]).astimezone().replace(tzinfo=None), r["name"])
        for r in [*data.get("alarms", []), *data.get("one_time", [])]
        if r.get("next")
    ]
    prochains.sort()
    phrases = []
    if data.get("paused_until"):
        fin = (
            datetime.fromisoformat(data["paused_until"])
            .astimezone()
            .replace(tzinfo=None)
        )
        phrases.append(
            f"Tes réveils sont en pause jusqu'à {quand(fin, maintenant.date())}."
        )
    if not prochains:
        phrases.append("Aucun réveil n'est prévu.")
    for rang, (instant, nom) in enumerate(prochains[:DITS]):
        debut = "Prochain réveil" if rang == 0 else "Puis"
        phrases.append(f"{debut} {quand(instant, maintenant.date())}, {nom}.")
    return " ".join(phrases)


def poser(phrase, maintenant):
    heures, minutes, demain = comprendre(phrase)
    instant = instant_du_reveil(heures, minutes, demain, maintenant)
    resultat = subprocess.run(
        [
            "alarm_clock",
            "at",
            "--name",
            NOM_DU_REVEIL,
            instant.strftime("%Y-%m-%d %H:%M"),
        ],
        capture_output=True,
        text=True,
        timeout=10,
    )
    if resultat.returncode:
        print(resultat.stderr.strip(), file=sys.stderr)
        return "AlarmClock n'a pas pu poser le réveil.", 1
    return f"Réveil mis pour {quand(instant, maintenant.date())}.", 0


def main(arguments):
    maintenant = datetime.now()
    try:
        if arguments == ["liste"]:
            print(liste(maintenant))
            return 0
        if arguments == ["poser"]:
            # La phrase entière : « demain » peut être hors de la partie variable.
            phrase = os.environ.get("VOCAL_ASSISTANT_PHRASE") or os.environ.get(
                "VOCAL_ASSISTANT_ARGUMENT", ""
            )
            texte, code = poser(phrase, maintenant)
            print(texte)
            return code
    except Incompris as erreur:
        print(erreur)
        return 1
    except SansService:
        print("Le service d'AlarmClock ne répond pas.")
        return 1
    print("reveils.py attend liste ou poser.")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
