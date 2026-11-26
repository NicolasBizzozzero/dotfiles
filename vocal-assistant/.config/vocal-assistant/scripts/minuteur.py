#!/usr/bin/env python3
"""Minuteurs, alarmes et rappels, qui sonnent avec AlarmClock.

Usage :
    minuteur.py                  lance ce que demande $VOCAL_ASSISTANT_PHRASE
    minuteur.py annuler          annule les minuteurs, alarmes et rappels en attente
    minuteur.py arreter          arrête la sonnerie en cours
    minuteur.py sonner TITRE TEXTE
                                 ce que lance le timer à l'heure dite

Phrases comprises, avec les nombres en lettres comme les écrit Vosk :

- « minuteur de vingt-cinq minutes », « mets une alarme d'une heure et demie »
- « mets un minuteur de deux heures, dix minutes et trente secondes »
- « minuteur de deux minutes trente », « minuteur de cinq » (des minutes)
- « rappelle-moi dans dix minutes de sortir le linge »
- « rappelle-moi d'appeler maman dans un quart d'heure »

Comment ça marche :

1. Le script calcule l'heure de fin, et crée un timer systemd pour cette
   heure-là. Un timer compté en durée prendrait du retard pendant une mise en
   veille, car l'horloge qui le compte s'arrête avec la machine. Un timer à
   heure fixe sonne dès le réveil si son heure est passée.
2. À l'heure dite, le timer relance ce script avec « sonner » : une
   notification reste affichée, et AlarmClock sonne (alarm_clock ring), avec
   ses sons, son volume et sa montée progressive.
3. Fermer la notification arrête la sonnerie. Sinon, elle s'arrête d'elle-même
   au bout de DUREE_DE_SONNERIE secondes.

Pourquoi alarm_clock ring, et pas alarm_clock in : une pause d'AlarmClock
(alarm_clock pause) fait taire ses alarmes, y compris celles posées avec
« in ». ring, lui, sonne même en pause. Un rappel demandé à voix haute sonne
donc, même quand les réveils sont en pause.

Le timer survit à un redémarrage de l'assistant, pas à celui de l'ordinateur.
Voir ceux en attente : systemctl --user list-timers 'minuteur-*'
"""

import os
import re
import signal
import subprocess
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

from nombres import NombreIncompris, est_un_mot_de_nombre, mots, nombre

# Les timers s'appellent minuteur-… : annuler les retrouve par ce préfixe.
PREFIXE = "minuteur-"
DUREE_MAXIMALE = 24 * 3600
# Au-delà, la sonnerie s'arrête seule. La notification, elle, reste affichée.
DUREE_DE_SONNERIE = 60
# Code de sortie d'alarm_clock quand son service ne tourne pas.
SANS_SERVICE = 3
# Code de sortie d'argparse pour une option inconnue.
OPTION_REFUSEE = 2
# Sans AlarmClock, ce son sonne trois fois.
ALARME = "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"

# Secondes par unité, de la plus grande à la plus petite.
UNITES = {"heure": 3600, "minute": 60, "seconde": 1}
FRACTIONS = {"demi": 0.5, "demie": 0.5, "quart": 0.25, "quarts": 0.25}
# Les mots qui commandent : la durée et le message se cherchent après eux.
DECLENCHEURS = {"minuteur": "minuteur", "alarme": "alarme", "rappel": "rappel"}
# Les mots qui relient la commande, la durée et le message : « dans dix
# minutes de sortir le linge ».
LIENS = {"dans", "de", "d", "pendant", "pour", "que", "qu", "à"}
POLITESSES = ("s il te plaît", "s il te plait", "s il vous plaît", "stp", "merci")

# Devant heure, minute ou seconde, un nombre qui finit par « un » se dit « une ».
FEMININS = {
    1: "une",
    21: "vingt et une",
    31: "trente et une",
    41: "quarante et une",
    51: "cinquante et une",
}
# Les heures que Piper lirait mal en chiffres : « 1 heure » donnerait « un heure ».
HEURES_EN_MOTS = {0: "minuit", 1: "une heure", 12: "midi", 21: "vingt et une heures"}


class Incompris(ValueError):
    """La phrase ne dit pas de durée valable. Le texte est lu à voix haute."""


# --- Lire la phrase -----------------------------------------------------------


def unite(mot):
    """« minutes » donne « minute ». None si le mot n'est pas une unité."""
    singulier = mot.removesuffix("s")
    return singulier if singulier in UNITES else None


