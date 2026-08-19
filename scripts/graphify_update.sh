#!/bin/bash
# graphify_update.sh — incremental graphify update for scepter vault
# Runs before push: updates knowledge graph with changed files only
# PC ONLY — skip on Termux (graphify not installed on Termux)

set -euo pipefail

# Detect platform
if [[ -d "/data/data/com.termux" ]]; then
    echo "[graphify_update] Termux detected — skipping (graphify is PC only)"
    exit 0
else
    HOME_DIR="$HOME"
    VAULT="${VAULT_ROOT:-$HOME/scepter}"
fi

cd "$VAULT"

# Check if graphify-out exists (graph already built)
if [[ ! -d "graphify-out" || ! -f "graphify-out/graph.json" ]]; then
    echo "[graphify_update] No existing graph — skipping (run 'graphify .' manually first)"
    exit 0
fi

# Check if GEMINI_API_KEY is available (needed for semantic extraction of new docs)
if [[ -z "${GEMINI_API_KEY:-}" && -z "${GOOGLE_API_KEY:-}" ]]; then
    echo "[graphify_update] No GEMINI_API_KEY — running code-only update (AST only)"
    graphify update . --code-only --no-viz >/dev/null 2>&1 || true
else
    # Incremental update: re-extracts only changed files, uses LLM for new docs
    graphify update . --no-viz >/dev/null 2>&1 || true
fi

# Refresh community labels & report (no LLM if labels unchanged)
graphify cluster-only . --no-viz >/dev/null 2>&1 || true

echo "[graphify_update] Graph updated"