#!/bin/bash
# Scepter vault sync — cross-platform (Linux/macOS/Windows/Termux)
# Order: pull --rebase -> export sessions -> sync memory -> STRUCTURE.md -> commit -> push
# Silent when nothing changed.

set -euo pipefail

# Detect platform
if [[ -d "/data/data/com.termux" ]]; then
    HOME_DIR="/data/data/com.termux/files/home"
    PY="$HOME_DIR/.hermes/venv/bin/python"
    VAULT="$HOME_DIR/storage/shared/scepter"
else
    HOME_DIR="$HOME"
    PY="$HOME/.hermes/venv/bin/python"
    VAULT="$HOME/scepter"
fi

LOG="$HOME_DIR/.vault_sync.log"
RECENT_DAYS="${SCEPTER_RECENT_DAYS:-14}"

# 0. Pull remote first (conflict-safe)
cd "$VAULT"
if ! git pull --rebase -q origin main 2>>"$LOG"; then
    git rebase --abort 2>/dev/null || true
    echo "$(date +%F_%T) pull/rebase conflict in vault" >> "$LOG"
    exit 1
fi

# 1. Session export (hybrid: digests all + transcripts recent)
if [[ -f "$VAULT/scripts/export_sessions.py" ]]; then
    "$PY" "$VAULT/scripts/export_sessions.py" --recent-days "$RECENT_DAYS" >/dev/null 2>&1 || true
fi

# 2. Memory sync (Android needs copy; PC uses symlink)
if [[ -d "$HOME_DIR/.hermes/memories" && -d "$VAULT/Hermes/Memory" ]]; then
    cp -u "$HOME_DIR/.hermes/memories/MEMORY.md" "$HOME_DIR/.hermes/memories/USER.md" \
          "$VAULT/Hermes/Memory/" 2>/dev/null || true
fi

# 3. Structural index
if [[ -f "$VAULT/scripts/tree_index.sh" ]]; then
    bash "$VAULT/scripts/tree_index.sh" "$VAULT" 2>/dev/null || true
fi

# 3b. Graphify update (incremental knowledge graph)
if [[ -f "$VAULT/scripts/graphify_update.sh" ]]; then
    bash "$VAULT/scripts/graphify_update.sh" 2>/dev/null || true
fi

# 4. Commit local changes (skip if nothing changed)
cd "$VAULT"
git add -A
if git diff --cached --quiet; then
    exit 0
fi
git commit -q -m "chore: sync second brain $(date +%Y-%m-%d_%H%M)"

# 5. Push
git push -q origin main 2>>"$LOG"