def est_de_la_duree(liste, i):
    """Vrai si le mot n° i fait partie d'une durée, comme « vingt » ou « minutes »."""
    mot = liste[i]
    if est_un_mot_de_nombre(mot) or unite(mot) or mot in FRACTIONS or mot == "et":
        return True
    # Le « d' » de « un quart d'heure ».
    return (
        mot == "d"
        and 0 < i < len(liste) - 1
        and liste[i - 1] in ("quart", "quarts")
        and unite(liste[i + 1]) == "heure"
    )


def quantite(liste):
    """« deux » donne 2, « une demi » 0.5, « trois quarts » 0.75."""
    fractions = [mot for mot in liste if mot in FRACTIONS]
    if not fractions:
        return nombre(liste)
    devant = [mot for mot in liste if mot not in FRACTIONS and mot != "et"]
    if len(fractions) > 1 or liste[-1] not in FRACTIONS:
        raise NombreIncompris(" ".join(liste))
    return (nombre(devant) if devant else 1) * FRACTIONS[fractions[0]]


def duree(liste):
    """La durée en secondes de mots comme « deux heures dix et trente secondes »."""
    liste = [mot for mot in liste if mot not in ("et", "d")]
    total, en_attente, derniere = 0, [], None
    for mot in liste:
        nom = unite(mot)
        if nom is None:
            en_attente.append(mot)
            continue
        total += (quantite(en_attente) if en_attente else 1) * UNITES[nom]
        en_attente, derniere = [], nom
    if en_attente:
        total += _reste(en_attente, derniere)
    return round(total)


def _reste(liste, derniere):
    """Les mots après la dernière unité : « et demie », ou « deux minutes trente »."""
    if derniere is None:
        # « minuteur de cinq » : sans unité, ce sont des minutes.
        return quantite(liste) * UNITES["minute"]
    if all(mot in FRACTIONS for mot in liste):
        return UNITES[derniere] * FRACTIONS[liste[-1]]
    plus_petites = [nom for nom, taille in UNITES.items() if taille < UNITES[derniere]]
    if not plus_petites:
        raise NombreIncompris(" ".join(liste))
    return nombre(liste) * UNITES[plus_petites[0]]


def morceaux_de_duree(liste, debut):
    """Les suites de mots de durée, à partir du mot n° debut : [(premier, fin), …]."""
    morceaux, i = [], debut
    while i < len(liste):
        if not est_de_la_duree(liste, i):
            i += 1
            continue
        fin = i
        while fin < len(liste) and est_de_la_duree(liste, fin):
            fin += 1
        # Un « et » au bord relie la durée au reste, il n'en fait pas partie.
        premier, dernier = i, fin
        while premier < dernier and liste[premier] == "et":
            premier += 1
        while dernier > premier and liste[dernier - 1] == "et":
            dernier -= 1
        if premier < dernier:
            morceaux.append((premier, dernier))
        i = fin
    return morceaux


def comprendre(phrase):
    """(sorte, secondes, message) : ce que demande la phrase.

    sorte vaut minuteur, alarme ou rappel. message est ce qu'il faut rappeler,
    tel qu'il a été dit, ou "" : seul un rappel en a un.
    """
    trouves = list(re.finditer(r"\w+", phrase))
    liste = [trouve.group().lower() for trouve in trouves]
    sorte, debut = "minuteur", 0
    for i, mot in enumerate(liste):
        if mot.startswith("rappel"):
            sorte = "rappel"
            # « rappelle-moi » : le pronom n'est pas le message.
            debut = i + 2 if liste[i + 1 : i + 2] in (["moi"], ["nous"]) else i + 1
            break
        if mot in DECLENCHEURS:
            sorte, debut = DECLENCHEURS[mot], i + 1
            break

    morceaux = morceaux_de_duree(liste, debut)
    avec_unite = [m for m in morceaux if any(unite(mot) for mot in liste[m[0] : m[1]])]
    if avec_unite:
        premier, fin = avec_unite[0]
    elif morceaux and sorte != "rappel":
        premier, fin = morceaux[-1]
    else:
        raise Incompris("Je n'ai pas compris la durée.")
    try:
        secondes = duree(liste[premier:fin])
    except NombreIncompris:
        raise Incompris("Je n'ai pas compris la durée.") from None

    message = ""
    if sorte == "rappel":
        # Le message est avant ou après la durée, sans les mots qui les relient.
        avant = list(range(debut, premier))
        while avant and liste[avant[-1]] in LIENS:
            avant.pop()
        apres = list(range(fin, len(liste)))
        indices = avant or apres
        while indices and liste[indices[0]] in LIENS:
            indices.pop(0)
        if indices:
            message = phrase[trouves[indices[0]].start() : trouves[indices[-1]].end()]
            message = _sans_politesse(message)
    return sorte, secondes, message


