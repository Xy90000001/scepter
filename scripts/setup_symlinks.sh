#!/bin/bash
# setup_symlinks.sh — Create per-profile symlinks for cross-device Hermes
# Lean Vault Isolation Protocol:
# - heromi: symlinked on BOTH PC and Termux (cross-platform)
# - xosin: symlinked/moved to local on Termux only (staged in vault)
# - All PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops, agency-*) are LOCAL ONLY, never in vault

set -euo pipefail

VAULT="${VAULT_ROOT:-$HOME/scepter}"
HERMES_DIR="$HOME/.hermes"

# Detect platform
if [[ -d "/data/data/com.termux" ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
    PLATFORM="termux"
    VAULT="${VAULT_ROOT:-$HOME/storage/shared/scepter}"
else
    PLATFORM="desktop"
fi

echo "Setting up symlinks for $PLATFORM..."

mkdir -p "$HERMES_DIR"

# 1. Memory: symlink on PC, copy-sync on Termux (handled by vault_sync.sh)
if [[ "$PLATFORM" == "desktop" ]]; then
    rm -rf "$HERMES_DIR/memories"
    ln -sfn "$VAULT/Hermes/Memory" "$HERMES_DIR/memories"
    echo "  memories → $VAULT/Hermes/Memory (symlink)"
fi

# 2. Profiles: per-profile symlinks based on platform
PROFILES_DIR="$HERMES_DIR/profiles"
VAULT_PROFILES="$VAULT/Hermes/Profiles"

rm -rf "$PROFILES_DIR"
mkdir -p "$PROFILES_DIR"

if [[ "$PLATFORM" == "termux" ]]; then
    # TERMUX: symlink heromi from vault, move xosin from vault to local
    # heromi (cross-platform)
    if [[ -d "$VAULT_PROFILES/heromi" ]]; then
        ln -sfn "$VAULT_PROFILES/heromi" "$PROFILES_DIR/heromi"
        echo "  heromi → $VAULT_PROFILES/heromi (symlink)"
    fi

    # xosin (staged in vault, moved to local on Termux)
    if [[ -d "$VAULT_PROFILES/xosin" ]]; then
        cp -r "$VAULT_PROFILES/xosin" "$PROFILES_DIR/xosin"
        echo "  xosin → $PROFILES_DIR/xosin (copied from vault to local)"
        # Optionally remove from vault after first deployment
        # rm -rf "$VAULT_PROFILES/xosin"
    fi

    echo "  PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops) are LOCAL ONLY — not linked from vault"
else
    # DESKTOP (PC): symlink heromi from vault
    if [[ -d "$VAULT_PROFILES/heromi" ]]; then
        ln -sfn "$VAULT_PROFILES/heromi" "$PROFILES_DIR/heromi"
        echo "  heromi → $VAULT_PROFILES/heromi (symlink)"
    fi

    # xosin is NOT linked on PC (Termux-only)
    # PC-only profiles are already local at ~/.hermes/Profiles/
    echo "  xosin (Termux-only) not linked on PC"
    echo "  PC-only profiles (xorin, ceo, engineer, product, growth, finance, ops) remain local at ~/.hermes/Profiles/"
fi

echo "Done. Profiles in $PROFILES_DIR:"
ls -1 "$PROFILES_DIR" 2>/dev/null || echo "  (empty)"