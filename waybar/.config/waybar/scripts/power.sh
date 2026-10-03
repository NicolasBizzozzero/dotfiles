#!/usr/bin/env bash
#
# power.sh - power button for the waybar `custom/power` module (wlogout + powerprofilesctl + rofi)
#
# Usage:
#   power.sh status     JSON for waybar: power icon, current profile in tooltip and class
#   power.sh logout     open the logout menu (clicking again while open closes it)
#   power.sh profiles   pick a power profile in rofi

WAYBAR_SIGNAL=9

declare -A ICONS=([performance]=󰓅 [balanced]=󰗑 [power-saver]=󰌪)

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

status() {
    local current
    current=$(powerprofilesctl get 2>/dev/null) || current=unknown
    jq -c -n --arg profile "$current" --arg icon "${ICONS[$current]}" '{
        text: "⏻",
        tooltip: "Left click: logout menu\nRight click: power profile (\($icon) \($profile))",
        class: $profile
    }'
}

logout() {
    if pgrep -x wlogout >/dev/null; then
        pkill -x wlogout
        return
    fi
    # Top/bottom margin per resolution class, scaled to the focused monitor
    local height scale base margin buttons=6
    read -r height scale < <(hyprctl -j monitors \
        | jq -r '.[] | select(.focused) | "\(.height / .scale | floor) \(.scale)"')
    if   ((height >= 2160)); then base=2160 margin=600
    elif ((height >= 1600)); then base=1600 margin=400
    elif ((height >= 1440)); then base=1440 margin=400
    elif ((height >= 1080)); then base=1080 margin=200
    elif ((height >= 720));  then base=720  margin=50 buttons=3
    else
        wlogout &
        return
    fi
    margin=$(awk "BEGIN { printf \"%.0f\", $margin * $base * $scale / $height }")
    wlogout --protocol layer-shell -b "$buttons" -T "$margin" -B "$margin" &
}

profiles() {
    if pgrep -x rofi >/dev/null; then
        pkill -x rofi
        return
    fi

    local current profile choice
    local -a profiles entries
    current=$(powerprofilesctl get)
    mapfile -t profiles < <(powerprofilesctl list | sed -n 's/^[ *]*\([a-z-]*\):$/\1/p')
    for profile in "${profiles[@]}"; do
        local label="${ICONS[$profile]}  $profile"
        [[ $profile == "$current" ]] && label+="  ✓"
        entries+=("$label")
    done

    choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "󰂄  Power profile")
    [[ -z $choice ]] && return
    profile=${profiles[$choice]}
    [[ $profile == "$current" ]] && return

    if powerprofilesctl set "$profile"; then
        notify-send -a "Power profile" -i battery "Power profile" "${ICONS[$profile]}  $profile"
    else
        notify-send -a "Power profile" -i battery "Power profile" "Failed to switch to $profile"
    fi
    pkill -RTMIN+$WAYBAR_SIGNAL waybar
}

case ${1:-} in
    status)   status ;;
    logout)   logout ;;
    profiles) profiles ;;
    *)        usage; exit 1 ;;
esac
