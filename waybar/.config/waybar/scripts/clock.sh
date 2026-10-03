#!/usr/bin/env bash
#
# clock.sh - date and time for the waybar `custom/clock` module (date + yad)
#
# Usage:
#   clock.sh status     JSON for waybar: French date and time
#   clock.sh calendar   open a calendar popup under the clock

# Not waybar's `clock` module: the fmt library it uses ignores the system locale
# on Arch, so the date would not be in French.

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

case ${1:-} in
    status)
        jq -c -n --arg text "$(date +'%A %d %B   %H:%M:%S')" '{text: $text}'
        ;;
    calendar)
        GDK_BACKEND=x11 yad --calendar --undecorated --fixed --close-on-unfocus \
            --no-buttons --geometry=+675+25
        ;;
    *)
        usage; exit 1
        ;;
esac
