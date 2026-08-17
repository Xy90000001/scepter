#!/bin/bash
# monitor_vault.sh — log health of vault services to systemd journal
# Runs via cron or systemd timer. Checks:
# - vault-watcher.service active
# - gbrain serve responding on 8080
# - graphify-out freshness (updated in last 24h)

set -euo pipefail

LOG_TAG="vault-monitor"

# Check vault-watcher service
if systemctl --user is-active --quiet vault-watcher.service; then
    echo "$(date +%F_%T) vault-watcher: OK" | systemd-cat -t "$LOG_TAG" -p info
else
    echo "$(date +%F_%T) vault-watcher: DOWN" | systemd-cat -t "$LOG_TAG" -p err
fi

# Check gbrain serve health
if curl -s http://localhost:8080/health | grep -q '"status":"ok"'; then
    echo "$(date +%F_%T) gbrain: OK" | systemd-cat -t "$LOG_TAG" -p info
else
    echo "$(date +%F_%T) gbrain: DOWN" | systemd-cat -t "$LOG_TAG" -p err
fi

# Check graphify-out freshness
GRAPH_REPORT="/home/exash/scepter/graphify-out/GRAPH_REPORT.md"
if [[ -f "$GRAPH_REPORT" ]]; then
    MOD_AGE=$(( ($(date +%s) - $(stat -c %Y "$GRAPH_REPORT")) / 3600 ))
    if [[ $MOD_AGE -lt 24 ]]; then
        echo "$(date +%F_%T) graphify: OK (${MOD_AGE}h old)" | systemd-cat -t "$LOG_TAG" -p info
    else
        echo "$(date +%F_%T) graphify: STALE (${MOD_AGE}h old)" | systemd-cat -t "$LOG_TAG" -p warning
    fi
else
    echo "$(date +%F_%T) graphify: MISSING" | systemd-cat -t "$LOG_TAG" -p err
fi
