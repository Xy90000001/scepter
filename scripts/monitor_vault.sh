#!/bin/bash
# monitor_vault.sh — log health of vault services (cross-platform)
# Runs via cron or systemd timer. Checks:
# - vault-watcher.service active (desktop only)
# - gbrain serve responding on 8080
# - graphify-out freshness (updated in last 24h)

set -euo pipefail

# Detect platform
if [[ -d "/data/data/com.termux" ]]; then
    HOME_DIR="/data/data/com.termux/files/home"
    VAULT="${VAULT_ROOT:-$HOME_DIR/storage/shared/scepter}"
    PLATFORM="termux"
else
    HOME_DIR="$HOME"
    VAULT="${VAULT_ROOT:-$HOME/scepter}"
    PLATFORM="desktop"
fi

LOG_TAG="vault-monitor"

# Check vault-watcher service (desktop only - uses systemd)
if [[ "$PLATFORM" == "desktop" ]]; then
    if systemctl --user is-active --quiet vault-watcher.service 2>/dev/null; then
        echo "$(date +%F_%T) vault-watcher: OK" | systemd-cat -t "$LOG_TAG" -p info 2>/dev/null || logger -t "$LOG_TAG" "vault-watcher: OK"
    else
        echo "$(date +%F_%T) vault-watcher: DOWN" | systemd-cat -t "$LOG_TAG" -p err 2>/dev/null || logger -t "$LOG_TAG" "vault-watcher: DOWN"
    fi
fi

# Check gbrain serve health
if curl -s http://localhost:8080/health 2>/dev/null | grep -q '"status":"ok"'; then
    echo "$(date +%F_%T) gbrain: OK" | systemd-cat -t "$LOG_TAG" -p info 2>/dev/null || logger -t "$LOG_TAG" "gbrain: OK"
else
    echo "$(date +%F_%T) gbrain: DOWN" | systemd-cat -t "$LOG_TAG" -p err 2>/dev/null || logger -t "$LOG_TAG" "gbrain: DOWN"
fi

# Check graphify-out freshness
GRAPH_REPORT="$VAULT/graphify-out/GRAPH_REPORT.md"
if [[ -f "$GRAPH_REPORT" ]]; then
    MOD_AGE=$(( ($(date +%s) - $(stat -c %Y "$GRAPH_REPORT" 2>/dev/null || stat -f %m "$GRAPH_REPORT")) / 3600 ))
    if [[ $MOD_AGE -lt 24 ]]; then
        echo "$(date +%F_%T) graphify: OK (${MOD_AGE}h old)" | systemd-cat -t "$LOG_TAG" -p info 2>/dev/null || logger -t "$LOG_TAG" "graphify: OK (${MOD_AGE}h old)"
    else
        echo "$(date +%F_%T) graphify: STALE (${MOD_AGE}h old)" | systemd-cat -t "$LOG_TAG" -p warning 2>/dev/null || logger -t "$LOG_TAG" "graphify: STALE (${MOD_AGE}h old)"
    fi
else
    echo "$(date +%F_%T) graphify: MISSING" | systemd-cat -t "$LOG_TAG" -p err 2>/dev/null || logger -t "$LOG_TAG" "graphify: MISSING"
fi