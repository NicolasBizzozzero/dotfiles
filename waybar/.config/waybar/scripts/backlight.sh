#!/usr/bin/env bash
#
# backlight.sh - screen brightness for the waybar `custom/backlight` module, also usable from the command line
#
# Usage:
#   backlight.sh status       JSON for waybar: current brightness
#   backlight.sh              show current brightness
#   backlight.sh set 60       set brightness to 60%       (or: backlight.sh 60)
#   backlight.sh up [N]       increase by N% (default 5)  (or: backlight.sh +N)
#   backlight.sh down [N]     decrease by N% (default 5)  (or: backlight.sh -N)
#
# Optional environment variables:
#   LUMINOSITY_DEVICE  device in /sys/class/backlight to use (default: auto-detect)
#   LUMINOSITY_STEP    default step for up/down, in %       (default: 5)
#   LUMINOSITY_MIN     lowest allowed %, so the screen never goes black (default: 5,
#                      the screen turns off below that)
#
# Permissions: no sudo needed. If the brightness file isn't writable, the change
# is sent to systemd-logind, which allows it for the user of the active session.
# If logind refuses (e.g. when run over SSH), give the video group direct write
# access instead, then reboot:
#   echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' | sudo tee /etc/udev/rules.d/90-backlight.rules
#   sudo usermod -aG video "$USER"
 
set -euo pipefail
 
SYSFS=/sys/class/backlight
STEP=${LUMINOSITY_STEP:-5}
MIN=${LUMINOSITY_MIN:-5}
WAYBAR_SIGNAL=8
 
die() { echo "luminosity: $*" >&2; exit 1; }
 
usage() {
    cat <<EOF
Usage: ${0##*/} [status | get | set N | up [N] | down [N] | N | +N | -N]
  status     JSON for waybar: current brightness
  get        show current brightness (default)
  set N, N   set brightness to N%
  up [N]     increase by N% (default: $STEP), same as +N
  down [N]   decrease by N% (default: $STEP), same as -N
EOF
}
 
# Parse arguments into an action and a number
case ${1:-get} in
    -h|--help|help) usage; exit 0 ;;
    status) action=status n=0 ;;
    get)  action=get  n=0 ;;
    set)  action=set  n=${2:-} ;;
    up)   action=up   n=${2:-$STEP} ;;
    down) action=down n=${2:-$STEP} ;;
    +*)   action=up   n=${1#+} ;;
    -*)   action=down n=${1#-} ;;
    *)    action=set  n=$1 ;;
esac
[[ $n =~ ^[0-9]+$ ]] || { usage >&2; exit 1; }
n=$(( 10#$n ))  # otherwise "08" would be read as (invalid) octal
 
# Find the backlight device. If there are several, prefer
# firmware > platform > raw, as the kernel documentation recommends.
find_device() {
    local type dev
    if [[ -n ${LUMINOSITY_DEVICE:-} ]]; then
        [[ -e $SYSFS/$LUMINOSITY_DEVICE/brightness ]] \
            || die "no backlight device named '$LUMINOSITY_DEVICE' in $SYSFS"
        echo "$SYSFS/$LUMINOSITY_DEVICE"
        return
    fi
    for type in firmware platform raw; do
        for dev in "$SYSFS"/*; do
            if [[ -r $dev/type && $(<"$dev/type") == "$type" ]]; then
                echo "$dev"
                return
            fi
        done
    done
    die "no backlight device in $SYSFS (external monitor? those need ddcutil)"
}
 
DEV=$(find_device)
MAX=$(<"$DEV/max_brightness")
CUR=$(<"$DEV/brightness")
MIN_RAW=$(( (MIN * MAX + 99) / 100 ))  # rounded up, so MIN=1 never gives 0
 
clamp()      { echo $(( $1 > MAX ? MAX : ($1 < MIN_RAW ? MIN_RAW : $1) )); }
to_raw()     { clamp $(( ($1 * MAX + 50) / 100 )); }      # percent -> raw value
to_percent() { echo $(( ($1 * 100 + MAX / 2) / MAX )); }  # raw value -> percent
 
write_raw() {
    if [[ -w $DEV/brightness ]]; then
        echo "$1" > "$DEV/brightness"
    else
        busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto \
            org.freedesktop.login1.Session SetBrightness ssu backlight "${DEV##*/}" "$1" \
            || die "logind refused the change, see 'Permissions' at the top of this script"
    fi
}
 
pct=$(to_percent "$CUR")
case $action in
    status) jq -c -n --arg text "$pct%" '{text: $text}'; exit 0 ;;
    get)  echo "$pct%"; exit 0 ;;
    set)  new=$(to_raw "$n") ;;
    up)   new=$(to_raw $(( pct + n ))) ;;
    down) new=$(to_raw $(( pct - n ))) ;;
esac
 
# With few brightness levels (e.g. max_brightness=7) a small step can round back
# to the current value: move at least one level so a key press always does something.
if (( new == CUR )); then
    case $action in
        up)   new=$(clamp $(( CUR + 1 ))) ;;
        down) new=$(clamp $(( CUR - 1 ))) ;;
    esac
fi
 
if (( new != CUR )); then
    write_raw "$new"
    pkill -RTMIN+$WAYBAR_SIGNAL waybar || true
fi
echo "$(to_percent "$new")%"
 
