#!/usr/bin/env bash
#
# claude.sh - Claude Code usage for the waybar `custom/claude` module (claude CLI)
#
# Usage:
#   claude.sh status   JSON for waybar: session usage, session and weekly usage in tooltip

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

usage() { sed -n 's/^#   /  /p' "$0" >&2; }

status() {
    local raw_output
    raw_output=$(claude --no-session-persistance -p "/usage" < /dev/null 2>/dev/null)

    if [[ -z "$raw_output" ]]; then
        jq -c -n --arg text '<span color="#df3320">󰚩 Err</span>' \
                 --arg tooltip 'Failed to execute claude CLI' \
                 '{"text": $text, "tooltip": $tooltip}'
        return
    fi

    local session_usage week_usage session_reset week_reset
    session_usage=$(echo "$raw_output" | awk -F'resets ' '/Current session/ {split($1,a,": "); split(a[2],b," "); print b[1]}')
    week_usage=$(echo "$raw_output" | awk -F'resets ' '/Current week/ {split($1,a,": "); split(a[2],b," "); print b[1]}')
    session_reset=$(echo "$raw_output" | awk -F'resets ' '/Current session/ {print $2}')
    week_reset=$(echo "$raw_output" | awk -F'resets ' '/Current week/ {print $2}')

    session_usage=${session_usage:-"N/A"}
    week_usage=${week_usage:-"N/A"}
    session_reset=${session_reset:-"N/A"}
    week_reset=${week_reset:-"N/A"}

    local text tooltip
    text="<span color=\"#32cd32\">󰚩 ${session_usage}</span>"
    tooltip="Session: ${session_usage} (Resets: ${session_reset})
Week: ${week_usage} (Resets: ${week_reset})"

    jq -c -n --arg text "$text" --arg tooltip "$tooltip" \
        '{"text": $text, "tooltip": $tooltip}'
}

case ${1:-} in
    status) status ;;
    *)      usage; exit 1 ;;
esac
