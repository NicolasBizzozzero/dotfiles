#!/usr/bin/env bash
#
# bluetooth.sh - device menu for the waybar `bluetooth` module (bluetoothctl + rofi)
#
# Usage:
#   bluetooth.sh menu      open the device menu (clicking again while open closes it)
#   bluetooth.sh toggle    turn Bluetooth on or off
#   bluetooth.sh on|off    turn it on, or off
#   bluetooth.sh restore   at login: turn it back on, unless it was turned off
#
# On and off both last across reboots. Off is a soft rfkill block, which
# systemd-rfkill saves and restores at boot. On needs `restore` at login
# (Hyprland's autostart): BlueZ is meant to power the adapter on at boot, but
# on this laptop that fails every time ("Failed to set mode: Failed (0x03)").
#
# A device disconnected from the menu is also blocked in BlueZ, so that it stays
# disconnected: a trusted device is let back in without a prompt, and a headset
# reconnects by itself within seconds. Connecting it from the menu, or with the
# voice assistant, unblocks it first. The pairing is kept either way.

SCAN_SECONDS=8

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

notify() { notify-send -a Bluetooth -i bluetooth "Bluetooth" "$1"; }

# bluetoothctl waits forever for bluetoothd when it isn't running
is_powered() { timeout 5 bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }

# The soft rfkill block of the Bluetooth adapter, kept across reboots
is_blocked() {
    local device
    for device in /sys/class/rfkill/rfkill*; do
        [[ $(<"$device/type") == bluetooth && $(<"$device/soft") == 1 ]] && return 0
    done
    return 1
}

power_on() {
    # A soft rfkill block makes `power on` fail, so lift it first
    rfkill unblock bluetooth 2>/dev/null
    # Right after the unblock, or at login, the adapter may not be ready yet
    local try
    for try in {1..10}; do
        timeout 5 bluetoothctl power on >/dev/null 2>&1
        is_powered && return 0
        sleep 0.5
    done
    return 1
}

power_off() {
    timeout 5 bluetoothctl power off >/dev/null 2>&1
    # The block is what lasts across reboots
    rfkill block bluetooth
}

toggle_power() {
    if is_powered; then
        power_off || notify "Could not turn Bluetooth off"
    else
        power_on || notify "Could not turn Bluetooth on"
    fi
}

restore() {
    is_blocked && return 0
    is_powered || power_on || notify "Could not turn Bluetooth back on"
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
            # Blocked first: the device's own reconnection follows the
            # disconnection at once. Blocking may disconnect it already
            bluetoothctl block "$mac" >/dev/null 2>&1
            if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
                bluetoothctl disconnect "$mac" >/dev/null 2>&1
            fi
            if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
                notify "Failed to disconnect from $name"
            else
                notify "Disconnected from $name"
            fi
            ;;
        paired)
            notify "Connecting to $name…"
            # A device disconnected from here or by the voice assistant is
            # blocked, and a blocked device refuses to connect
            bluetoothctl unblock "$mac" >/dev/null 2>&1
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
    toggle)  toggle_power ;;
    on)      power_on ;;
    off)     power_off ;;
    restore) restore ;;
    *)       usage; exit 1 ;;
esac
