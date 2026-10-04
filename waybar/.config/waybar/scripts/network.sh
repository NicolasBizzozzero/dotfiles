#!/usr/bin/env bash
#
# network.sh - Wi-Fi menu for the waybar `network` module (iwd over D-Bus + iwctl + rofi)
#
# Usage:
#   network.sh menu     open the Wi-Fi menu (clicking again while open closes it)
#   network.sh toggle   power the Wi-Fi device on/off

SCAN_TIMEOUT=10

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

notify() { notify-send -a Wi-Fi -i network-wireless "Wi-Fi" "$1"; }

iwd_objects() {
    busctl --json=short call net.connman.iwd / org.freedesktop.DBus.ObjectManager GetManagedObjects
}

# Print "path<TAB>name<TAB>powered" of the first Wi-Fi device
read_device() {
    iwd_objects | jq -r '.data[0] | to_entries[]
        | select(.value["net.connman.iwd.Device"])
        | [.key, .value["net.connman.iwd.Device"].Name.data, .value["net.connman.iwd.Device"].Powered.data]
        | @tsv' | head -n1
}

IFS=$'\t' read -r DEVICE_PATH DEVICE POWERED < <(read_device)
if [[ -z $DEVICE ]]; then
    notify "No Wi-Fi device found (is iwd running?)"
    exit 1
fi

toggle_power() {
    if [[ $POWERED == true ]]; then
        iwctl device "$DEVICE" set-property Powered off
    else
        # A soft rfkill block keeps the device off, so lift it first
        rfkill unblock wifi 2>/dev/null
        iwctl device "$DEVICE" set-property Powered on || notify "Could not turn Wi-Fi on"
    fi
}

# Print "signal<TAB>name<TAB>type<TAB>connected<TAB>known", strongest first.
# Signal is in 100 * dBm. The station object shares the device path.
list_networks() {
    local ordered
    ordered=$(busctl --json=short call net.connman.iwd "$DEVICE_PATH" \
        net.connman.iwd.Station GetOrderedNetworks) || return
    iwd_objects | jq -r --argjson o "$ordered" '.data[0] as $objs | $o.data[0][]
        | . as [$path, $signal]
        | $objs[$path]["net.connman.iwd.Network"]
        | [$signal, .Name.data, .Type.data, .Connected.data, (.KnownNetwork != null)]
        | @tsv'
}

signal_icon() {
    local dbm=$(($1 / 100)) secured=$2 level
    if   ((dbm >= -60)); then level=3
    elif ((dbm >= -67)); then level=2
    elif ((dbm >= -75)); then level=1
    else level=0; fi
    local -a open=(󰤟 󰤢 󰤥 󰤨) locked=(󰤡 󰤤 󰤧 󰤪)
    if [[ $secured == open ]]; then echo "${open[$level]}"; else echo "${locked[$level]}"; fi
}

scan() {
    notify "Scanning…"
    iwctl station "$DEVICE" scan
    local i
    for ((i = 0; i < SCAN_TIMEOUT * 2; i++)); do
        busctl get-property net.connman.iwd "$DEVICE_PATH" net.connman.iwd.Station Scanning \
            | grep -q false && break
        sleep 0.5
    done
}

connect() {
    local ssid=$1 type=$2 known=$3
    if [[ $known == false && $type == 8021x ]]; then
        notify "$ssid uses enterprise auth: connect once with iwctl"
        return
    fi
    if [[ $known == false && $type == psk ]]; then
        local pass
        pass=$(rofi -dmenu -password -p "󰌾  $ssid" -theme-str 'listview { enabled: false; }') || return
        [[ -z $pass ]] && return
        notify "Connecting to $ssid…"
        iwctl --passphrase "$pass" station "$DEVICE" connect "$ssid" >/dev/null
    else
        notify "Connecting to $ssid…"
        iwctl station "$DEVICE" connect "$ssid" >/dev/null
    fi \
        && notify "Connected to $ssid" \
        || notify "Failed to connect to $ssid"
}

show_menu() {
    local -a entries actions ssids types knowns
    local signal name type connected known label

    if [[ $POWERED != true ]]; then
        entries+=("󰤭  Turn Wi-Fi on"); actions+=(power)
    else
        entries+=("󰤨  Turn Wi-Fi off"); actions+=(power)
        entries+=("󰑐  Scan for networks"); actions+=(scan)

        while IFS=$'\t' read -r signal name type connected known; do
            [[ -z $name ]] && continue
            label="$(signal_icon "$signal" "$type")  $name"
            [[ $connected == true ]] && label+="  ✓"
            [[ $connected != true && $known == true ]] && label+="  (saved)"
            # Connected network first
            if [[ $connected == true ]]; then
                entries=("${entries[@]:0:2}" "$label" "${entries[@]:2}")
                actions=("${actions[@]:0:2}" connected "${actions[@]:2}")
                ssids=("$name" "${ssids[@]}"); types=("$type" "${types[@]}"); knowns=("$known" "${knowns[@]}")
            else
                entries+=("$label"); actions+=(network)
                ssids+=("$name"); types+=("$type"); knowns+=("$known")
            fi
        done < <(list_networks)
    fi

    local idx
    idx=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "󰖩  Wi-Fi")
    [[ -z $idx ]] && return

    # Network entries come after the power/scan entries
    local n=$((idx - 2))
    case ${actions[$idx]} in
        power)
            toggle_power
            if [[ $POWERED != true ]]; then
                # Reopen with the network list once the station shows up
                sleep 2
                IFS=$'\t' read -r DEVICE_PATH DEVICE POWERED < <(read_device)
                show_menu
            fi
            ;;
        scan)
            scan
            show_menu
            ;;
        connected)
            iwctl station "$DEVICE" disconnect \
                && notify "Disconnected from ${ssids[$n]}"
            ;;
        network)
            connect "${ssids[$n]}" "${types[$n]}" "${knowns[$n]}"
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
