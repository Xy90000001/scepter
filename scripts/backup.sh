#!/bin/bash
# Scepter backup: export sessions → commit → push. Silent when nothing changed.
set -e

PY=/data/data/com.termux/files/home/.hermes/venv/bin/python
VAULT=/data/data/com.termux/files/home/storage/shared/scepter
RECENT_DAYS="${SCEPTER_RECENT_DAYS:-14}"

# Export session history (stdout suppressed — stay quiet on success)
"$PY" "$VAULT/scripts/export_sessions.py" --recent-days "$RECENT_DAYS" >/dev/null

# Sync live memory into the vault (Android shared storage can't host the live
# files: FUSE lacks flock, which the memory tool requires). Vault = canonical
# interchange; PC symlinks it directly, Android syncs one-way here.
cp -u "$HOME/.hermes/memories/MEMORY.md" "$HOME/.hermes/memories/USER.md" \
      "$VAULT/Hermes/Memory/" 2>/dev/null || true

cd "$VAULT"
git add -A
if git diff --cached --quiet; then
  exit 0  # nothing changed — no commit, no message
fi

git commit -q -m "chore: sync second brain $(date +%Y-%m-%d_%H%M)"
git push -q origin main
