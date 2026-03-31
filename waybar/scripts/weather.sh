#!/bin/bash

# 1. Fetch the city based on your current IP address
CITY=$(curl -s https://ipinfo.io/city 2>/dev/null)

# 2. If the API fails or returns nothing, fallback to Chelles
if [ -z "$CITY" ]; then
    CITY="Chelles"
fi

# 3. Replace any spaces in the city name with '+' for the URL (e.g., "Vaires sur Marne" -> "Vaires+sur+Marne")
FORMATTED_CITY=$(echo "$CITY" | tr ' ' '+')

# 4. Fetch the weather using the dynamic city
curl -s -H 'Accept-Language: fr' "https://wttr.in/${FORMATTED_CITY}?format=%c+%t"
