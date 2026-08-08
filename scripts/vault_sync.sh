#!/bin/bash
# Scepter vault sync — the single fast loop (cronie every 15 min).
# Order: export sessions -> sync memory -> STRUCTURE.md -> commit local ->
# pull --rebase (conflict-safe) -> push. Silent when nothing changed.
set -e

HOME_DIR="/data/data/com.termux/files/home"
PY="$HOME_DIR/.hermes/venv/bin/python"
VAULT="$HOME_DIR/storage/shared/scepter"
LOG="$HOME_DIR/.vault_sync.log"
RECENT_DAYS="${SCEPTER_RECENT_DAYS:-14}"

# 1. Session export (hybrid: digests all + transcripts recent)
"$PY" "$VAULT/scripts/export_sessions.py" --recent-days "$RECENT_DAYS" >/dev/null 2>&1 || true

# 2. Memory sync (live files stay internal — FUSE can't flock)
cp -u "$HOME_DIR/.hermes/memories/MEMORY.md" "$HOME_DIR/.hermes/memories/USER.md" \
      "$VAULT/Hermes/Memory/" 2>/dev/null || true

# 3. Structural index
bash "$VAULT/scripts/tree_index.sh" "$VAULT" 2>/dev/null || true

cd "$VAULT"

# 4. Commit local changes (skip if nothing changed)
git add -A
if git diff --cached --quiet; then
    exit 0
fi
git commit -q -m "chore: sync second brain $(date +%Y-%m-%d_%H%M)"

# 5. Pull remote (conflict-safe) then push
if ! git pull --rebase -q origin main 2>>"$LOG"; then
    git rebase --abort 2>/dev/null || true
    echo "$(date +%F_%T) pull/rebase conflict in vault" >> "$LOG"
    exit 1
fi
git push -q origin main 2>>"$LOG"