def _sans_politesse(message):
    simple = " ".join(mots(message))
    for politesse in POLITESSES:
        if simple.endswith(politesse):
            mots_a_retirer = len(politesse.split())
            debut_politesse = list(re.finditer(r"\w+", message))[-mots_a_retirer]
            return message[: debut_politesse.start()].rstrip(" ,")
    return message


# --- Le dire --------------------------------------------------------------------


def duree_dite(secondes):
    """3630 donne « une heure et 30 secondes », écrit pour être lu par Piper."""
    parties = []
    for nom, taille in UNITES.items():
        nombre_d_unites, secondes = divmod(secondes, taille)
        if nombre_d_unites:
            pluriel = "s" if nombre_d_unites > 1 else ""
            parties.append(
                f"{FEMININS.get(nombre_d_unites, nombre_d_unites)} {nom}{pluriel}"
            )
    if len(parties) == 1:
        return parties[0]
    return ", ".join(parties[:-1]) + " et " + parties[-1]


def de(texte):
    """« de 25 minutes », mais « d'une heure » et « d'appeler maman »."""
    return f"d'{texte}" if texte[:1].lower() in "aeiouyéèêàâîôûœ" else f"de {texte}"


def heure_dite(instant, maintenant):
    """« à 20 heures 45 », « demain à midi » : l'heure de fin, comme elle se dit."""
    heures = HEURES_EN_MOTS.get(instant.hour, f"{instant.hour} heures")
    texte = f"{heures} {instant.minute}" if instant.minute else heures
    jour = "demain " if instant.date() != maintenant.date() else ""
    return f"{jour}à {texte}"


def annonce(sorte, secondes, message, fin, maintenant):
    """Ce que l'assistant répond quand il pose le timer."""
    dite = duree_dite(secondes)
    # Moins d'une minute : l'heure de fin n'apprend rien.
    quand = heure_dite(fin, maintenant) if secondes >= 60 else f"dans {dite}"
    if sorte == "rappel":
        if message:
            return f"Je te rappellerai {de(message)} {quand}."
        return f"Rappel noté, {quand}."
    if sorte == "alarme":
        return f"Alarme {de(dite)} lancée, elle sonnera {quand}."
    return f"Minuteur {de(dite)} lancé, il sonnera {quand}."


def notification(sorte, secondes, message):
    """(titre, texte) de la notification affichée à l'heure dite."""
    dite = duree_dite(secondes)
    if sorte == "rappel":
        texte = message[:1].upper() + message[1:] if message else "C'est l'heure."
        return "Rappel", texte
    if sorte == "alarme":
        return "Alarme", f"Alarme {de(dite)} terminée."
    return "Minuteur", f"Minuteur {de(dite)} terminé."


# --- Poser, annuler et sonner ---------------------------------------------------


def poser(fin, titre, texte):
    """Crée le timer systemd qui lancera « minuteur.py sonner » à l'heure fin."""
    nom = f"{PREFIXE}{fin:%Y%m%d-%H%M%S}-{os.getpid()}"
    subprocess.run(
        [
            "systemd-run",
            "--user",
            "--quiet",
            "--collect",
            f"--unit={nom}",
            f"--description={titre} : {texte}",
            f"--on-calendar={fin:%Y-%m-%d %H:%M:%S}",
            # Sans cela, systemd peut sonner jusqu'à une minute en retard.
            "--timer-property=AccuracySec=1s",
            sys.executable,
            str(Path(__file__).resolve()),
            "sonner",
            titre,
            texte,
        ],
        check=True,
        timeout=10,
    )


