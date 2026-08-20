#!/bin/bash
# setup_symlinks.sh — Create per-profile symlinks for cross-device Hermes
# Lean Vault Isolation Protocol:
# - Profile DEFINITIONS (SOUL.md, config.yaml) in vault
# - Runtime copies to local ~/.hermes/Profiles/<name>/
# - Runtime files (state.db, caches, sessions) stay local only
# - xosin: copied from vault to local on Termux only

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

# Function: copy profile definition from vault to local (SOUL.md + config.yaml only)
sync_profile_def() {
    local profile="$1"
    local src="$VAULT_PROFILES/$profile"
    local dst="$LOCAL_PROFILES/$profile"
    
    if [[ ! -d "$src" ]]; then
        echo "  WARNING: $profile not found in vault"
        return 1
    fi
    
    mkdir -p "$dst"
    
    # Copy only definition files (not runtime)
    for f in SOUL.md config.yaml; do
        if [[ -f "$src/$f" ]]; then
            cp "$src/$f" "$dst/$f"
        fi
    done
    
    echo "  $profile definition synced from vault"
}

if [[ "$PLATFORM" == "termux" ]]; then
    # TERMUX: sync heromi + xosin definitions from vault
    sync_profile_def "heromi"
    sync_profile_def "xosin"
    
    echo "  PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops) are LOCAL ONLY"
else
    # DESKTOP: sync heromi definition from vault
    sync_profile_def "heromi"
    
    echo "  xosin (Termux-only) not synced on PC"
    echo "  PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops) remain local"
fi

echo "Done. Local profiles in $LOCAL_PROFILES:"
ls -1 "$LOCAL_PROFILES" 2>/dev/null || echo "  (empty)"