#!/bin/bash
# vault_watch.sh — inotifywait watcher for scepter vault
# Pulls on every file change (debounced), runs vault_sync_desktop.sh
# Logs to ~/.vault_watch.log

VAULT="$HOME/scepter"
SYNC_SCRIPT="$VAULT/scripts/vault_sync_desktop.sh"
LOG_FILE="$HOME/.vault_watch.log"
DEBOUNCE=5

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

if [[ ! -x "$SYNC_SCRIPT" ]]; then
    log "ERROR: sync script not executable: $SYNC_SCRIPT"
    exit 1
fi

log "Watcher started. Watching: $VAULT"

# Use a temp flag file for debounce
FLAG="/tmp/vault_watch_pending"

# Build watch list from existing paths
WATCH_PATHS=()
for p in "$VAULT/Brain" "$VAULT/01_Tasks" "$VAULT/00_Inbox" \
    "$VAULT/Hermes/Memory" "$VAULT/02_Projects" "$VAULT/03_Outreach" \
    "$VAULT/AGENTS.md" "$VAULT/scripts"; do
    [[ -e "$p" ]] && WATCH_PATHS+=("$p")
done

inotifywait -q -m -r -e modify,create,delete,move,attrib \
    --exclude '(\.git|Hermes/Sessions|nohup\.out|\.obsidian)' \
    --format '%w%f %e %T' --timefmt '%s' \
    "${WATCH_PATHS[@]}" 2>>"$LOG_FILE" | while read -r line; do

    log "Change detected: $line"

    # Touch flag file
    touch "$FLAG"

    # Wait debounce window
    sleep "$DEBOUNCE"

    # If flag still fresh (not modified during sleep), run sync
    if [[ -f "$FLAG" ]]; then
        rm -f "$FLAG"
        log "Running sync..."
        if "$SYNC_SCRIPT" >>"$LOG_FILE" 2>&1; then
            log "Sync OK"
        else
            log "Sync FAILED (exit $?)"
        fi
    fi
done
