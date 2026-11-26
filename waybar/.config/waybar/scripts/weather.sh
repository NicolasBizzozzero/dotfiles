#!/usr/bin/env bash
#
# weather.sh - current weather for the waybar `custom/weather` module (Wi-Fi name or ipinfo.io + wttr.in)
#
# Usage:
#   weather.sh status   JSON for waybar: weather icon, temperature and city
#   weather.sh pad      JSON for waybar's custom/weather-pad: blank room before the center group
#   weather.sh city     the city, then on a second line how it was found: wifi, ip or default

# Known Wi-Fi networks (SSID) and their city. They come first: on one of them,
# the city is exact and nothing is sent to ipinfo.io. ipinfo.io guesses the city
# from the IP address, which belongs to the internet provider: its guess can be
# hundreds of kilometres off. Name of the current Wi-Fi: iw dev wlan0 link
# The table is in CITIES_FILE, kept out of the dotfiles repository (it is
# public, and a Wi-Fi name with its town points to a home). It holds:
#   CITIES=(["MyWifi"]="Paris" ["Office Wi-Fi"]="Lyon")
CITIES_FILE=~/.config/waybar/weather_cities.sh
declare -A CITIES=()
# shellcheck source=/dev/null
[[ -r $CITIES_FILE ]] && source "$CITIES_FILE"
# Used when the Wi-Fi is unknown and ipinfo.io does not answer
DEFAULT_CITY="Chelles"
# The last text shown, and the characters after its icon in the longest one at
# home: "-12°C Vaires-sur-Marne". A longer city moves the date a little
LAST_TEXT="${XDG_RUNTIME_DIR:-/tmp}/waybar-weather"
WEATHER_WIDTH=22

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

# Print the city, then how it was found. The Wi-Fi name is readable without root.
find_city() {
    local interface ssid city
    for interface in $(iw dev | awk '$1 == "Interface" { print $2 }'); do
        ssid=$(iw dev "$interface" link | sed -n 's/^\s*SSID: //p')
        if [[ -n $ssid && -n ${CITIES[$ssid]:-} ]]; then
            printf '%s\nwifi\n' "${CITIES[$ssid]}"
            return
        fi
    done

    city=$(curl -s -m 5 https://ipinfo.io/city 2>/dev/null)
    if [[ -n $city ]]; then
        printf '%s\nip\n' "$city"
    else
        printf '%s\ndefault\n' "$DEFAULT_CITY"
    fi
}

status() {
    local city
    city=$(find_city | head -n 1)

    # (Optional) If you want to force the city name to be ALL CAPS, uncomment the line below:
    # city="${city^^}"

    # Replace any spaces in the city name with '+' for the URL
    local formatted_city
    formatted_city=$(echo "$city" | tr ' ' '+')

    # Fetch ONLY the weather Icon (%c) and Temp (%t)
    local weather text
    weather=$(curl -s -f -m 5 -H 'Accept-Language: fr' "https://wttr.in/${formatted_city}?format=%c+%t" 2>/dev/null)
    # wttr pads the icon with trailing spaces: keep a single one
    weather=$(echo "$weather" | tr -s ' ')
    # Zero has no sign: wttr writes +0°C, -0°C, or even +-0°C
    weather=$(echo "$weather" | sed -E 's/[+-]+0°/0°/')

    # Output validation and manual string assembly
    if [[ -z "$weather" ]] || [[ "$weather" == *"Unknown"* ]]; then
        text="󰖐 N/A"
    else
        # Stitch the weather and our perfectly capitalized city variable together
        text="$weather $city"
    fi
    jq -c -n --arg text "$text" '{text: $text}'
    # For custom/weather-pad, which then reads it again (signal 13)
    printf '%s\n' "$text" > "$LAST_TEXT"
    pkill -RTMIN+13 -x waybar
}

# The date starts at the center of the screen, and GTK centers the whole group:
# a shorter weather text would move that start. custom/weather-pad, at the far
# left of the group, adds the missing characters as spaces (the bar's font is
# monospaced, so a space is as wide as a letter). Blank and out of the way, it
# keeps every visible gap the same. Counted after the icon: the icon is an
# emoji, as wide whichever it is.
pad() {
    local text rest
    text=$(cat "$LAST_TEXT" 2>/dev/null)
    rest=${text#* }
    local missing=$((WEATHER_WIDTH - ${#rest}))
    ((missing < 0)) && missing=0
    printf -v rest '%*s' "$missing" ''
    jq -c -n --arg text "$rest" '{text: $text}'
}

case ${1:-} in
    status) status ;;
    pad)    pad ;;
    city)   find_city ;;
    *)      usage; exit 1 ;;
esac
