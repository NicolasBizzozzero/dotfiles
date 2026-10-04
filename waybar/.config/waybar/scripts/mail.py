#!/usr/bin/env python3
#
# mail.py - unread mail for the waybar `custom/mail` module (IMAP IDLE + Secret Service + Thunderbird)
#
# Usage:
#   mail.py watch    keep a push (IDLE) connection per account, update the count (systemd service)
#   mail.py status   JSON for waybar: mail icon with a blue dot when there is unread mail,
#                    unread counts per account in the tooltip (--count: show the total instead)
#   mail.py open     focus Thunderbird (switching workspace), or start it on the current one

# Accounts are private, so they are not in the dotfiles: one per line in
# ~/.config/waybar/mail-accounts.conf (format in mail-accounts.example.conf).
# Each password comes from the Secret Service (KeePassXC), stored once with:
#     secret-tool store --label="waybar-mail <username>" service waybar-mail user <username>
# Unread mail is counted in the "All Mail" folder (IMAP \All special use: every
# folder and label once, without Spam and Trash), or INBOX if the server has none.
# Thunderbird sends the new-mail notifications.

import html
import json
import os
import shlex
import socket
import ssl
import subprocess
import sys
import threading
import time
from imaplib import IMAP4, IMAP4_SSL
from pathlib import Path

ICON = "󰇮"
# Unread dot: color, size, how far it is pulled back over the envelope (0: none,
# the icon's empty right edge already makes it overlap the corner) and raised
# (Pango units: 1/1024 pt)
BADGE_COLOR = "#2f6bff"
BADGE_SIZE = "6000"
BADGE_PULL = "0"
BADGE_RISE = "4200"
WAYBAR_SIGNAL = 11
IDLE_SECONDS = 25 * 60  # servers drop IDLE after 29 minutes
RETRY_MAX_SECONDS = 300
CONFIG = Path.home() / ".config/waybar/mail-accounts.conf"
STATE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "waybar-mail.json"
THUNDERBIRD_CLASS = "org.mozilla.Thunderbird"

state = {}
state_lock = threading.Lock()


def usage():
    lines = Path(__file__).read_text().splitlines()
    block = lines[lines.index("# Usage:") + 1 :]
    for line in block:
        if not line.startswith("#   "):
            break
        print("  " + line[4:], file=sys.stderr)
    sys.exit(1)


def log(message):
    print(message, file=sys.stderr, flush=True)


def read_accounts():
    """[(label, host, port, security, user)] from the private config file."""
    accounts = []
    for line in CONFIG.read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        label, host, port, security, user = shlex.split(line)
        accounts.append((label, host, int(port), security, user))
    return accounts


def password(user):
    result = subprocess.run(
        ["secret-tool", "lookup", "service", "waybar-mail", "user", user],
        capture_output=True,
        text=True,
    )
    return result.stdout if result.returncode == 0 and result.stdout else None


def all_mail_folder(conn):
    """Name of the folder flagged \\All (Gmail "All Mail", Proton Bridge "All
    Mail"), so mail sorted into other folders by filters is counted too."""
    _, folders = conn.list()
    for line in folders:
        line = line.decode()
        if "\\All" in line.split(")")[0]:
            return line.rsplit(' "/" ', 1)[-1].strip()
    return "INBOX"


def connect(host, port, security):
    context = ssl.create_default_context()
    if host in ("127.0.0.1", "localhost", "::1"):
        # Proton Mail Bridge uses its own self-signed certificate; the
        # connection never leaves this machine
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
    if security == "ssl":
        return IMAP4_SSL(host, port, ssl_context=context, timeout=60)
    conn = IMAP4(host, port, timeout=60)
    conn.starttls(ssl_context=context)
    return conn


def publish(label, unread=None, error=None):
    """Store an account's state and tell waybar to refresh, when it changed."""
    with state_lock:
        new = {"unread": unread, "error": error}
        if state.get(label) == new:
            return
        state[label] = new
        tmp = STATE.with_suffix(".tmp")
        tmp.write_text(json.dumps(state))
        tmp.replace(STATE)
    subprocess.run(["pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "waybar"])


def watch_account(label, host, port, security, user):
    delay = 5
    while True:
        secret = password(user)
        if secret is None:
            publish(label, error="password not in the keyring (KeePassXC locked?)")
            time.sleep(30)
            continue
        try:
            conn = connect(host, port, security)
            conn.login(user, secret)
            conn.select(all_mail_folder(conn), readonly=True)
            delay = 5
            while True:
                _, data = conn.search(None, "UNSEEN")
                publish(label, unread=len(data[0].split()))
                # Wait for the server to push a change (new mail, mail read,
                # deleted...), then recount
                with conn.idle(duration=IDLE_SECONDS) as idler:
                    for _ in idler.burst():
                        pass
        except (OSError, IMAP4.error, ssl.SSLError, socket.timeout) as error:
            log(f"{label}: {error}")
            publish(label, error=str(error))
            time.sleep(delay)
            delay = min(delay * 2, RETRY_MAX_SECONDS)


def watch():
    accounts = read_accounts()
    for label, *_ in accounts:
        state[label] = {"unread": None, "error": "connecting"}
    threads = [
        threading.Thread(target=watch_account, args=account, daemon=True)
        for account in accounts
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()


def badge_markup(visible):
    """Envelope with a small dot over its top-right corner (Pango markup): the
    dot follows the envelope, raised, and BADGE_PULL (letter spacing) can pull
    it further back over it.
    The dot is always drawn, transparent when hidden, so the width never
    changes and the clock does not move when mail arrives."""
    alpha = "100%" if visible else "1"
    return (
        f'<span letter_spacing="{BADGE_PULL}">{ICON}</span>'
        f'<span color="{BADGE_COLOR}" fgalpha="{alpha}" size="{BADGE_SIZE}" rise="{BADGE_RISE}">●</span>'
    )


def status(show_count=False):
    try:
        accounts = json.loads(STATE.read_text())
    except (OSError, ValueError):
        accounts = {}

    total = sum(a["unread"] or 0 for a in accounts.values())
    lines = []
    for label, account in accounts.items():
        if account["error"]:
            lines.append(f"{label}: {account['error']}")
        else:
            lines.append(f"{label}: {account['unread']} unread")
    if not accounts:
        lines.append("Mail watcher not running (systemctl --user status waybar-mail)")
    elif len(accounts) > 1:
        lines.append(f"Total: {total} unread")

    text = f"{ICON} {total}" if show_count and total else badge_markup(total > 0)
    classes = ["unread" if total else "none"]
    if any(a["error"] for a in accounts.values()) or not accounts:
        classes.append("problem")
    tooltip = html.escape("\n".join(lines))
    print(json.dumps({"text": text, "tooltip": tooltip, "class": classes}, ensure_ascii=False))


def open_thunderbird():
    clients = json.loads(
        subprocess.run(
            ["hyprctl", "-j", "clients"], capture_output=True, text=True
        ).stdout
    )
    window = next((c for c in clients if c["class"] == THUNDERBIRD_CLASS), None)
    if window:
        subprocess.run(
            [
                "hyprctl",
                "dispatch",
                f'hl.dsp.focus({{ window = "address:{window["address"]}" }})',
            ],
            capture_output=True,
        )
    else:
        subprocess.Popen(
            ["thunderbird"],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "watch":
        watch()
    elif command == "status":
        status(show_count="--count" in sys.argv[2:])
    elif command == "open":
        open_thunderbird()
    else:
        usage()
