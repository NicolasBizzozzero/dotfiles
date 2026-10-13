#!/usr/bin/env bash
#
# cat.sh - cat mode for the waybar `custom/cat` module (Hyprland submap)
#
# Usage:
#   cat.sh status   JSON for waybar: cat icon, highlighted while cat mode is on
#   cat.sh toggle   turn cat mode on/off

# Cat mode is the "cat" submap of hyprland.lua (a catch-all bind swallows every
# key of every keyboard) plus cat_overlay.py, an invisible surface catching
# clicks and scrolls everywhere except on waybar, to click the icon again.
# The submap is the state: each status starts or stops the overlay to match it.

WAYBAR_SIGNAL=12
ICON=$'\U000f011b'
OVERLAY="$(dirname "$(readlink -f "$0")")/cat_overlay.py"

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

is_on() { [[ $(hyprctl submap) == cat ]]; }

start_overlay() { pgrep -f "$OVERLAY" >/dev/null || setsid -f "$OVERLAY" >/dev/null 2>&1; }
stop_overlay()  { pkill -f "$OVERLAY"; }

case ${1:-} in
    status)
        if is_on; then
            start_overlay
            jq -c -n --arg text "$ICON" '{text: $text, tooltip: "Cat mode: keyboard and clicks disabled (click to enable them)", class: "on"}'
        else
            stop_overlay
            jq -c -n --arg text "$ICON" '{text: $text, tooltip: "Cat mode: off (click to disable the keyboard and clicks outside the bar)", class: "off"}'
        fi
        ;;
    toggle)
        if is_on; then
            hyprctl dispatch 'hl.dsp.submap("reset")' >/dev/null
            stop_overlay
        else
            hyprctl dispatch 'hl.dsp.submap("cat")' >/dev/null
            start_overlay
        fi
        pkill -RTMIN+$WAYBAR_SIGNAL waybar
        ;;
    *)
        usage; exit 1
        ;;
esac
