#!/usr/bin/env bash
#
# cat.sh - cat mode for the waybar `custom/cat` module (Hyprland submap)
#
# Usage:
#   cat.sh status   JSON for waybar: cat icon, highlighted while cat mode is on
#   cat.sh toggle   turn cat mode on/off

# Cat mode is the "cat" submap of hyprland.lua: a catch-all bind swallows every
# key of every keyboard, the touchpad keeps working to click the icon again.
# A config reload resets the submap, so the keyboard comes back by itself.

WAYBAR_SIGNAL=12
ICON=$'\U000f011b'

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

is_on() { [[ $(hyprctl submap) == cat ]]; }

case ${1:-} in
    status)
        if is_on; then
            jq -c -n --arg text "$ICON" '{text: $text, tooltip: "Cat mode: keyboard disabled (click to enable it)", class: "on"}'
        else
            jq -c -n --arg text "$ICON" '{text: $text, tooltip: "Cat mode: off (click to disable the keyboard)", class: "off"}'
        fi
        ;;
    toggle)
        if is_on; then
            hyprctl dispatch 'hl.dsp.submap("reset")' >/dev/null
        else
            hyprctl dispatch 'hl.dsp.submap("cat")' >/dev/null
        fi
        pkill -RTMIN+$WAYBAR_SIGNAL waybar
        ;;
    *)
        usage; exit 1
        ;;
esac
