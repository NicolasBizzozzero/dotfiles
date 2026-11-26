#!/usr/bin/env bash
#
# clock.sh - date and time for the waybar `custom/date` and `custom/time` modules (date + yad)
#
# Usage:
#   clock.sh date       JSON for waybar: the French date
#   clock.sh time       JSON for waybar: the time
#   clock.sh pad        JSON for waybar's custom/date-pad: blank room after the center group
#   clock.sh calendar   open a calendar popup under the date

# Not waybar's `clock` module: the fmt library it uses ignores the system locale
# on Arch, so the date would not be in French.

# Characters in "mercredi 30 septembre", the longest date
DATE_WIDTH=21

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

case ${1:-} in
    date)
        jq -c -n --arg text "$(date +'%A %d %B')" '{text: $text}'
        ;;
    time)
        jq -c -n --arg text "$(date +' %H:%M:%S')" '{text: $text}'
        ;;
    pad)
        # The date starts at the center of the screen. GTK centers the whole
        # group, so a shorter date would move its start: custom/date-pad, at
        # the far right of the group, adds the missing characters as spaces
        # (the bar's font is monospaced, so a space is as wide as a letter).
        # Blank and out of the way, it keeps every visible gap the same.
        day=$(date +'%A %d %B')
        printf -v pad '%*s' $((DATE_WIDTH - ${#day})) ''
        jq -c -n --arg text "$pad" '{text: $text}'
        ;;
    calendar)
        GDK_BACKEND=x11 yad --calendar --undecorated --fixed --close-on-unfocus \
            --no-buttons --geometry=+675+25
        ;;
    *)
        usage; exit 1
        ;;
esac
