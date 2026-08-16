#!/usr/bin/env bash
# vault_watch.sh — inotifywait watcher for scepter vault
# Watches for file changes, debounces, runs vault_sync.sh
# Runs in background; logs to ~/.vault_watch.log

set -euo pipefail

VAULT="${VAULT:-$HOME/scepter}"
SYNC_SCRIPT="$VAULT/scripts/vault_sync.sh"
LOG_FILE="${LOG_FILE:-$HOME/.vault_watch.log}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-3}"

# Directories to watch (space-separated, no trailing slashes)
WATCH_DIRS=(
    "$VAULT/Brain"
    "$VAULT/01_Tasks"
    "$VAULT/00_Inbox"
    "$VAULT/Hermes/Memory"
    "$VAULT/02_Projects"
    "$VAULT/03_Outreach"
    "$VAULT/AGENTS.md"
    "$VAULT/scripts"
)

# Exclude patterns (grep -E)
EXCLUDE_PATTERN='(\.git|Hermes/Sessions|nohup\.out|\.obsidian)'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Check sync script exists
if [[ ! -x "$SYNC_SCRIPT" ]]; then
    log "ERROR: sync script not found or not executable: $SYNC_SCRIPT"
    exit 1
fi

# Build inotifywait args
INOTIFY_ARGS=(
    -q                    # quiet
    -r                    # recursive
    -e modify,create,delete,move,attrib
    --exclude "$EXCLUDE_PATTERN"
    --format '%w%f %e %T'
    --timefmt '%s'
)

log "Starting vault watcher for: ${WATCH_DIRS[*]}"
log "Debounce: ${DEBOUNCE_SECONDS}s | Sync: $SYNC_SCRIPT"

# Debounce state
last_event_time=0
pending_sync=false

# Process events
inotifywait "${INOTIFY_ARGS[@]}" "${WATCH_DIRS[@]}" | while IFS= read -r line; do
    # Parse: filepath event_type timestamp
    filepath="${line%% *}"
    rest="${line#* }"
    event_type="${rest%% *}"
    event_time="${rest#* }"

    # Skip excluded (belt-and-suspenders)
    if [[ "$filepath" =~ $EXCLUDE_PATTERN ]]; then
        continue
    fi

    now=$(date +%s)
    last_event_time=$event_time
    pending_sync=true

    log "Change: $event_type $filepath"

    # Debounce: wait for quiet period
    sleep "$DEBOUNCE_SECONDS"

    # Check if another event arrived during debounce
    if [[ $(date +%s) -lt $((last_event_time + DEBOUNCE_SECONDS)) ]]; then
        continue  # more changes coming, wait for next loop iteration
    fi

    if [[ "$pending_sync" == true ]]; then
        log "Debounce elapsed — running sync..."
        pending_sync=false

        if "$SYNC_SCRIPT" >>"$LOG_FILE" 2>&1; then
            log "Sync completed successfully"
        else
            log "Sync FAILED (exit code $?) — check $LOG_FILE"
        fi
    fi
done