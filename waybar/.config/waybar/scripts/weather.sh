#!/bin/bash

# 1. Fetch the city based on your current IP address
CITY=$(curl -s https://ipinfo.io/city 2>/dev/null)

# 2. If the API fails or returns nothing, fallback to Chelles
if [ -z "$CITY" ]; then
    CITY="Chelles"
fi

# 3. Replace any spaces in the city name with '+' for the URL (e.g., "Vaires sur Marne" -> "Vaires+sur+Marne")
FORMATTED_CITY=$(echo "$CITY" | tr ' ' '+')

# 4. Try to fetch weather (max 5 seconds timeout)
RESPONSE=$(curl -s -f -m 5 -H 'Accept-Language: fr' "https://wttr.in/${FORMATTED_CITY}?format=%c+%t" 2>/dev/null)

# 5. Output validation: If response is empty or contains "Unknown location", show a fallback
if [[ -z "$RESPONSE" ]] || [[ "$RESPONSE" == *"Unknown"* ]]; then
    echo "󰖐 N/A"
else
    echo "$RESPONSE"
fi
