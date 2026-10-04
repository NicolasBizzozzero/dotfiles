#!/usr/bin/env bash
#
# temperature.sh - temperatures for the waybar `custom/temperature` module (lm_sensors)
#
# Usage:
#   temperature.sh status   JSON for waybar: ACPI temperature, every sensor in the tooltip

# Sensors are found by name, not by hwmon number: the numbers can change at boot
CRITICAL=80
ICON_LOW=$''   # thermometer empty
ICON_MID=$''   # thermometer half
ICON_HIGH=$''  # thermometer full

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

# Print "<chip> <feature> <°C>" for every temperature sensor
read_sensors() {
    sensors -j 2>/dev/null | jq -r '
        to_entries[] | .key as $chip | .value | to_entries[]
        | select(.value | type == "object") | .key as $feature
        | .value | to_entries[] | select(.key | test("^temp[0-9]+_input$"))
        | "\($chip)\t\($feature)\t\(.value | round)"'
}

status() {
    local sensors
    sensors=$(read_sensors)
    pick() { awk -F'\t' -v chip="$1" -v feat="$2" '$1 ~ chip && $2 ~ feat { print $3; exit }' <<< "$sensors"; }

    local acpi cpu_package cpu_hottest
    acpi=$(pick '^acpitz' '^temp1$')
    cpu_package=$(pick '^coretemp' '^Package')
    cpu_hottest=$(awk -F'\t' '$1 ~ /^coretemp/ && $2 ~ /^Core/ && $3 > max { max = $3 } END { print max }' <<< "$sensors")

    local tooltip="CPU package: ${cpu_package:-?}°C"$'\n'"CPU hottest core: ${cpu_hottest:-?}°C"
    tooltip+=$'\n'"Motherboard (ACPI): ${acpi:-?}°C"
    local i=1 ssd
    while read -r ssd; do
        tooltip+=$'\n'"SSD $i: ${ssd}°C"
        i=$((i + 1))
    done < <(awk -F'\t' '$1 ~ /^nvme/ && $2 == "Composite" { print $3 }' <<< "$sensors")
    local wifi
    wifi=$(pick '^iwlwifi' '^temp1$')
    [[ -n $wifi ]] && tooltip+=$'\n'"Wi-Fi card: ${wifi}°C"

    local value=${acpi:-${cpu_package:-0}} icon class=normal
    if   ((value >= 70)); then icon=$ICON_HIGH
    elif ((value >= 50)); then icon=$ICON_MID
    else icon=$ICON_LOW; fi
    ((value >= CRITICAL)) && class=critical

    jq -c -n --arg text "${value}°C $icon" --arg tooltip "$tooltip" --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

case ${1:-} in
    status) status ;;
    *)      usage; exit 1 ;;
esac
