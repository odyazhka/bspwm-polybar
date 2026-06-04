#!/usr/bin/env bash
# bspwm-desktops.sh — polybar module for BSPWM workspace switching
#
# Modes:
#   collapsed  — shows only the current desktop number; click to expand
#   expanded   — shows all desktops for this monitor; current is marked [X] (non-clickable)
#                clicking another desktop switches to it and collapses
#
# Multi-monitor: each polybar instance must pass its monitor name via $MONITOR env var.
# The script queries bspwm to discover which desktops belong to that monitor.
#
# Usage in polybar config:
#
#   [module/bspwm-desktops]
#   type             = custom/script
#   exec             = MONITOR=%{monitor} ~/.config/polybar/bspwm-desktops.sh
#   exec-if          = command -v bspc
#   interval         = 0
#   tail             = true
#   click-left       = MONITOR=%{monitor} ~/.config/polybar/bspwm-desktops.sh toggle &
#
# Environment variables:
#   MONITOR          — monitor name (e.g. eDP-1, HDMI-1). Falls back to the focused monitor.
#   STATE_DIR        — directory for per-monitor state files (default: /tmp/bspwm-desktops)

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
STATE_DIR="${STATE_DIR:-/tmp/bspwm-desktops}"
mkdir -p "$STATE_DIR"

# Polybar IPC action prefix (used for clickable areas)
# %{A1:command:} wraps a left-click action
SCRIPT="$(realpath "$0")"

# ── Helpers ──────────────────────────────────────────────────────────────────

# Resolve the monitor we're running on.
get_monitor() {
    if [[ -n "${MONITOR:-}" ]]; then
        echo "$MONITOR"
    else
        # Fall back to the monitor that holds the focused desktop
        bspc query -M -m focused --names 2>/dev/null | head -1
    fi
}

# Return all desktop names assigned to $1 (monitor name), in order.
get_desktops_for_monitor() {
    local mon="$1"
    bspc query -D -m "$mon" --names 2>/dev/null
}

# Return the name of the currently focused desktop on $1 (monitor name).
get_focused_desktop() {
    local mon="$1"
    bspc query -D -m "$mon" -d focused --names 2>/dev/null | head -1
}

# State file path for a given monitor.
state_file() {
    local mon="$1"
    # Replace any / or space in monitor name to make a safe filename
    echo "${STATE_DIR}/mode_${mon//[^a-zA-Z0-9_-]/_}"
}

# Read current mode for a monitor (collapsed | expanded).
get_mode() {
    local sf
    sf="$(state_file "$1")"
    if [[ -f "$sf" ]]; then
        cat "$sf"
    else
        echo "collapsed"
    fi
}

# Write mode for a monitor.
set_mode() {
    local sf
    sf="$(state_file "$1")"
    echo "$2" > "$sf"
}

# ── Output ───────────────────────────────────────────────────────────────────

render() {
    local mon="$1"
    local mode
    mode="$(get_mode "$mon")"

    mapfile -t desktops < <(get_desktops_for_monitor "$mon")
    local focused
    focused="$(get_focused_desktop "$mon")"

    if [[ "$mode" == "collapsed" ]]; then
        # Show only the focused desktop; click expands
        local toggle_cmd="MONITOR=${mon} ${SCRIPT} toggle"
        echo "%{A1:${toggle_cmd}:}%{O4}${focused}%{O4}%{A}"
    else
        # Expanded: show all desktops, current is non-clickable [X]
        local output=""
        local first=1
        for d in "${desktops[@]}"; do
            if [[ "$d" == "$focused" ]]; then
                if [[ "$first" == "1" ]]; then
                    output+="[${d}]"
                else
                    output+=" [${d}]"
                fi
            else
                local switch_cmd="MONITOR=${mon} ${SCRIPT} switch ${d}"
                if [[ "$first" == "1" ]]; then
                    output+="%{A1:${switch_cmd}:}${d} %{A}"
                else
                    output+="%{A1:${switch_cmd}:} ${d} %{A}"
                fi
            fi
            first=0
        done
        # Strip trailing space before closing O4
        output="${output% }"
        echo "%{O4}${output}%{O4}"
    fi
}

# ── Actions ──────────────────────────────────────────────────────────────────

action_toggle() {
    local mon="$1"
    local cur
    cur="$(get_mode "$mon")"
    if [[ "$cur" == "collapsed" ]]; then
        set_mode "$mon" "expanded"
    else
        set_mode "$mon" "collapsed"
    fi
    # Signal polybar to refresh (polybar-msg is preferred; fall back to pkill)
    refresh_polybar
}

action_switch() {
    local mon="$1"
    local desktop="$2"
    bspc desktop -f "$desktop"
    set_mode "$mon" "collapsed"
    refresh_polybar
}

refresh_polybar() {
    # Try polybar IPC first (polybar ≥ 3.4)
    if command -v polybar-msg &>/dev/null; then
        polybar-msg cmd restart 2>/dev/null || true
    fi
    # Also send SIGUSR1 to all polybar processes (harmless fallback)
    pkill -SIGUSR1 polybar 2>/dev/null || true
}

# ── Event loop (tail mode) ────────────────────────────────────────────────────

run_loop() {
    local mon="$1"

    # Emit initial output
    render "$mon"

    # Subscribe to bspwm events and re-render on any desktop/focus change
    bspc subscribe desktop_focus desktop_add desktop_remove desktop_rename \
        node_transfer | while read -r _event; do
        render "$mon"
    done
}

# ── Entry point ───────────────────────────────────────────────────────────────

MONITOR="$(get_monitor)"

if [[ -z "$MONITOR" ]]; then
    echo "ERR: no monitor"
    exit 1
fi

case "${1:-loop}" in
    loop)
        run_loop "$MONITOR"
        ;;
    toggle)
        action_toggle "$MONITOR"
        ;;
    switch)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 switch <desktop-name>" >&2
            exit 1
        fi
        action_switch "$MONITOR" "$2"
        ;;
    render)
        render "$MONITOR"
        ;;
    *)
        echo "Usage: $0 [loop|toggle|switch <desktop>|render]" >&2
        exit 1
        ;;
esac
