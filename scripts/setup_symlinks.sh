#!/bin/bash
# setup_symlinks.sh — Create per-profile symlinks for cross-device Hermes
# Lean Vault Isolation Protocol:
# - Profile DEFINITIONS (SOUL.md, config.yaml) in vault
# - Runtime files (state.db, caches, sessions) stay local only
# - heromi: SYMLINKED from vault to local on BOTH PC and Termux
# - skills: kept in vault (~/scepter/skills/), NOT symlinked
# - PC-only profiles: created locally, never in vault

set -euo pipefail

VAULT="${VAULT_ROOT:-$HOME/scepter}"
HERMES_DIR="$HOME/.hermes"

# Detect platform
if [[ -d "/data/data/com.termux" ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
    PLATFORM="termux"
    VAULT="${VAULT_ROOT:-$HOME/scepter}"
else
    PLATFORM="desktop"
fi

echo "Setting up profiles for $PLATFORM..."

mkdir -p "$HERMES_DIR/profiles"

VAULT_PROFILES="$VAULT/Hermes/Profiles"
LOCAL_PROFILES="$HERMES_DIR/profiles"

# Function: symlink heromi profile from vault to local (full profile directory)
symlink_heromi() {
    local src="$VAULT_PROFILES/heromi"
    local dst="$LOCAL_PROFILES/heromi"
    
    if [[ ! -d "$src" ]]; then
        echo "  WARNING: heromi not found in vault"
        return 1
    fi
    
    # Remove existing (file, dir, or symlink)
    rm -rf "$dst"
    
    # Symlink entire profile directory
    ln -s "$src" "$dst"
    echo "  heromi symlinked from vault"
}

if [[ "$PLATFORM" == "termux" ]]; then
    # TERMUX: symlink heromi from vault
    symlink_heromi
    
    echo "  PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops) are LOCAL ONLY"
    echo "  skills/ remain in vault (not symlinked)"
else
    # DESKTOP: symlink heromi from vault
    symlink_heromi
    
    echo "  PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops) remain local"
    echo "  skills/ remain in vault (not symlinked)"
fi

echo "Done. Local profiles in $LOCAL_PROFILES:"
ls -1 "$LOCAL_PROFILES" 2>/dev/null || echo "  (empty)"