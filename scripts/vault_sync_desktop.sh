#!/bin/bash
# Scepter vault sync — desktop version (Linux)
# Order: pull --rebase -> export sessions -> sync memory -> STRUCTURE.md -> commit -> push
# Silent when nothing changed.

set -euo pipefail

HOME_DIR="$HOME"
VAULT="$HOME/scepter"
PY="$HOME/.hermes/venv/bin/python"
LOG="$HOME/.vault_sync.log"
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

# 2. Memory sync (symlink on desktop — already in sync, but ensure)
# No cp needed since ~/.hermes/memories -> ~/scepter/Hermes/Memory

# 3. Structural index
if [[ -f "$VAULT/scripts/tree_index.sh" ]]; then
    bash "$VAULT/scripts/tree_index.sh" "$VAULT" 2>/dev/null || true
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