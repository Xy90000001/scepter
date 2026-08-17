#!/bin/bash
# setup_symlinks.sh — Create per-profile symlinks for cross-device Hermes
# Run once on each device after cloning vault

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

# 1. Memory: always symlink (PC) or copy-sync via vault_sync (Termux)
#    On Termux, vault_sync.sh handles copying MEMORY.md/USER.md
#    On PC, symlink for direct writes
if [[ "$PLATFORM" == "desktop" ]]; then
    rmdir "$HERMES_DIR/memories" 2>/dev/null || true
    ln -sfn "$VAULT/Hermes/Memory" "$HERMES_DIR/memories"
    echo "  memories → $VAULT/Hermes/Memory (symlink)"
fi

# 2. Profiles: per-profile symlinks based on platform
PROFILES_DIR="$HERMES_DIR/profiles"
VAULT_PROFILES="$VAULT/Hermes/Profiles"

rmdir "$PROFILES_DIR" 2>/dev/null || true
mkdir -p "$PROFILES_DIR"

# Shared profiles (exist on all devices)
SHARED_PROFILES=("xorin" "ceo" "engineer" "product" "growth" "finance" "ops")

# Platform-specific profiles
if [[ "$PLATFORM" == "termux" ]]; then
    PLATFORM_PROFILES=("heromi")
else
    PLATFORM_PROFILES=()
fi

ALL_PROFILES=("${SHARED_PROFILES[@]}" "${PLATFORM_PROFILES[@]}")

for profile in "${ALL_PROFILES[@]}"; do
    if [[ -d "$VAULT_PROFILES/$profile" ]]; then
        ln -sfn "$VAULT_PROFILES/$profile" "$PROFILES_DIR/$profile"
        echo "  $profile → $VAULT_PROFILES/$profile (symlink)"
    else
        echo "  WARNING: $profile not found in vault"
    fi
done

echo "Done. Profiles in $PROFILES_DIR:"
ls -1 "$PROFILES_DIR"