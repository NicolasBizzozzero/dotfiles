#!/bin/bash

# 1. Define where your wallpapers are stored
WALLPAPER_DIR="$HOME/.config/wallpapers"

# 2. Find all valid images and pick one at random
RANDOM_PIC=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

# 3. Dynamically overwrite the hyprpaper config file using the NEW block syntax!
cat <<EOF > "$HOME/.config/hypr/hyprpaper.conf"
wallpaper {
    monitor = eDP-1
    path = $RANDOM_PIC
    fit_mode = cover
}

splash = false
ipc = true
EOF

# 4. Kill any stray instances of hyprpaper
killall -q hyprpaper

# 5. Launch hyprpaper
exec hyprpaper
