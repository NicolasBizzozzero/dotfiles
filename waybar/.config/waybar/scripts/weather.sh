#!/usr/bin/env bash
#
# weather.sh - current weather for the waybar `custom/weather` module (ipinfo.io + wttr.in)
#
# Usage:
#   weather.sh status   JSON for waybar: weather icon, temperature and city

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

status() {
    # 1. Fetch the city based on your current IP address
    local city
    city=$(curl -s https://ipinfo.io/city 2>/dev/null)

    # 2. If the API fails or returns nothing, fallback to Chelles
    if [ -z "$city" ]; then
        city="Chelles"
    fi

    # (Optional) If you want to force the city name to be ALL CAPS, uncomment the line below:
    # city="${city^^}"

    # 3. Replace any spaces in the city name with '+' for the URL
    local formatted_city
    formatted_city=$(echo "$city" | tr ' ' '+')

    # 4. Try to fetch ONLY the weather Icon (%c) and Temp (%t)
    local weather text
    weather=$(curl -s -f -m 5 -H 'Accept-Language: fr' "https://wttr.in/${formatted_city}?format=%c+%t" 2>/dev/null)
    # wttr pads the icon with trailing spaces: keep a single one
    weather=$(echo "$weather" | tr -s ' ')

    # 5. Output validation and manual string assembly
    if [[ -z "$weather" ]] || [[ "$weather" == *"Unknown"* ]]; then
        text="󰖐 N/A"
    else
        # Stitch the weather and our perfectly capitalized city variable together
        text="$weather $city"
    fi
    jq -c -n --arg text "$text" '{text: $text}'
}

case ${1:-} in
    status) status ;;
    *)      usage; exit 1 ;;
esac
