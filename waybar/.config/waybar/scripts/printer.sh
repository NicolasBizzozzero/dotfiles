#!/usr/bin/env bash
#
# printer.sh - print queue for the waybar `custom/printer` module (CUPS: lpstat, ipptool, cancel + rofi)
#
# Usage:
#   printer.sh status   JSON for waybar: job count, printer state and toner levels in tooltip
#   printer.sh menu     cancel jobs, pause/resume printers, set the default (clicking again closes it)

WAYBAR_SIGNAL=10
ICON=󰐪
CUPS_URL=http://localhost:631
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-printer-state"
IPP_TEST="${XDG_RUNTIME_DIR:-/tmp}/waybar-printer.test"

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

notify() { notify-send -a Printer -i printer "Printer" "$1"; }

# CUPS starts on demand (cups.socket) and stops when idle: only query it when it
# already runs, otherwise polling every few seconds would keep it alive forever.
cups_running() { pgrep -x cupsd >/dev/null; }

printers()        { lpstat -e 2>/dev/null; }
default_printer() { lpstat -d 2>/dev/null | sed -n 's/^.*destination: //p'; }
# "printer-id<TAB>user<TAB>size" for each pending job
jobs_list()       { lpstat -o 2>/dev/null | awk '{ print $1 "\t" $2 "\t" $3 }'; }

# Print "attribute<TAB>value" for the state, state reasons and toner levels of a printer
printer_attrs() {
    cat > "$IPP_TEST" <<'EOF'
{
    OPERATION Get-Printer-Attributes
    GROUP operation-attributes-tag
    ATTR charset attributes-charset utf-8
    ATTR naturalLanguage attributes-natural-language en
    ATTR uri printer-uri $uri
    ATTR keyword requested-attributes printer-state,printer-state-reasons,marker-names,marker-levels
    DISPLAY printer-state
    DISPLAY printer-state-reasons
    DISPLAY marker-names
    DISPLAY marker-levels
}
EOF
    ipptool -t "ipp://localhost/printers/$1" "$IPP_TEST" 2>/dev/null \
        | sed -n 's/^ *\([a-z-]*\) ([^)]*) = \(.*\)$/\1\t\2/p'
}

# Reasons that need the user: errors (no paper, jam, door open...) and offline
is_problem() { grep -qE -- '-error|offline-report' <<< "$1"; }

status() {
    local text=$ICON class=idle tooltip
    if ! cups_running; then
        echo idle > "$STATE_FILE"
        jq -c -n --arg text "$text" '{text: $text, tooltip: "No print jobs", class: "idle"}'
        return
    fi

    local -a printer_names
    mapfile -t printer_names < <(printers)
    local default njobs
    default=$(default_printer)
    njobs=$(jobs_list | grep -c .)
    ((njobs > 0)) && { text="$ICON $njobs"; class=printing; }

    if ((${#printer_names[@]} == 0)); then
        tooltip="No printer configured"
    else
        local name attr value state reasons names levels problems=""
        for name in "${printer_names[@]}"; do
            state="" reasons="" names="" levels=""
            while IFS=$'\t' read -r attr value; do
                case $attr in
                    printer-state)         state=$value ;;
                    printer-state-reasons) reasons=$value ;;
                    marker-names)          names=$value ;;
                    marker-levels)         levels=$value ;;
                esac
            done < <(printer_attrs "$name")

            tooltip+="$name"
            [[ $name == "$default" ]] && tooltip+=" (default)"
            tooltip+=": ${state:-unknown}"
            [[ -n $reasons && $reasons != none ]] && tooltip+=" - ${reasons//,/, }"
            if is_problem "$reasons"; then
                class=problem
                problems+="$name: ${reasons//,/, }"$'\n'
            fi

            # Toner/ink levels, when the printer reports them (negative = unknown)
            if [[ -n $names && -n $levels ]]; then
                local -a marker_names marker_levels
                IFS=, read -ra marker_names <<< "$names"
                IFS=, read -ra marker_levels <<< "$levels"
                local i
                for i in "${!marker_names[@]}"; do
                    local level=${marker_levels[$i]:--1}
                    if ((level >= 0)); then level="$level%"; else level="unknown"; fi
                    tooltip+=$'\n'"  ${marker_names[$i]}: $level"
                done
            fi
            tooltip+=$'\n'
        done
        ((njobs > 0)) && tooltip+=$'\n'"$njobs job(s) in the queue" || tooltip+=$'\n'"No print jobs"
    fi

    # Notify on changes only: jobs done, or a new problem
    local previous
    previous=$(cat "$STATE_FILE" 2>/dev/null)
    if [[ $class == problem && $previous != problem ]]; then
        notify "Needs attention: ${problems%$'\n'}"
    elif [[ $class == idle && $previous == printing ]]; then
        notify "All jobs printed"
    fi
    echo "$class" > "$STATE_FILE"

    jq -c -n --arg text "$text" --arg tooltip "${tooltip%$'\n'}" --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

printer_menu() {
    local name=$1 state choice
    state=$(lpstat -p "$name" 2>/dev/null)
    local -a entries=("󰄬  Set as default") actions=(default)
    if grep -q disabled <<< "$state"; then
        entries+=("󰐊  Resume"); actions+=(resume)
    else
        entries+=("󰏤  Pause"); actions+=(pause)
    fi
    choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "$ICON  $name")
    [[ -z $choice ]] && return
    case ${actions[$choice]} in
        default) lpoptions -d "$name" >/dev/null && notify "$name is now the default printer" ;;
        pause)   cupsdisable "$name" && notify "$name paused" ;;
        resume)  cupsenable "$name" && notify "$name resumed" ;;
    esac
}

menu() {
    if pgrep -x rofi >/dev/null; then
        pkill -x rofi
        return
    fi

    local -a entries actions args
    local job user size name default
    while IFS=$'\t' read -r job user size; do
        [[ -z $job ]] && continue
        entries+=("󰅖  Cancel ${job%-*} job ${job##*-} ($user, $size bytes)"); actions+=(cancel); args+=("$job")
    done < <(jobs_list)
    if ((${#entries[@]} > 0)); then
        entries+=("󰅙  Cancel all jobs"); actions+=(cancel-all); args+=("")
    fi

    default=$(default_printer)
    while read -r name; do
        [[ -z $name ]] && continue
        local label="$ICON  $name"
        [[ $name == "$default" ]] && label+="  ✓"
        lpstat -p "$name" 2>/dev/null | grep -q disabled && label+="  (paused)"
        entries+=("$label"); actions+=(printer); args+=("$name")
    done < <(printers)
    if ! printers | grep -q .; then
        entries+=("󰋼  No printer configured"); actions+=(none); args+=("")
    fi

    entries+=("󰖟  Open CUPS (add a printer)"); actions+=(web); args+=("")

    local choice
    choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "$ICON  Printers")
    [[ -z $choice ]] && return
    case ${actions[$choice]} in
        cancel)     cancel "${args[$choice]}" && notify "Job ${args[$choice]} cancelled" ;;
        cancel-all) cancel -a && notify "All jobs cancelled" ;;
        printer)    printer_menu "${args[$choice]}" ;;
        web)        xdg-open "$CUPS_URL" ;;
    esac
    pkill -RTMIN+$WAYBAR_SIGNAL waybar
}

case ${1:-} in
    status) status ;;
    menu)   menu ;;
    *)      usage; exit 1 ;;
esac
