#!/usr/bin/env bash
#
# bluetooth.sh - device menu for the waybar `bluetooth` module (bluetoothctl + rofi)
#
# Usage:
#   bluetooth.sh menu     open the device menu (clicking again while open closes it)
#   bluetooth.sh toggle   power the adapter on/off

SCAN_SECONDS=8

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

notify() { notify-send -a Bluetooth -i bluetooth "Bluetooth" "$1"; }

is_powered() { bluetoothctl show | grep -q "Powered: yes"; }

power_on() {
    # A soft rfkill block makes `power on` fail, so lift it first
    rfkill unblock bluetooth 2>/dev/null
    bluetoothctl power on >/dev/null
}

toggle_power() {
    if is_powered; then
        bluetoothctl power off >/dev/null
    else
        power_on || notify "Could not turn Bluetooth on"
    fi
}

# Print "MAC<TAB>name" for `bluetoothctl devices [Filter]`
list_devices() {
    bluetoothctl devices "$@" | sed -n 's/^Device \([0-9A-F:]\{17\}\) \(.*\)$/\1\t\2/p'
}

battery_of() {
    bluetoothctl info "$1" | sed -n 's/.*Battery Percentage: .*(\([0-9]*\)).*/\1/p'
}

device_action() {
    local mac=$1 name=$2 state=$3
    case $state in
        connected)
            bluetoothctl disconnect "$mac" >/dev/null \
                && notify "Disconnected from $name" \
                || notify "Failed to disconnect from $name"
            ;;
        paired)
            notify "Connecting to $name…"
            bluetoothctl connect "$mac" >/dev/null \
                && notify "Connected to $name" \
                || notify "Failed to connect to $name"
            ;;
        new)
            notify "Pairing with $name…"
            # Without a registered agent the adapter is not pairable: the link
            # gets encrypted but no key is stored, so the pairing is lost on
            # the next power cycle. Enable pairable and pair with an agent.
            bluetoothctl pairable on >/dev/null
            bluetoothctl --agent NoInputNoOutput pair "$mac" >/dev/null
            if ! bluetoothctl info "$mac" | grep -q "Bonded: yes"; then
                notify "Failed to pair with $name. Is it in pairing mode?"
                return
            fi
            bluetoothctl trust "$mac" >/dev/null
            bluetoothctl connect "$mac" >/dev/null \
                && notify "Connected to $name" \
                || notify "Paired with $name but failed to connect"
            ;;
    esac
}

show_menu() {
    local -a entries actions macs names states
    local mac name label

    if ! is_powered; then
        entries+=("󰂲  Turn Bluetooth on"); actions+=(power)
    else
        entries+=("󰂯  Turn Bluetooth off"); actions+=(power)
        entries+=("󰑐  Scan for devices");  actions+=(scan)

        declare -A connected paired
        while IFS=$'\t' read -r mac name; do connected[$mac]=1; done < <(list_devices Connected)
        while IFS=$'\t' read -r mac name; do paired[$mac]=1;    done < <(list_devices Paired)

        # Connected first, then paired, then newly discovered
        local pass
        for pass in connected paired new; do
            while IFS=$'\t' read -r mac name; do
                local state=new
                [[ -n ${paired[$mac]} ]] && state=paired
                [[ -n ${connected[$mac]} ]] && state=connected
                [[ $state == "$pass" ]] || continue
                # Unnamed devices only show their address as alias: skip them
                [[ $name == "${mac//:/-}" ]] && continue

                case $state in
                    connected)
                        label="󰂱  $name  ✓"
                        local bat; bat=$(battery_of "$mac")
                        [[ -n $bat ]] && label+="  ${bat}%"
                        ;;
                    paired) label="󰂯  $name" ;;
                    new)    label="󰂰  $name  (new)" ;;
                esac
                entries+=("$label"); actions+=(device)
                macs+=("$mac"); names+=("$name"); states+=("$state")
            done < <(list_devices)
        done
    fi

    local idx
    idx=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "  Bluetooth")
    [[ -z $idx ]] && return

    case ${actions[$idx]} in
        power)
            toggle_power
            # Reopen so the device list is there right after turning on
            is_powered && show_menu
            ;;
        scan)
            notify "Scanning for ${SCAN_SECONDS}s…"
            bluetoothctl --timeout "$SCAN_SECONDS" scan on >/dev/null
            show_menu
            ;;
        device)
            # Device entries come after the power/scan entries
            local d=$((idx - 2))
            device_action "${macs[$d]}" "${names[$d]}" "${states[$d]}"
            ;;
    esac
}

case ${1:-} in
    menu)
        if pgrep -x rofi >/dev/null; then
            pkill -x rofi
            exit 0
        fi
        show_menu
        ;;
    toggle) toggle_power ;;
    *)      usage; exit 1 ;;
esac
