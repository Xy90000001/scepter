#!/bin/bash
# vault_watch.sh — inotifywait watcher for scepter vault
# Pulls on every file change (debounced), runs vault_sync.sh
# Logs to ~/.vault_watch.log
# Cross-platform (Linux + Termux via termux-api)

set -euo pipefail

# Detect platform
if [[ -d "/data/data/com.termux" ]]; then
    HOME_DIR="/data/data/com.termux/files/home"
    VAULT="${VAULT_ROOT:-$HOME_DIR/storage/shared/scepter}"
    SYNC_SCRIPT="$VAULT/scripts/vault_sync.sh"
    LOG_FILE="$HOME_DIR/.vault_watch.log"
    PLATFORM="termux"
else
    HOME_DIR="$HOME"
    VAULT="${VAULT_ROOT:-$HOME/scepter}"
    SYNC_SCRIPT="$VAULT/scripts/vault_sync.sh"
    LOG_FILE="$HOME_DIR/.vault_watch.log"
    PLATFORM="desktop"
fi

DEBOUNCE=5

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

if [[ ! -x "$SYNC_SCRIPT" ]]; then
    log "ERROR: sync script not executable: $SYNC_SCRIPT"
    exit 1
fi

log "Watcher started [$PLATFORM]. Watching: $VAULT"

# Use a temp flag file for debounce
FLAG="/tmp/vault_watch_pending"

# Build watch list from existing paths
WATCH_PATHS=()
for p in "$VAULT/Brain" "$VAULT/01_Tasks" "$VAULT/00_Inbox" \
    "$VAULT/Hermes/Memory" "$VAULT/02_Projects" "$VAULT/03_Outreach" \
    "$VAULT/AGENTS.md" "$VAULT/scripts"; do
    [[ -e "$p" ]] && WATCH_PATHS+=("$p")
done

# Platform-specific inotifywait
if [[ "$PLATFORM" == "termux" ]]; then
    # Termux: use termux-inotifywait (from termux-api package) or poll fallback
    if command -v termux-inotifywait >/dev/null 2>&1; then
        INOTIFY_CMD="termux-inotifywait"
    else
        log "WARN: termux-inotifywait not installed (pkg install termux-api). Falling back to polling."
        # Polling fallback: check every 30s
        while true; do
            sleep 30
            # Quick check for changes via git status
            cd "$VAULT"
            if ! git diff --quiet || ! git diff --cached --quiet; then
                log "Change detected via git status"
                touch "$FLAG"
                sleep "$DEBOUNCE"
                if [[ -f "$FLAG" ]]; then
                    rm -f "$FLAG"
                    log "Running sync..."
                    if "$SYNC_SCRIPT" >>"$LOG_FILE" 2>&1; then
                        log "Sync OK"
                    else
                        log "Sync FAILED (exit $?)"
                    fi
                fi
            fi
        done
        exit 0
    fi
else
    INOTIFY_CMD="inotifywait"
fi

# Main watch loop
"$INOTIFY_CMD" -q -m -r -e modify,create,delete,move,attrib \
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