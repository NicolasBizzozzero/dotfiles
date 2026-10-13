#!/usr/bin/env python3
#
# cat.py - cat mode for the waybar `custom/cat` module (Hyprland submap + GTK layer-shell)
#
# Usage:
#   cat.py status    JSON for waybar: cat icon, highlighted while cat mode is on
#   cat.py toggle    turn cat mode on/off
#   cat.py overlay   cover every screen except waybar while cat mode lasts (started by toggle)

# Cat mode is the "cat" submap of hyprland.lua (a catch-all bind swallows every
# key of every keyboard) plus an invisible overlay catching clicks and scrolls
# everywhere except on waybar, to click the icon again.
#
# Never stuck: the overlay owns cat mode. It turns it off when it exits, for any
# reason, and when waybar's bar has been missing for a few seconds (crashed or
# not loaded: no icon to click). Each status turns off cat mode left without an
# overlay (killed hard). Nothing is saved, so a reboot or a new session starts
# with cat mode off.
#
# The overlay is a transparent layer-shell surface anchored to every edge: with
# no exclusive zone of its own, Hyprland keeps it out of waybar's (the bar has
# "exclusive": true), so it follows the bar's size and position by itself.

import json
import os
import signal
import subprocess
import sys
from pathlib import Path

WAYBAR_SIGNAL = 12
ICON = "\ueeed"
SCRIPT = os.path.realpath(__file__)
CSS = b"window { background-color: transparent; }"
# Seconds without waybar's bar before cat mode turns off (a waybar reload is shorter)
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


def submap(name):
    subprocess.run(
        ["hyprctl", "dispatch", f'hl.dsp.submap("{name}")'], capture_output=True
    )


def refresh_waybar():
    subprocess.run(["pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "waybar"])


def waybar_loaded():
    layers = subprocess.run(["hyprctl", "layers", "-j"], capture_output=True, text=True)
    try:
        monitors = json.loads(layers.stdout).values()
    except ValueError:
        return False
    return any(
        layer.get("namespace") == "waybar"
        for monitor in monitors
        for level in monitor.get("levels", {}).values()
        for layer in level
    )


def overlay_running():
    return (
        subprocess.run(
            ["pgrep", "-f", f"{SCRIPT} overlay"], capture_output=True
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
    subprocess.run(["pkill", "-f", f"{SCRIPT} overlay"])


def status():
    if is_on() and not overlay_running():
        submap("reset")
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
        submap("reset")
        stop_overlay()
    elif waybar_loaded():
        start_overlay()
        submap("cat")
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
        missing = 0 if waybar_loaded() else missing + 1
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
        submap("reset")
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
