#!/usr/bin/env bash
#
# apply.sh - install the TUXEDO Control Center profiles of profiles.json (no GUI needed)
#
# Usage:
#   sudo ~/.config/tuxedo/apply.sh   install/update the profiles, the first one becomes the default
#
# Safety: profiles.json is checked first, /etc/tcc is backed up, tccd is stopped
# while its files are written (so it cannot overwrite them), profiles not defined
# here are kept, and if tccd does not come back with the new default profile
# active, the backup is restored. Only TCC settings are touched: firmware calls
# are made by tccd itself, exactly as when using its GUI.

set -euo pipefail

DIR=$(dirname "$(readlink -f "$0")")
PROFILES=$DIR/profiles.json
TCC=/etc/tcc
STAMP=$(date +%Y%m%d-%H%M%S)

die() { echo "apply.sh: $*" >&2; exit 1; }
usage() { sed -n 's/^#   /  /p' "$0" >&2; }

[[ ${1:-} == -h || ${1:-} == --help ]] && { usage; exit 0; }
[[ $EUID -eq 0 ]] || die "needs root: sudo $0"
for f in "$TCC/profiles" "$TCC/settings"; do [[ -f $f ]] || die "$f not found (is tuxedo-control-center installed?)"; done

# Same fields as the profiles tccd already uses, unique ids
jq -e --slurpfile current "$TCC/profiles" '
    type == "array" and length > 0
    and ([.[].id] | length == (unique | length))
    and all(.[]; (keys) == ($current[0][0] | keys))
' "$PROFILES" >/dev/null || die "$PROFILES is invalid (JSON, unique ids, same fields as $TCC/profiles)"
DEFAULT=$(jq -r '.[0].id' "$PROFILES")

cp -a "$TCC/profiles" "$TCC/profiles.bak-$STAMP"
cp -a "$TCC/settings" "$TCC/settings.bak-$STAMP"
echo "Backup: $TCC/{profiles,settings}.bak-$STAMP"

restore() {
    echo "Restoring the backup" >&2
    systemctl stop tccd || true
    cp -a "$TCC/profiles.bak-$STAMP" "$TCC/profiles"
    cp -a "$TCC/settings.bak-$STAMP" "$TCC/settings"
    systemctl start tccd || true
}
trap 'restore; die "failed, nothing changed"' ERR

systemctl stop tccd

# Replace the profiles with the same ids, keep the others (e.g. "TUXEDO Defaults")
TMP=$(mktemp)
jq --slurpfile new "$PROFILES" '
    ($new[0] | map(.id)) as $ids
    | [ .[] | select(.id as $id | $ids | index($id) | not) ] + $new[0]
' "$TCC/profiles" > "$TMP"
install -m 644 "$TMP" "$TCC/profiles"

# Default profile on AC and on battery
jq --arg id "$DEFAULT" '.stateMap.power_ac = $id | .stateMap.power_bat = $id' "$TCC/settings" > "$TMP"
install -m 644 "$TMP" "$TCC/settings"
rm -f "$TMP"

systemctl start tccd

active=""
for _ in $(seq 1 40); do
    active=$(busctl --system --json=short call com.tuxedocomputers.tccd /com/tuxedocomputers/tccd \
        com.tuxedocomputers.tccd GetActiveProfileJSON 2>/dev/null | jq -r '.data[0]' | jq -r '.id' 2>/dev/null || true)
    [[ $active == "$DEFAULT" ]] && break
    sleep 0.5
done
[[ $active == "$DEFAULT" ]] || false   # triggers the restore

trap - ERR
echo "Done: active profile \"$(jq -r '.[0].name' "$PROFILES")\" ($DEFAULT), default on AC and battery"
