#!/usr/bin/env bash
#
# power.sh - power button for the waybar `custom/power` module (systemctl + powerprofilesctl + rofi)
#
# Usage:
#   power.sh status     JSON for waybar: power icon, current profile in tooltip and class
#   power.sh menu       lock, suspend, log out, reboot or shut down (clicking again closes it)
#   power.sh profiles   pick a power profile in rofi

WAYBAR_SIGNAL=9

declare -A ICONS=([performance]=󰓅 [balanced]=󰗑 [power-saver]=󰌪)

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

status() {
    local current
    current=$(powerprofilesctl get 2>/dev/null) || current=unknown
    jq -c -n --arg profile "$current" --arg icon "${ICONS[$current]}" '{
        text: "⏻",
        tooltip: "Left click: power menu\nRight click: power profile (\($icon) \($profile))",
        class: $profile
    }'
}

confirm() {
    local answer
    answer=$(printf '%s\n' "  Yes, $1" "  Cancel" | rofi -dmenu -i -format i -p "$2  $1?")
    [[ $answer == 0 ]]
}

menu() {
    if pgrep -x rofi >/dev/null; then
        pkill -x rofi
        return
    fi

    local -a entries=("  Lock" "󰤄  Suspend" "󰍃  Log out" "󰜉  Reboot" "  Shut down")
    local choice
    choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "⏻  Power")
    case $choice in
        0) hyprlock & ;;
        1) hyprlock & sleep 1; systemctl suspend ;;
        2) confirm "log out" 󰍃 && hyprctl dispatch 'hl.dsp.exit()' ;;
        3) confirm "reboot" 󰜉 && systemctl reboot ;;
        4) confirm "shut down" "" && systemctl poweroff ;;
    esac
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
    menu)     menu ;;
    profiles) profiles ;;
    *)        usage; exit 1 ;;
esac