def timers_en_attente():
    """Les noms des timers minuteur-… qui n'ont pas encore sonné."""
    sortie = subprocess.run(
        ["systemctl", "--user", "list-timers", f"{PREFIXE}*", "--plain", "--no-legend"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    # Une ligne commence par la prochaine échéance, ou par « - » pour un timer
    # qui a déjà sonné et dont la notification est encore affichée.
    return [
        mot
        for ligne in sortie.splitlines()
        if not ligne.startswith("-")
        for mot in ligne.split()
        if mot.startswith(PREFIXE) and mot.endswith(".timer")
    ]


def annuler():
    timers = timers_en_attente()
    if not timers:
        print("Aucun minuteur ni rappel n'est en attente.")
        return 0
    subprocess.run(["systemctl", "--user", "stop", *timers], check=True)
    print("C'est annulé." if len(timers) == 1 else f"J'en ai annulé {len(timers)}.")
    return 0


def arreter():
    """Arrête la sonnerie d'AlarmClock, et celle de secours d'un minuteur."""
    try:
        sortie = subprocess.run(
            ["alarm_clock", "stop"], capture_output=True, text=True, timeout=10
        ).stdout
    except FileNotFoundError:
        sortie = ""
    # Une sonnerie de secours tourne dans l'unité minuteur-… qui l'a lancée.
    subprocess.run(
        ["systemctl", "--user", "kill", "--signal=SIGTERM", f"{PREFIXE}*.service"],
        capture_output=True,
    )
    print(
        "Rien ne sonne." if "nothing is ringing" in sortie else "J'arrête la sonnerie."
    )
    return 0


def nom_de_sonnerie(titre, texte):
    """Ce qu'alarm_clock status et stop montrent : « Minuteur de 5 minutes »."""
    if titre == "Rappel":
        return f"Rappel : {texte.rstrip('.')}"
    return texte.removesuffix(" terminé.").removesuffix(" terminée.")


def lancer_la_sonnerie(nom):
    """Fait sonner AlarmClock. Renvoie de quoi arrêter la sonnerie, ou None.

    None si une autre alarme sonne déjà : elle suffit, et elle ne doit pas être
    arrêtée à la fermeture de cette notification-ci.

    nom est ce que montre alarm_clock stop : « dismissed 'Minuteur de 5
    minutes' » plutôt que « 'test ring' ». Un AlarmClock d'avant --name refuse
    l'option (code 2, celui d'argparse) : la sonnerie part alors sans nom.
    """
    duree_option = ["--duration", str(DUREE_DE_SONNERIE)]
    try:
        resultat = subprocess.run(
            ["alarm_clock", "ring", *duree_option, "--name", nom],
            capture_output=True,
            timeout=10,
        )
        if resultat.returncode == OPTION_REFUSEE:
            resultat = subprocess.run(
                ["alarm_clock", "ring", *duree_option], capture_output=True, timeout=10
            )
    except FileNotFoundError:
        # AlarmClock absent : le son de secours.
        boucle = f"for i in 1 2 3; do pw-play {ALARME}; done"
        return subprocess.Popen(["/bin/sh", "-c", boucle], start_new_session=True)
    if resultat.returncode == 0:
        return "service"
    if resultat.returncode == SANS_SERVICE:
        return subprocess.Popen(
            ["alarm_clock", "ring", "--foreground", *duree_option],
            start_new_session=True,
        )
    return None


def arreter_la_sonnerie(sonnerie):
    if sonnerie == "service":
        subprocess.run(["alarm_clock", "stop"], capture_output=True, timeout=10)
    elif sonnerie is not None and sonnerie.poll() is None:
        os.killpg(sonnerie.pid, signal.SIGTERM)


def sonner(titre, texte):
    """Sonne, et affiche une notification qui reste jusqu'à ce que tu la fermes."""
    sonnerie = lancer_la_sonnerie(nom_de_sonnerie(titre, texte))
    debut = time.monotonic()
    # --action fait attendre notify-send jusqu'à la fermeture de la notification.
    affichee = subprocess.run(
        [
            "notify-send",
            "--app-name=vocal-assistant",
            "--urgency=critical",
            "--action=default=Arrêter la sonnerie",
            titre,
            texte,
        ],
        capture_output=True,
    )
    # Une notification qui n'a pas pu s'afficher n'arrête rien. Fermée après la
    # fin de la sonnerie, elle ne doit pas couper une autre alarme.
    if affichee.returncode == 0 and time.monotonic() - debut < DUREE_DE_SONNERIE:
        arreter_la_sonnerie(sonnerie)
    return 0


def lancer(phrase):
    try:
        sorte, secondes, message = comprendre(phrase)
    except Incompris as erreur:
        print(erreur)
        return 1
    if not 0 < secondes <= DUREE_MAXIMALE:
        print("La durée doit aller d'une seconde à vingt-quatre heures.")
        return 1
    maintenant = datetime.now().replace(microsecond=0)
    fin = maintenant + timedelta(seconds=secondes)
    titre, texte = notification(sorte, secondes, message)
    try:
        poser(fin, titre, texte)
    except (OSError, subprocess.SubprocessError):
        print("Je n'ai pas pu lancer le minuteur.")
        return 1
    print(annonce(sorte, secondes, message, fin, maintenant))
    return 0


def main(arguments):
    action = arguments[0] if arguments else ""
    if action == "annuler":
        return annuler()
    if action == "arreter":
        return arreter()
    if action == "sonner" and len(arguments) == 3:
        return sonner(arguments[1], arguments[2])
    if action:
        print(__doc__.split("\n\n")[1], file=sys.stderr)
        return 2
    return lancer(os.environ.get("VOCAL_ASSISTANT_PHRASE", ""))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
