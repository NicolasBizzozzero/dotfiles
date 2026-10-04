#!/usr/bin/env bash
#
# power.sh - power button for the waybar `custom/power` module (systemctl + TUXEDO Control Center + rofi)
#
# Usage:
#   power.sh status     JSON for waybar: power icon, current profile in tooltip and class
#   power.sh menu       lock, suspend, log out, reboot or shut down (clicking again closes it)
#   power.sh profiles   pick a power profile (TUXEDO Control Center) in rofi

WAYBAR_SIGNAL=9

# Power profiles are TUXEDO Control Center profiles (~/.config/tuxedo/profiles.json,
# installed with ~/.config/tuxedo/apply.sh). Switching here is temporary: tccd goes
# back to the default profile at reboot or when the charger is plugged/unplugged.
declare -A ICONS=([performance]=󰓅 [entertainment]=󰗑 [power_saving]=󰌪 [quiet]=󰌪)
DEFAULT_ICON=󰗑

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

tcc() {
    busctl --system --json=short call com.tuxedocomputers.tccd /com/tuxedocomputers/tccd \
        com.tuxedocomputers.tccd "$@" 2>/dev/null | jq -r '.data[0]'
}

# Print "id<TAB>name<TAB>firmware mode" of the active profile, or of every profile
active_profile() { tcc GetActiveProfileJSON | jq -r '[.id, .name, (.odmProfile.name // "")] | @tsv'; }
list_profiles() { tcc GetCustomProfilesJSON | jq -r '.[] | [.id, .name, (.odmProfile.name // "")] | @tsv'; }

icon_for() { echo "${ICONS[$1]:-$DEFAULT_ICON}"; }

status() {
    local id name odm
    IFS=$'\t' read -r id name odm < <(active_profile)
    jq -c -n --arg name "${name:-unknown}" --arg icon "$(icon_for "$odm")" --arg odm "${odm:-unknown}" '{
        text: "⏻",
        tooltip: "Left click: power menu\nRight click: power profile (\($icon) \($name))",
        class: $odm
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

    local current id name odm choice
    local -a ids names odms entries
    IFS=$'\t' read -r current _ _ < <(active_profile)
    while IFS=$'\t' read -r id name odm; do
        local label="$(icon_for "$odm")  $name"
        [[ $id == "$current" ]] && label+="  ✓"
        ids+=("$id"); names+=("$name"); odms+=("$odm"); entries+=("$label")
    done < <(list_profiles)

    choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "󰂄  Power profile")
    [[ -z $choice ]] && return
    [[ ${ids[$choice]} == "$current" ]] && return

    if [[ $(tcc SetTempProfileById s "${ids[$choice]}") == true ]]; then
        notify-send -a "Power profile" -i battery "Power profile" "$(icon_for "${odms[$choice]}")  ${names[$choice]}"
    else
        notify-send -a "Power profile" -i battery "Power profile" "Failed to switch to ${names[$choice]}"
    fi
    pkill -RTMIN+$WAYBAR_SIGNAL waybar
}

case ${1:-} in
    status)   status ;;
    menu)     menu ;;
    profiles) profiles ;;
    *)        usage; exit 1 ;;
esac
