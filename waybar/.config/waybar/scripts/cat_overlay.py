#!/usr/bin/env python3
#
# cat_overlay.py - invisible click catcher for cat mode (started/stopped by cat.sh)
#
# Usage:
#   cat_overlay.py      cover every screen except waybar until killed

# A transparent layer-shell surface anchored to every edge: with no exclusive
# zone of its own it stays out of waybar's, so the bar keeps its clicks while
# clicks and scrolls anywhere else land here and do nothing. The keyboard is
# left to the "cat" submap of hyprland.lua.

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, Gtk, GtkLayerShell  # noqa: E402

CSS = b"window { background-color: transparent; }"


def cover(monitor):
    window = Gtk.Window()
    window.set_app_paintable(True)
    visual = window.get_screen().get_rgba_visual()
    if visual:
        window.set_visual(visual)

    GtkLayerShell.init_for_window(window)
    GtkLayerShell.set_namespace(window, "cat-mode")
    GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
    GtkLayerShell.set_monitor(window, monitor)
    GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE)
    for edge in (
        GtkLayerShell.Edge.TOP,
        GtkLayerShell.Edge.BOTTOM,
        GtkLayerShell.Edge.LEFT,
        GtkLayerShell.Edge.RIGHT,
    ):
        GtkLayerShell.set_anchor(window, edge, True)

    window.show_all()


def main():
    provider = Gtk.CssProvider()
    provider.load_from_data(CSS)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    display = Gdk.Display.get_default()
    for i in range(display.get_n_monitors()):
        cover(display.get_monitor(i))

    Gtk.main()


if __name__ == "__main__":
    main()
