#!/bin/bash
# Scepter backup: export sessions → commit → push. Silent when nothing changed.
# Cross-platform (Android/PC). Detects environment.

set -euo pipefail

# Detect platform
if [[ -d "/data/data/com.termux" ]]; then
    # Android/Termux
    HOME_DIR="/data/data/com.termux/files/home"
    PY="$HOME_DIR/.hermes/venv/bin/python"
    VAULT="$HOME_DIR/storage/shared/scepter"
else
    # Linux/macOS/Windows (WSL)
    HOME_DIR="$HOME"
    PY="$HOME/.hermes/venv/bin/python"
    VAULT="$HOME/scepter"
fi

RECENT_DAYS="${SCEPTER_RECENT_DAYS:-14}"

# Export session history
if [[ -f "$VAULT/scripts/export_sessions.py" ]]; then
    "$PY" "$VAULT/scripts/export_sessions.py" --recent-days "$RECENT_DAYS" >/dev/null 2>&1 || true
fi

# Sync live memory into the vault
# On PC: symlink handles this; on Android: copy is needed
if [[ -d "$HOME_DIR/.hermes/memories" && -d "$VAULT/Hermes/Memory" ]]; then
    cp -u "$HOME_DIR/.hermes/memories/MEMORY.md" "$HOME_DIR/.hermes/memories/USER.md" \
          "$VAULT/Hermes/Memory/" 2>/dev/null || true
fi

# Structural index
if [[ -f "$VAULT/scripts/tree_index.sh" ]]; then
    bash "$VAULT/scripts/tree_index.sh" "$VAULT" 2>/dev/null || true
fi

# Graphify update (incremental knowledge graph)
if [[ -f "$VAULT/scripts/graphify_update.sh" ]]; then
    bash "$VAULT/scripts/graphify_update.sh" 2>/dev/null || true
fi

cd "$VAULT"
git add -A
if git diff --cached --quiet; then
    exit 0
fi

git commit -q -m "chore: sync second brain $(date +%Y-%m-%d_%H%M)"
git push -q origin main