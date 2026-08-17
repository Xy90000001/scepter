#!/bin/bash
# dispatch_guard.sh — Validate environment before dispatching to a profile
# Usage: dispatch_guard.sh <target_profile> [task_id]
# Returns 0 if safe to dispatch, 1 if target profile would fail on current device

set -euo pipefail

TARGET_PROFILE="${1:-}"
TASK_ID="${2:-}"

if [[ -z "$TARGET_PROFILE" ]]; then
    echo "Usage: $0 <target_profile> [task_id]" >&2
    exit 1
fi

# Detect current environment
if [[ -d "/data/data/com.termux" ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
    CURRENT_ENV="termux"
else
    CURRENT_ENV="desktop"
fi

# Profile environment requirements
case "$TARGET_PROFILE" in
    heromi)
        REQUIRED_ENV="termux"
        ;;
    xorin|ceo|engineer|product|growth|finance|ops)
        REQUIRED_ENV="desktop"
        ;;
    *)
        echo "Unknown profile: $TARGET_PROFILE" >&2
        exit 1
        ;;
esac

if [[ "$CURRENT_ENV" != "$REQUIRED_ENV" ]]; then
    echo "BLOCKED: Cannot dispatch to '$TARGET_PROFILE' from $CURRENT_ENV (requires $REQUIRED_ENV)" >&2
    if [[ -n "$TASK_ID" ]]; then
        echo "Task $TASK_ID would fail — use 'hermes kanban update $TASK_ID --assignee <correct_profile>'" >&2
    fi
    exit 1
fi

echo "OK: $TARGET_PROFILE can run on $CURRENT_ENV"
exit 0