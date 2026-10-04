#!/usr/bin/env bash
#
# media.sh - now playing for the waybar `custom/media` module (playerctl / MPRIS)
#
# Usage:
#   media.sh follow     print a JSON line for waybar at every player change (continuous)
#   media.sh toggle     play/pause the shown player
#   media.sh next       next track on the shown player
#   media.sh previous   previous track on the shown player

# The shown player is the one playing (the most recently started if several),
# else the most recent paused one. Nothing running: empty output, module hidden.

MAX_LENGTH=40
# Players never shown (comma-separated MPRIS names, as listed by `playerctl -l`)
IGNORED_PLAYERS="vlc"
LAST_ACTIVE="${XDG_RUNTIME_DIR:-/tmp}/waybar-media-player"
ICON_PAUSED=$'\U000f03e4'

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

player_icon() {
    case $1 in
        firefox*)  echo $'' ;;
        chromium*) echo $'' ;;
        spotify*)  echo $'' ;;
        vlc*)      echo $'\U000f057c' ;;
        mpv*)      echo $'\U000f0379' ;;
        mpd*)      echo $'' ;;
        *)         echo $'' ;;
    esac
}

# Print the name of the player to show, or nothing
shown_player() {
    local last name status
    local -a playing paused
    last=$(cat "$LAST_ACTIVE" 2>/dev/null)
    while read -r name; do
        [[ -z $name ]] && continue
        status=$(playerctl -p "$name" status 2>/dev/null)
        case $status in
            Playing) playing+=("$name") ;;
            Paused)  paused+=("$name") ;;
        esac
    done < <(playerctl --ignore-player="$IGNORED_PLAYERS" -l 2>/dev/null)

    local -a group
    if ((${#playing[@]})); then group=("${playing[@]}")
    elif ((${#paused[@]})); then group=("${paused[@]}")
    else return; fi
    for name in "${group[@]}"; do
        [[ $name == "$last" ]] && { echo "$name"; return; }
    done
    echo "${group[0]}"
}

escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<< "$1"; }

print_state() {
    local player
    player=$(shown_player)
    if [[ -z $player ]]; then
        echo '{"text": "", "class": "stopped"}'
        return
    fi

    local status artist title album
    IFS=$'\t' read -r status artist title album < <(playerctl -p "$player" metadata \
        --format $'{{status}}\t{{artist}}\t{{title}}\t{{album}}' 2>/dev/null)
    local label=${title:-$player}
    [[ -n $artist ]] && label="$artist – $label"
    ((${#label} > MAX_LENGTH)) && label="${label:0:MAX_LENGTH-1}…"

    local icon class
    if [[ $status == Playing ]]; then
        icon=$(player_icon "$player") class=playing
    else
        icon=$ICON_PAUSED class=paused
    fi

    local tooltip="${title:-?}"
    [[ -n $artist ]] && tooltip+=$'\n'"$artist"
    [[ -n $album ]] && tooltip+=$'\n'"$album"
    tooltip+=$'\n\n'"${player%%.*} ($status)"$'\n'"Click: play/pause, right click: next, middle click: previous"

    jq -c -n --arg text "$icon $(escape "$label")" --arg tooltip "$(escape "$tooltip")" --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

follow() {
    print_state
    # playerctl prints a line at every change of any player: use it as a trigger
    # and recompute everything (several players, players appearing/vanishing)
    while true; do
        playerctl --ignore-player="$IGNORED_PLAYERS" -a --follow metadata --format $'{{playerName}}\t{{status}}' 2>/dev/null |
            while IFS=$'\t' read -r name status; do
                [[ $status == Playing ]] && echo "$name" > "$LAST_ACTIVE"
                print_state
            done
        sleep 1
    done
}

control() {
    local player
    player=$(shown_player)
    [[ -n $player ]] && playerctl -p "$player" "$1"
}

case ${1:-} in
    follow)   follow ;;
    toggle)   control play-pause ;;
    next)     control next ;;
    previous) control previous ;;
    *)        usage; exit 1 ;;
esac
