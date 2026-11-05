#!/usr/bin/env bash
#
# microphone.sh - microphone for the waybar `custom/microphone` module (pactl + pamixer + rofi + mako)
#
# Usage:
#   microphone.sh follow   print a JSON line for waybar at every microphone change (continuous)
#   microphone.sh up       raise the microphone volume by 5% (up to 100%)
#   microphone.sh down     lower the microphone volume by 5%
#   microphone.sh mute     mute/unmute the microphone
#   microphone.sh menu     choose the microphone (clicking again while open closes it)

# The microphone is the default source. Choosing one in the menu makes it the
# configured default, which WirePlumber saves (~/.local/state/wireplumber/default-nodes)
# along with each microphone's volume: both survive a reboot. While the chosen
# microphone is absent, another one is used until it comes back.

STEP=5
LIMIT=100
ICON=󰍬
ICON_MUTED=󰍭
# Reusing the previous notification id replaces it instead of stacking a new one
ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-microphone-notification-id"

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

# Microphones as a JSON array: every source except the monitors of outputs
microphones() {
    pactl -f json list sources 2>/dev/null |
        jq -c '[.[] | select(.properties["device.class"] != "monitor")]'
}

is_muted() { [[ $(pamixer --default-source --get-mute) == true ]]; }

escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<< "$1"; }

print_state() {
    local name
    name=$(microphones | jq -r --arg default "$(pactl get-default-source 2>/dev/null)" \
        'first(.[] | select(.name == $default) | .description) // empty')
    # No microphone: empty output, module hidden
    if [[ -z $name ]]; then
        echo '{"text": "", "class": "none"}'
        return
    fi

    local volume text class
    volume=$(pamixer --default-source --get-volume)
    if is_muted; then
        text=$ICON_MUTED class=muted
    else
        text="$ICON $volume%" class=on
    fi
    local tooltip="$name | $volume%"$'\n\n'"Scroll: volume, right click: mute, click: choose the microphone"
    jq -c -n --arg text "$text" --arg tooltip "$(escape "$tooltip")" --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

follow() {
    print_state
    # pactl prints a line at every audio event: redraw on source changes (volume,
    # mute, plugged in or out) and server ones (default microphone changed)
    while true; do
        LC_ALL=C pactl subscribe 2>/dev/null | while read -r line; do
            case $line in
                *" source #"*|*" server"*) print_state ;;
            esac
        done
        sleep 1
        print_state
    done
}

notify() {
    local id args=(-a Microphone -u low -t 1500 -p)
    # Fast scrolling runs several instances at once: without the lock, they all
    # read the id before any writes it back, and each stacks its own notification
    exec 9>> "$ID_FILE.lock"
    flock 9
    id=$(cat "$ID_FILE" 2>/dev/null)
    [[ -n $id ]] && args+=(-r "$id")
    notify-send "${args[@]}" "$@" > "$ID_FILE.tmp" && mv "$ID_FILE.tmp" "$ID_FILE"
    flock -u 9
}

notify_volume() {
    if is_muted; then
        notify "$ICON_MUTED  Microphone muted"
        return
    fi
    local volume
    volume=$(pamixer --default-source --get-volume)
    notify -h "int:value:$volume" "$ICON  Microphone: $volume%"
}

show_menu() {
    local -a entries names
    local default name description
    default=$(pactl get-default-source 2>/dev/null)
    while IFS=$'\t' read -r name description; do
        if [[ $name == "$default" ]]; then
            entries+=("$ICON  $description  ✓")
        else
            entries+=("$ICON  $description")
        fi
        names+=("$name")
    done < <(microphones | jq -r '.[] | "\(.name)\t\(.description)"')

    if ((${#entries[@]} == 0)); then
        notify-send -a Microphone -i audio-input-microphone "Microphone" "No microphone found"
        return
    fi

    local idx
    idx=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "$ICON  Microphone")
    [[ -z $idx ]] && return
    pactl set-default-source "${names[$idx]}"
}

case ${1:-} in
    follow)
        follow
        ;;
    up)
        if is_muted; then
            pamixer --default-source -u
        else
            pamixer --default-source -i "$STEP" --set-limit "$LIMIT"
        fi
        notify_volume
        ;;
    down)
        if is_muted; then
            pamixer --default-source -u
        else
            pamixer --default-source -d "$STEP"
        fi
        notify_volume
        ;;
    mute)
        pamixer --default-source -t
        notify_volume
        ;;
    menu)
        if pgrep -x rofi >/dev/null; then
            pkill -x rofi
            exit 0
        fi
        show_menu
        ;;
    *)
        usage; exit 1
        ;;
esac
