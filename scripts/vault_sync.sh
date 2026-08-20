#!/bin/bash
# vault_sync.sh — Cross-platform sync for Scepter vault (Linux/macOS/Termux)
# Lean Vault Isolation Protocol: only heromi profile + sessions sync
# Order: pull --rebase -> export heromi sessions -> sync memory -> graphify update -> commit -> push
# Silent when nothing changed.

set -euo pipefail

# Detect platform
if [[ -d "/data/data/com.termux" ]]; then
    HOME_DIR="/data/data/com.termux/files/home"
    PY="$HOME_DIR/.hermes/hermes-agent/venv/bin/python"
    VAULT="$HOME_DIR/scepter"
    PLATFORM="termux"
    # Keep device awake during sync
    termux-wake-lock 2>/dev/null || true
    trap 'termux-wake-unlock 2>/dev/null || true' EXIT
else
    HOME_DIR="$HOME"
    PY="$HOME/.hermes/hermes-agent/venv/bin/python"
    VAULT="$HOME/scepter"
    PLATFORM="desktop"
fi

LOG="$HOME_DIR/.vault_sync.log"
RECENT_DAYS="${SCEPTER_RECENT_DAYS:-14}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$PLATFORM] Starting vault sync" >> "$LOG"

cd "$VAULT" || { echo "Vault not found at $VAULT" >> "$LOG"; exit 1; }

# 0. Pull remote first (conflict-safe)
if ! git pull --rebase -q origin main 2>>"$LOG"; then
    git rebase --abort 2>/dev/null || true
    echo "[$(date)] [$PLATFORM] pull/rebase conflict in vault" >> "$LOG"
    exit 1
fi

# 1. Session sync (mutual: export local heromi sessions, import remote heromi sessions)
if [[ -f "$VAULT/scripts/session_sync.py" ]]; then
    if [[ "$PLATFORM" == "desktop" ]]; then
        # PC: export local heromi sessions, then import any remote heromi sessions
        "$PY" "$VAULT/scripts/session_sync.py" export --recent-days "$RECENT_DAYS" --profile heromi >> "$LOG" 2>&1 || true
        "$PY" "$VAULT/scripts/session_sync.py" import --profile heromi >> "$LOG" 2>&1 || true
    else
        # Termux: import remote heromi sessions, then export any local heromi sessions
        "$PY" "$VAULT/scripts/session_sync.py" import --profile heromi >> "$LOG" 2>&1 || true
        "$PY" "$VAULT/scripts/session_sync.py" export --recent-days "$RECENT_DAYS" --profile heromi >> "$LOG" 2>&1 || true
    fi
fi

# 1b. Kanban tasks sync (mutual: export local changes, import remote changes)
if [[ -f "$VAULT/scripts/kanban_sync.py" ]]; then
    if [[ "$PLATFORM" == "desktop" ]]; then
        # PC: export local tasks to JSON, then import any remote changes
        "$PY" "$VAULT/scripts/kanban_sync.py" export >> "$LOG" 2>&1 || true
        "$PY" "$VAULT/scripts/kanban_sync.py" import >> "$LOG" 2>&1 || true
    else
        # Termux: import remote tasks, then export any local changes
        "$PY" "$VAULT/scripts/kanban_sync.py" import >> "$LOG" 2>&1 || true
        "$PY" "$VAULT/scripts/kanban_sync.py" export >> "$LOG" 2>&1 || true
    fi
fi

# 1c. Profile definition sync (copy SOUL.md + config.yaml from vault to local)
if [[ -f "$VAULT/scripts/setup_symlinks.sh" ]]; then
    bash "$VAULT/scripts/setup_symlinks.sh" >> "$LOG" 2>&1 || true
fi

# 2. Memory sync (Android needs copy; PC uses symlink but copy is safe both ways)
if [[ -d "$HOME_DIR/.hermes/memories" && -d "$VAULT/Hermes/Memory" ]]; then
    cp -u "$HOME_DIR/.hermes/memories/MEMORY.md" "$HOME_DIR/.hermes/memories/USER.md" \
          "$VAULT/Hermes/Memory/" 2>/dev/null || true
fi

# 3. Graphify update (PC ONLY — skip on Termux)
if [[ "$PLATFORM" == "desktop" ]]; then
    if command -v graphify >/dev/null 2>&1; then
        graphify update . >> "$LOG" 2>&1 || true
    fi

    # 4. gbrain embed stale (PC ONLY — skip on Termux)
    if command -v gbrain >/dev/null 2>&1; then
        gbrain embed --stale >> "$LOG" 2>&1 || true
    fi
else
    echo "[$(date)] [$PLATFORM] Skipping graphify/gbrain (PC only)" >> "$LOG"
fi

# 5. STRUCTURE.md refresh (PC only for now)
if [[ "$PLATFORM" == "desktop" && -f "$VAULT/scripts/gen_structure.py" ]]; then
    "$PY" "$VAULT/scripts/gen_structure.py" >> "$LOG" 2>&1 || true
fi

# 6. Commit local changes (skip if nothing changed)
git add -A
if git diff --cached --quiet; then
    echo "[$(date)] [$PLATFORM] No changes to commit" >> "$LOG"
    exit 0
fi

git commit -q -m "chore: sync second brain $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG" 2>&1

# 7. Push
if git push -q origin main 2>>"$LOG"; then
    echo "[$(date)] [$PLATFORM] Pushed changes" >> "$LOG"
else
    echo "[$(date)] [$PLATFORM] Push failed" >> "$LOG"
    exit 1
fi