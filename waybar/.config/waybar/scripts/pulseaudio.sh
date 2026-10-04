#!/usr/bin/env bash
#
# pulseaudio.sh - volume control for the waybar `pulseaudio` module (pamixer + mako)
#
# Usage:
#   pulseaudio.sh up     raise the volume by 5% (up to 150%)
#   pulseaudio.sh down   lower the volume by 5%
#   pulseaudio.sh mute   mute/unmute

STEP=5
LIMIT=150
SOUND=/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga
# Reusing the previous notification id replaces it instead of stacking a new one
ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-volume-notification-id"

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

notify() {
    local id args=(-a Volume -u low -t 1500 -p)
    id=$(cat "$ID_FILE" 2>/dev/null)
    [[ -n $id ]] && args+=(-r "$id")
    notify-send "${args[@]}" "$@" > "$ID_FILE"
}

notify_volume() {
    if [[ $(pamixer --get-mute) == true ]]; then
        notify "󰖁  Muted"
        return
    fi
    local volume icon
    volume=$(pamixer --get-volume)
    if   ((volume <= 30)); then icon=󰕿
    elif ((volume <= 60)); then icon=󰖀
    else icon=󰕾; fi
    notify -h "int:value:$volume" "$icon  Volume: $volume%"
}

play_sound() {
    [[ -f $SOUND ]] && pw-play "$SOUND" &
}

case ${1:-} in
    up)
        if [[ $(pamixer --get-mute) == true ]]; then
            pamixer -u
        else
            pamixer -i "$STEP" --allow-boost --set-limit "$LIMIT"
        fi
        notify_volume; play_sound
        ;;
    down)
        if [[ $(pamixer --get-mute) == true ]]; then
            pamixer -u
        else
            pamixer -d "$STEP"
        fi
        notify_volume; play_sound
        ;;
    mute)
        pamixer -t
        notify_volume
        ;;
    *)
        usage; exit 1
        ;;
esac
