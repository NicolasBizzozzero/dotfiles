#!/usr/bin/env python3
#
# cat.py - cat mode for the waybar `custom/cat` module (Hyprland submap + GTK layer-shell)
#
# Usage:
#   cat.py status    JSON for waybar: cat icon, highlighted while cat mode is on
#   cat.py toggle    turn cat mode on/off
#   cat.py overlay   cover every screen except waybar while cat mode lasts (started by toggle)

# Cat mode is cat_mode() in hyprland.lua (the "cat" submap: a catch-all bind
# swallows every key of every keyboard; and the touchpad kept on while keys are
# pressed) plus an invisible overlay catching clicks and scrolls everywhere
# except on waybar, to click the icon again.
#
# Never stuck: the overlay owns cat mode. It turns it off when it exits, for any
# reason, and when waybar's bar has been out of reach for a few seconds (crashed,
# not loaded, or under a fullscreen window: no icon to click); it can't be turned
# on then either. Each status turns off cat mode left without an overlay (killed
# hard). Nothing is saved, so a reboot or a new session starts with cat mode off.
#
# The overlay is a transparent layer-shell surface anchored to every edge: with
# no exclusive zone of its own, Hyprland keeps it out of waybar's (the bar has
# "exclusive": true), so it follows the bar's size and position by itself.

import json
import os
import re
import signal
import subprocess
import sys
from pathlib import Path

WAYBAR_SIGNAL = 12
ICON = "\ueeed"
SCRIPT = os.path.realpath(__file__)
# The overlay process exactly (run through the shebang's python), not any
# command line that merely mentions it
OVERLAY = f"^[^ ]*python[^ ]* {re.escape(SCRIPT)} overlay$"
CSS = b"window { background-color: transparent; }"
# Seconds without waybar's bar in reach before cat mode turns off (a waybar reload is shorter)
WAYBAR_GRACE = 3


def usage():
    lines = Path(__file__).read_text().splitlines()
    block = lines[lines.index("# Usage:") + 1 :]
    for line in block:
        if not line.startswith("#   "):
            break
        print("  " + line[4:], file=sys.stderr)
    sys.exit(1)


def is_on():
    submap = subprocess.run(["hyprctl", "submap"], capture_output=True, text=True)
    return submap.stdout.strip() == "cat"


def set_mode(on):
    subprocess.run(
        ["hyprctl", "eval", f"cat_mode({str(on).lower()})"], capture_output=True
    )
    if not on:
        # Leave the submap even if hyprland.lua has no cat_mode() (failed to load)
        subprocess.run(
            ["hyprctl", "dispatch", 'hl.dsp.submap("reset")'], capture_output=True
        )


def refresh_waybar():
    subprocess.run(["pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "waybar"])


def hyprctl_json(what):
    output = subprocess.run(["hyprctl", what, "-j"], capture_output=True, text=True)
    return json.loads(output.stdout)


def bar_reachable():
    """Waybar's bar is shown on some monitor: loaded, and not under a fullscreen
    window (the bar is on the top layer, which fullscreen windows cover)"""
    try:
        layers, monitors, clients = map(hyprctl_json, ("layers", "monitors", "clients"))
    except ValueError:
        return False
    with_bar = {
        name
        for name, monitor in layers.items()
        for level in monitor.get("levels", {}).values()
        for layer in level
        if layer.get("namespace") == "waybar"
    }
    # fullscreen is a bit mask: 1 maximized (the bar stays shown), 2 fullscreen
    covered = {c["workspace"]["id"] for c in clients if c.get("fullscreen", 0) & 2}
    return any(
        monitor["name"] in with_bar and monitor["activeWorkspace"]["id"] not in covered
        for monitor in monitors
    )


def overlay_running():
    return (
        subprocess.run(
            ["pgrep", "-f", OVERLAY], capture_output=True
        ).returncode
        == 0
    )


def start_overlay():
    if not overlay_running():
        subprocess.Popen(
            [SCRIPT, "overlay"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )


def stop_overlay():
    subprocess.run(["pkill", "-f", OVERLAY])


def status():
    if is_on() and not overlay_running():
        set_mode(False)
    if is_on():
        tooltip, css_class = (
            "Cat mode: keyboard and clicks disabled (click to enable them)",
            "on",
        )
    else:
        stop_overlay()
        tooltip, css_class = (
            "Cat mode: off (click to disable the keyboard and clicks outside the bar)",
            "off",
        )
    print(json.dumps({"text": ICON, "tooltip": tooltip, "class": css_class}))


def toggle():
    if is_on():
        set_mode(False)
        stop_overlay()
    elif bar_reachable():
        start_overlay()
        set_mode(True)
    refresh_waybar()


def overlay():
    # GTK only here: status runs every few seconds and must stay fast
    import gi

    gi.require_version("Gdk", "3.0")
    gi.require_version("Gtk", "3.0")
    gi.require_version("GtkLayerShell", "0.1")
    from gi.repository import Gdk, GLib, GLibUnix, Gtk, GtkLayerShell

    provider = Gtk.CssProvider()
    provider.load_from_data(CSS)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    display = Gdk.Display.get_default()
    for i in range(display.get_n_monitors()):
        window = Gtk.Window()
        window.set_app_paintable(True)
        visual = window.get_screen().get_rgba_visual()
        if visual:
            window.set_visual(visual)

        GtkLayerShell.init_for_window(window)
        GtkLayerShell.set_namespace(window, "cat-mode")
        GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_monitor(window, display.get_monitor(i))
        GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE)
        for edge in (
            GtkLayerShell.Edge.TOP,
            GtkLayerShell.Edge.BOTTOM,
            GtkLayerShell.Edge.LEFT,
            GtkLayerShell.Edge.RIGHT,
        ):
            GtkLayerShell.set_anchor(window, edge, True)
        window.show_all()

    missing = 0

    def check_waybar():
        nonlocal missing
        missing = 0 if bar_reachable() else missing + 1
        if missing >= WAYBAR_GRACE:
            Gtk.main_quit()
        return GLib.SOURCE_CONTINUE

    def quit_on_signal():
        Gtk.main_quit()
        return GLib.SOURCE_REMOVE

    GLib.timeout_add_seconds(1, check_waybar)
    for signum in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signum, quit_on_signal)
    try:
        Gtk.main()
    finally:
        set_mode(False)
        refresh_waybar()


if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "status":
        status()
    elif command == "toggle":
        toggle()
    elif command == "overlay":
        overlay()
    else:
        usage()
