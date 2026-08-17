#!/bin/bash
# vault_sync_termux.sh — Termux/Android sync for Scepter vault
# Runs via cronie + termux-services every 15 min
# Usage: bash ~/storage/shared/scepter/scripts/vault_sync_termux.sh

set -euo pipefail

VAULT="${VAULT:-$HOME/storage/shared/scepter}"
PY="${PY:-python3}"
LOG_FILE="$HOME/.vault_sync.log"
RECENT_DAYS=7

# Termux-specific: keep device awake during sync
termux-wake-lock 2>/dev/null || true

cleanup() {
    termux-wake-unlock 2>/dev/null || true
}
trap cleanup EXIT

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Termux vault sync" >> "$LOG_FILE"

cd "$VAULT" || { echo "Vault not found at $VAULT" >> "$LOG_FILE"; exit 1; }

# 1. Git pull --rebase (get remote changes)
echo "[$(date)] Pulling..." >> "$LOG_FILE"
git pull --rebase origin main >> "$LOG_FILE" 2>&1 || { echo "Git pull failed" >> "$LOG_FILE"; exit 1; }

# 2. Session export (hybrid: digests all + transcripts recent)
if [[ -f "$VAULT/scripts/session_sync.py" ]]; then
    "$PY" "$VAULT/scripts/session_sync.py" export --recent-days "$RECENT_DAYS" >> "$LOG_FILE" 2>&1
fi

# 3. Graphify update (keep code graph current)
if command -v graphify >/dev/null 2>&1; then
    graphify update . >> "$LOG_FILE" 2>&1 || true
fi

# 4. gbrain embed stale (if gbrain available)
if command -v gbrain >/dev/null 2>&1; then
    gbrain embed --stale >> "$LOG_FILE" 2>&1 || true
fi

# 5. STRUCTURE.md refresh (optional, for Obsidian file explorer)
if [[ -f "$VAULT/scripts/gen_structure.py" ]]; then
    "$PY" "$VAULT/scripts/gen_structure.py" >> "$LOG_FILE" 2>&1 || true
fi

# 6. Commit if any changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    git add -A
    git commit -m "vault backup: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1
    git push origin main >> "$LOG_FILE" 2>&1
    echo "[$(date)] Pushed changes" >> "$LOG_FILE"
else
    echo "[$(date)] No changes to commit" >> "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sync complete" >> "$LOG_FILE"