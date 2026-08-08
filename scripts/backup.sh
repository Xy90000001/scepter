#!/bin/bash
# Scepter backup: export sessions → commit → push. Silent when nothing changed.
set -e

PY=/data/data/com.termux/files/home/.hermes/venv/bin/python
VAULT=/data/data/com.termux/files/home/storage/shared/scepter
RECENT_DAYS="${SCEPTER_RECENT_DAYS:-14}"

# Export session history (stdout suppressed — stay quiet on success)
"$PY" "$VAULT/scripts/export_sessions.py" --recent-days "$RECENT_DAYS" >/dev/null

cd "$VAULT"
git add -A
if git diff --cached --quiet; then
  exit 0  # nothing changed — no commit, no message
fi

git commit -q -m "chore: sync second brain $(date +%Y-%m-%d_%H%M)"
git push -q origin main
